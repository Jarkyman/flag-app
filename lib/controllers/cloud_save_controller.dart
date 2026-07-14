import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../cloud_save/cloud_save_gateway.dart';
import '../cloud_save/cloud_save_session.dart';
import '../cloud_save/cloud_save_store.dart';
import '../cloud_save/models/cloud_save_data.dart';

enum CloudSaveStatus { idle, syncing, saving, restoring }

enum CloudSaveResult {
  success,
  notFound,
  notSignedIn,
  unsupported,
  invalidBackup,
  failed,
}

class CloudSaveController extends GetxController
    with WidgetsBindingObserver
    implements GetxService {
  static const legacySaveName = 'flags-game-cloud-save-v1';
  static const autoSaveNames = [
    'flags-game-cloud-autosave-v2-a',
    'flags-game-cloud-autosave-v2-b',
  ];
  static const _readableSaveNames = [...autoSaveNames, legacySaveName];

  final CloudSaveGateway gateway;
  final CloudSaveStore store;
  final CloudSaveSession session;
  final DateTime Function() now;
  final Duration autoSaveDelay;
  final Duration launchRetryDelay;
  final Duration launchSyncTimeout;
  final int launchLoadAttempts;

  CloudSaveController({
    required this.gateway,
    required this.store,
    required this.session,
    DateTime Function()? now,
    this.autoSaveDelay = const Duration(seconds: 3),
    this.launchRetryDelay = const Duration(milliseconds: 750),
    this.launchSyncTimeout = const Duration(seconds: 6),
    this.launchLoadAttempts = 8,
  })  : assert(launchLoadAttempts > 0),
        now = now ?? DateTime.now;

  CloudSaveStatus _status = CloudSaveStatus.idle;
  CloudSaveStatus get status => _status;
  bool get isBusy => _status != CloudSaveStatus.idle;
  DateTime? get lastCloudSaveAt => store.lastCloudSaveAt;
  Timer? _autoSaveTimer;
  bool _initialRemoteAbsenceConfirmed = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  void scheduleAutoSave() {
    if (!gateway.isSupported ||
        _status == CloudSaveStatus.restoring ||
        _status == CloudSaveStatus.syncing) {
      return;
    }
    final changedAt = now().toUtc();
    unawaited(store.markPendingChanges(changedAt));
    if (!session.isSignedIn) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(autoSaveDelay, () {
      unawaited(flushAutoSave());
    });
  }

  Future<void> flushAutoSave() async {
    if (store.pendingChangeAt == null ||
        !gateway.isSupported ||
        !session.isSignedIn) {
      return;
    }
    if (isBusy) {
      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer(autoSaveDelay, () {
        unawaited(flushAutoSave());
      });
      return;
    }

    _setStatus(CloudSaveStatus.saving);
    try {
      await _reconcilePendingChanges();
    } catch (error, stackTrace) {
      _logError('Could not autosave progress', error, stackTrace);
    } finally {
      _setStatus(CloudSaveStatus.idle);
    }
  }

  Future<CloudSaveResult> syncOnLaunch() async {
    if (!gateway.isSupported) return CloudSaveResult.unsupported;
    if (!await _ensureSignedIn()) return CloudSaveResult.notSignedIn;

    _setStatus(CloudSaveStatus.syncing);
    try {
      final backups = await _loadRemoteBackupsWithRetry().timeout(
        launchSyncTimeout,
      );
      final bestRemote = _selectBestRemote(backups);
      if (bestRemote == null) {
        _initialRemoteAbsenceConfirmed = true;
        debugPrint('Cloud launch sync: no remote backup found.');
        if (store.pendingChangeAt != null) _schedulePendingUpload();
        return CloudSaveResult.notFound;
      }
      _initialRemoteAbsenceConfirmed = false;
      debugPrint(
        'Cloud launch sync: found ${bestRemote.name} from '
        '${bestRemote.data.savedAtUtc.toIso8601String()}.',
      );

      final lastLocalSave = store.lastCloudSaveAt;
      final pendingChange = store.pendingChangeAt;
      if (lastLocalSave == null) {
        debugPrint('Cloud launch sync: restoring remote backup.');
        await _restoreSnapshot(bestRemote.data, syncProgress: false);
      } else if (pendingChange != null &&
          pendingChange.isAfter(bestRemote.data.savedAtUtc)) {
        _schedulePendingUpload();
      } else if (bestRemote.data.savedAtUtc.isAfter(lastLocalSave)) {
        await _restoreSnapshot(bestRemote.data, syncProgress: false);
      } else if (pendingChange != null) {
        _schedulePendingUpload();
      }
      return CloudSaveResult.success;
    } on FormatException catch (error, stackTrace) {
      _logError('Cloud save is incompatible or invalid', error, stackTrace);
      return CloudSaveResult.invalidBackup;
    } catch (error, stackTrace) {
      _logError('Could not sync cloud progress', error, stackTrace);
      return CloudSaveResult.failed;
    } finally {
      _setStatus(CloudSaveStatus.idle);
    }
  }

  Future<CloudSaveResult> restoreFromCloud() async {
    if (!gateway.isSupported) return CloudSaveResult.unsupported;
    if (!await _ensureSignedIn()) return CloudSaveResult.notSignedIn;

    _setStatus(CloudSaveStatus.restoring);
    try {
      final bestRemote = _selectBestRemote(await _loadRemoteBackups());
      if (bestRemote == null) {
        return CloudSaveResult.notFound;
      }
      await _restoreSnapshot(bestRemote.data);
      return CloudSaveResult.success;
    } on FormatException catch (error, stackTrace) {
      _logError('Cloud save is incompatible or invalid', error, stackTrace);
      return CloudSaveResult.invalidBackup;
    } catch (error, stackTrace) {
      _logError('Could not restore progress from the cloud', error, stackTrace);
      return CloudSaveResult.failed;
    } finally {
      _setStatus(CloudSaveStatus.idle);
    }
  }

  Future<bool> _ensureSignedIn() async {
    if (session.isSignedIn) return true;
    try {
      await session.signIn();
      return session.isSignedIn;
    } catch (error, stackTrace) {
      _logError('Could not sign into game services', error, stackTrace);
      return false;
    }
  }

  Future<void> _uploadSnapshot(List<_RemoteBackup> backups) async {
    final savedAt = now().toUtc();
    final snapshot = store.createSnapshot(savedAt);
    await gateway.save(
      name: _nextAutoSaveName(backups),
      data: snapshot.encode(),
    );
    await store.markCloudSaveComplete(savedAt);
  }

  void _schedulePendingUpload() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(autoSaveDelay, () {
      unawaited(flushAutoSave());
    });
  }

  Future<void> _reconcilePendingChanges() async {
    final backups = await _loadRemoteBackups();
    final bestRemote = _selectBestRemote(backups);
    if (bestRemote == null) {
      if (store.lastCloudSaveAt == null && _initialRemoteAbsenceConfirmed) {
        await _uploadSnapshot(backups);
      }
      return;
    }

    final lastLocalSave = store.lastCloudSaveAt;
    final pendingChange = store.pendingChangeAt;
    if (lastLocalSave == null) {
      await _restoreSnapshot(bestRemote.data);
    } else if (pendingChange != null &&
        pendingChange.isAfter(bestRemote.data.savedAtUtc)) {
      await _uploadSnapshot(backups);
    } else if (bestRemote.data.savedAtUtc.isAfter(lastLocalSave)) {
      await _restoreSnapshot(bestRemote.data);
    } else {
      await _uploadSnapshot(backups);
    }
  }

  Future<List<_RemoteBackup>> _loadRemoteBackups() async {
    final backups = <_RemoteBackup>[];
    FormatException? formatError;
    final remoteData = await gateway.loadAll(names: _readableSaveNames);
    for (final entry in remoteData.entries) {
      try {
        backups
            .add(_RemoteBackup(entry.key, CloudSaveData.decode(entry.value)));
      } on FormatException catch (error) {
        formatError ??= error;
      }
    }
    if (backups.isEmpty && formatError != null) throw formatError;
    return backups;
  }

  Future<List<_RemoteBackup>> _loadRemoteBackupsWithRetry() async {
    for (var attempt = 0; attempt < launchLoadAttempts; attempt++) {
      try {
        final backups = await _loadRemoteBackups();
        if (backups.isNotEmpty || attempt == launchLoadAttempts - 1) {
          return backups;
        }
        debugPrint(
          'Cloud launch sync: Saved Games not ready '
          '(attempt ${attempt + 1}/$launchLoadAttempts).',
        );
      } catch (error) {
        if (attempt == launchLoadAttempts - 1) rethrow;
        debugPrint(
          'Cloud launch sync: retrying after $error '
          '(attempt ${attempt + 1}/$launchLoadAttempts).',
        );
      }
      await Future<void>.delayed(launchRetryDelay);
    }
    return const [];
  }

  _RemoteBackup? _selectBestRemote(List<_RemoteBackup> backups) {
    if (backups.isEmpty) return null;
    final nonEmpty = backups.where((backup) => !_isPristine(backup.data));
    final candidates = nonEmpty.isEmpty ? backups : nonEmpty.toList();
    return candidates.reduce(
      (best, candidate) => candidate.data.savedAtUtc.isAfter(
        best.data.savedAtUtc,
      )
          ? candidate
          : best,
    );
  }

  String _nextAutoSaveName(List<_RemoteBackup> backups) {
    for (final name in autoSaveNames) {
      if (!backups.any((backup) => backup.name == name)) return name;
    }
    final writable = backups
        .where((backup) => autoSaveNames.contains(backup.name))
        .toList()
      ..sort((a, b) => a.data.savedAtUtc.compareTo(b.data.savedAtUtc));
    return writable.first.name;
  }

  bool _isPristine(CloudSaveData data) {
    if (data.hints != 3 ||
        data.scores.values.any((value) => value != 0) ||
        data.correctAnswers.values.any((value) => value != 0)) {
      return false;
    }
    for (final level in data.levels.values.expand((levels) => levels)) {
      if (level['Guessed'] == true || level['BombUsed'] == true) return false;
      final answerLetters = level['AnswerLetters'];
      if (answerLetters is List &&
          answerLetters.any((letter) => letter != '' && letter != '#')) {
        return false;
      }
      final allLetters = level['AllLetters'];
      if (allLetters is List && allLetters.isNotEmpty) return false;
    }
    return true;
  }

  Future<void> _restoreSnapshot(
    CloudSaveData snapshot, {
    bool syncProgress = true,
  }) async {
    await store.restore(snapshot);
    await store.markCloudSaveComplete(snapshot.savedAtUtc);
    await store.clearPendingChanges();
    if (syncProgress) unawaited(_syncRestoredProgress());
  }

  Future<void> _syncRestoredProgress() async {
    try {
      await session.syncStoredProgress();
    } catch (error, stackTrace) {
      _logError('Could not backfill restored game progress', error, stackTrace);
    }
  }

  void _setStatus(CloudSaveStatus value) {
    _status = value;
    update();
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    debugPrint('$message: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _autoSaveTimer?.cancel();
      unawaited(flushAutoSave());
    }
  }

  @override
  void onClose() {
    _autoSaveTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}

class _RemoteBackup {
  final String name;
  final CloudSaveData data;

  const _RemoteBackup(this.name, this.data);
}
