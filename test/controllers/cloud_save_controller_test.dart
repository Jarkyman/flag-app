import 'dart:async';

import 'package:flag_app/cloud_save/cloud_save_gateway.dart';
import 'package:flag_app/cloud_save/cloud_save_session.dart';
import 'package:flag_app/cloud_save/cloud_save_store.dart';
import 'package:flag_app/cloud_save/models/cloud_save_data.dart';
import 'package:flag_app/controllers/cloud_save_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final savedAt = DateTime.utc(2026, 7, 12, 11, 45);

  test('does not touch local progress when no cloud backup exists', () async {
    final gateway = _FakeCloudSaveGateway(dataToLoad: null);
    final session = _FakeCloudSaveSession();
    final store = _FakeCloudSaveStore(snapshot: _snapshot(savedAt));
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: session,
      launchRetryDelay: Duration.zero,
      launchLoadAttempts: 1,
    );

    final result = await controller.restoreFromCloud();

    expect(result, CloudSaveResult.notFound);
    expect(store.restoredData, isNull);
    expect(session.syncCalls, 0);
  });

  test('restores valid data and then backfills native game services', () async {
    final backup = _snapshot(savedAt);
    final gateway = _FakeCloudSaveGateway(dataToLoad: backup.encode());
    final session = _FakeCloudSaveSession();
    final store = _FakeCloudSaveStore(snapshot: backup);
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: session,
      launchRetryDelay: Duration.zero,
      launchLoadAttempts: 1,
    );

    final result = await controller.restoreFromCloud();

    expect(result, CloudSaveResult.success);
    expect(store.restoredData?.hints, 9);
    expect(store.markedAt, savedAt);
    expect(session.syncCalls, 1);
  });

  test('rejects incompatible data without changing local progress', () async {
    final gateway = _FakeCloudSaveGateway(dataToLoad: '{"schemaVersion":99}');
    final session = _FakeCloudSaveSession();
    final store = _FakeCloudSaveStore(snapshot: _snapshot(savedAt));
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: session,
    );

    final result = await controller.restoreFromCloud();

    expect(result, CloudSaveResult.invalidBackup);
    expect(gateway.loadCalls, 1);
    expect(store.restoredData, isNull);
    expect(session.syncCalls, 0);
  });

  test('reports unsupported platforms before requesting sign-in', () async {
    final gateway = _FakeCloudSaveGateway(isSupported: false);
    final session = _FakeCloudSaveSession(isSignedIn: false);
    final controller = CloudSaveController(
      gateway: gateway,
      store: _FakeCloudSaveStore(snapshot: _snapshot(savedAt)),
      session: session,
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.unsupported);
    expect(session.signInCalls, 0);
  });

  test('debounces repeated progress changes into one automatic save', () async {
    final gateway = _FakeCloudSaveGateway();
    final store = _FakeCloudSaveStore(snapshot: _snapshot(savedAt));
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: _FakeCloudSaveSession(),
      now: () => savedAt,
      autoSaveDelay: const Duration(milliseconds: 10),
      launchRetryDelay: Duration.zero,
      launchLoadAttempts: 1,
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.notFound);
    controller.scheduleAutoSave();
    controller.scheduleAutoSave();
    controller.scheduleAutoSave();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(gateway.saveCalls, 1);
    expect(store.pendingChangeAt, isNull);
    expect(store.markedAt, savedAt);
  });

  test('launch sync restores an existing backup on a new device', () async {
    final backup = _snapshot(savedAt);
    final store = _FakeCloudSaveStore(snapshot: backup);
    final controller = CloudSaveController(
      gateway: _FakeCloudSaveGateway(dataToLoad: backup.encode()),
      store: store,
      session: _FakeCloudSaveSession(),
    );

    final result = await controller.syncOnLaunch();

    expect(result, CloudSaveResult.success);
    expect(store.restoredData?.savedAtUtc, savedAt);
    expect(store.markedAt, savedAt);
  });

  test('launch sync signs in before restoring the backup', () async {
    final backup = _snapshot(savedAt);
    final session = _FakeCloudSaveSession(isSignedIn: false);
    final store = _FakeCloudSaveStore(snapshot: backup);
    final controller = CloudSaveController(
      gateway: _FakeCloudSaveGateway(
        dataByName: {
          CloudSaveController.legacySaveName: backup.encode(),
        },
      ),
      store: store,
      session: session,
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.success);
    expect(session.signInCalls, 1);
    expect(store.restoredData?.savedAtUtc, savedAt);
  });

  test('launch sync retries until Saved Games exposes the backup', () async {
    final backup = _snapshot(savedAt);
    final gateway = _FakeCloudSaveGateway(
      loadResults: [
        const {},
        const {},
        {CloudSaveController.legacySaveName: backup.encode()},
      ],
    );
    final store = _FakeCloudSaveStore(snapshot: backup);
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: _FakeCloudSaveSession(),
      launchRetryDelay: Duration.zero,
      launchLoadAttempts: 3,
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.success);
    expect(gateway.loadCalls, 3);
    expect(store.restoredData?.savedAtUtc, savedAt);
  });

  test('manual restore retries until iCloud exposes the backup', () async {
    final backup = _snapshot(savedAt);
    final gateway = _FakeCloudSaveGateway(
      loadResults: [
        const {},
        {CloudSaveController.autoSaveNames.first: backup.encode()},
      ],
    );
    final store = _FakeCloudSaveStore(snapshot: backup);
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: _FakeCloudSaveSession(),
      launchRetryDelay: Duration.zero,
      launchLoadAttempts: 2,
    );

    expect(await controller.restoreFromCloud(), CloudSaveResult.success);
    expect(gateway.loadCalls, 2);
    expect(store.restoredData?.savedAtUtc, savedAt);
  });

  test('cloud discovery waits up to ten seconds by default', () {
    final controller = CloudSaveController(
      gateway: _FakeCloudSaveGateway(),
      store: _FakeCloudSaveStore(snapshot: _snapshot(savedAt)),
      session: _FakeCloudSaveSession(),
    );

    expect(controller.launchSyncTimeout, const Duration(seconds: 10));
  });

  test('launch sync never uploads an empty backup when the account has none',
      () async {
    final gateway = _FakeCloudSaveGateway();
    final controller = CloudSaveController(
      gateway: gateway,
      store: _FakeCloudSaveStore(snapshot: _pristineSnapshot(savedAt)),
      session: _FakeCloudSaveSession(),
      now: () => savedAt,
      autoSaveDelay: Duration.zero,
      launchRetryDelay: Duration.zero,
      launchLoadAttempts: 1,
    );

    final result = await controller.syncOnLaunch();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(result, CloudSaveResult.notFound);
    expect(gateway.saveCalls, 0);
  });

  test('launch sync uploads existing progress after confirming an empty cloud',
      () async {
    final gateway = _FakeCloudSaveGateway();
    final store = _FakeCloudSaveStore(snapshot: _snapshot(savedAt));
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: _FakeCloudSaveSession(),
      now: () => savedAt,
      autoSaveDelay: Duration.zero,
      launchRetryDelay: Duration.zero,
      launchLoadAttempts: 1,
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.notFound);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(gateway.saveCalls, 1);
    expect(store.pendingChangeAt, isNull);
    expect(store.markedAt, savedAt);
  });

  test('launch timeout continues offline without confirming an empty cloud',
      () async {
    final gateway = _FakeCloudSaveGateway(hangOnFirstLoad: true);
    final store = _FakeCloudSaveStore(snapshot: _snapshot(savedAt));
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: _FakeCloudSaveSession(),
      now: () => savedAt,
      autoSaveDelay: Duration.zero,
      launchRetryDelay: Duration.zero,
      launchSyncTimeout: const Duration(milliseconds: 10),
      launchLoadAttempts: 1,
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.failed);
    expect(store.restoredData, isNull);
    expect(gateway.saveCalls, 0);

    controller.scheduleAutoSave();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(gateway.saveCalls, 0);
    expect(store.pendingChangeAt, savedAt);
  });

  test('launch deadline confirms repeated successful empty cloud reads',
      () async {
    final gateway = _FakeCloudSaveGateway();
    final store = _FakeCloudSaveStore(snapshot: _snapshot(savedAt));
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: _FakeCloudSaveSession(),
      now: () => savedAt,
      autoSaveDelay: Duration.zero,
      launchRetryDelay: const Duration(milliseconds: 5),
      launchSyncTimeout: const Duration(milliseconds: 25),
      launchLoadAttempts: 100,
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.notFound);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(gateway.saveCalls, 1);
    final callsAtReturn = gateway.loadCalls;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(gateway.loadCalls, callsAtReturn);
  });

  test('restored local data does not wait for a hanging native backfill',
      () async {
    final backup = _snapshot(savedAt);
    final session = _FakeCloudSaveSession(hangOnSync: true);
    final store = _FakeCloudSaveStore(snapshot: backup);
    final controller = CloudSaveController(
      gateway: _FakeCloudSaveGateway(dataToLoad: backup.encode()),
      store: store,
      session: session,
    );

    final result = await controller.restoreFromCloud().timeout(
          const Duration(milliseconds: 100),
        );

    expect(result, CloudSaveResult.success);
    expect(store.restoredData?.savedAtUtc, savedAt);
    expect(session.syncCalls, 1);
  });

  test('a new device restores remote data even after a pending local change',
      () async {
    final remoteAt = savedAt.subtract(const Duration(hours: 1));
    final gateway = _FakeCloudSaveGateway(
      dataToLoad: _snapshot(remoteAt).encode(),
    );
    final session = _FakeCloudSaveSession(isSignedIn: false);
    final store = _FakeCloudSaveStore(snapshot: _snapshot(savedAt));
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: session,
      now: () => savedAt,
      autoSaveDelay: Duration.zero,
    );

    controller.scheduleAutoSave();
    await Future<void>.delayed(Duration.zero);
    expect(store.pendingChangeAt, savedAt);
    expect(gateway.saveCalls, 0);

    session.isSignedIn = true;
    expect(await controller.syncOnLaunch(), CloudSaveResult.success);
    expect(gateway.saveCalls, 0);
    expect(store.restoredData?.savedAtUtc, remoteAt);
  });

  test('the legacy backup slot is read-only', () async {
    final remoteAt = savedAt.subtract(const Duration(hours: 1));
    final nextAt = savedAt.add(const Duration(hours: 1));
    final gateway = _FakeCloudSaveGateway(
      dataByName: {
        CloudSaveController.legacySaveName: _snapshot(remoteAt).encode(),
      },
    );
    final store = _FakeCloudSaveStore(snapshot: _snapshot(nextAt));
    final controller = CloudSaveController(
      gateway: gateway,
      store: store,
      session: _FakeCloudSaveSession(),
      now: () => nextAt,
      autoSaveDelay: Duration.zero,
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.success);
    controller.scheduleAutoSave();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(gateway.saveCalls, 1);
    expect(gateway.savedName, isNot(CloudSaveController.legacySaveName));
    expect(CloudSaveController.autoSaveNames, contains(gateway.savedName));
  });

  test('a newer empty slot never wins over a real legacy backup', () async {
    final legacy = _snapshot(savedAt);
    final empty = _pristineSnapshot(savedAt.add(const Duration(days: 1)));
    final store = _FakeCloudSaveStore(snapshot: empty);
    final controller = CloudSaveController(
      gateway: _FakeCloudSaveGateway(
        dataByName: {
          CloudSaveController.legacySaveName: legacy.encode(),
          CloudSaveController.autoSaveNames.first: empty.encode(),
        },
      ),
      store: store,
      session: _FakeCloudSaveSession(),
    );

    expect(await controller.syncOnLaunch(), CloudSaveResult.success);
    expect(store.restoredData?.savedAtUtc, legacy.savedAtUtc);
    expect(store.restoredData?.hints, 9);
  });
}

CloudSaveData _snapshot(DateTime savedAt) {
  return CloudSaveData(
    savedAtUtc: savedAt,
    levels: const {},
    scores: const {},
    hints: 9,
    correctAnswers: const {},
  );
}

CloudSaveData _pristineSnapshot(DateTime savedAt) {
  return CloudSaveData(
    savedAtUtc: savedAt,
    levels: const {},
    scores: const {},
    hints: 3,
    correctAnswers: const {},
  );
}

class _FakeCloudSaveGateway implements CloudSaveGateway {
  @override
  final bool isSupported;
  final String? dataToLoad;
  final Map<String, String?> dataByName;
  final List<Map<String, String>> loadResults;
  final bool hangOnFirstLoad;

  _FakeCloudSaveGateway({
    this.isSupported = true,
    this.dataToLoad,
    this.dataByName = const {},
    this.loadResults = const [],
    this.hangOnFirstLoad = false,
  });

  String? savedName;
  int saveCalls = 0;
  int loadCalls = 0;

  @override
  Future<Map<String, String>> loadAll({required List<String> names}) async {
    if (hangOnFirstLoad && loadCalls == 0) {
      loadCalls++;
      return Completer<Map<String, String>>().future;
    }
    if (loadCalls < loadResults.length) {
      return loadResults[loadCalls++];
    }
    loadCalls++;
    final result = <String, String>{};
    for (final name in names) {
      final data = dataByName.containsKey(name) ? dataByName[name] : dataToLoad;
      if (data != null) result[name] = data;
    }
    return result;
  }

  @override
  Future<void> save({required String name, required String data}) async {
    saveCalls++;
    savedName = name;
  }
}

class _FakeCloudSaveSession implements CloudSaveSession {
  @override
  bool isSignedIn;

  final bool hangOnSync;

  _FakeCloudSaveSession({
    this.isSignedIn = true,
    this.hangOnSync = false,
  });

  int signInCalls = 0;
  int syncCalls = 0;

  @override
  Future<void> signIn() async {
    signInCalls++;
    isSignedIn = true;
  }

  @override
  Future<void> syncStoredProgress() {
    syncCalls++;
    if (hangOnSync) return Completer<void>().future;
    return Future.value();
  }
}

class _FakeCloudSaveStore implements CloudSaveStore {
  final CloudSaveData snapshot;

  _FakeCloudSaveStore({required this.snapshot});

  CloudSaveData? restoredData;
  DateTime? markedAt;
  DateTime? _pendingChangeAt;

  @override
  DateTime? get lastCloudSaveAt => markedAt;

  @override
  DateTime? get pendingChangeAt => _pendingChangeAt;

  @override
  CloudSaveData createSnapshot(DateTime savedAtUtc) => snapshot;

  @override
  Future<void> markCloudSaveComplete(DateTime savedAtUtc) async {
    markedAt = savedAtUtc;
    if (_pendingChangeAt == null || !_pendingChangeAt!.isAfter(savedAtUtc)) {
      _pendingChangeAt = null;
    }
  }

  @override
  Future<void> markPendingChanges(DateTime changedAtUtc) async {
    _pendingChangeAt = changedAtUtc;
  }

  @override
  Future<void> clearPendingChanges() async {
    _pendingChangeAt = null;
  }

  @override
  Future<void> restore(CloudSaveData data) async {
    restoredData = data;
  }
}
