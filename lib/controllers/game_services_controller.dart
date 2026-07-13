import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../game_services/game_achievement_evaluator.dart';
import '../game_services/game_progress_repo.dart';
import '../game_services/game_progress_snapshot_builder.dart';
import '../game_services/game_services_gateway.dart';
import '../game_services/models/game_services_catalog.dart';
import '../game_services/models/remote_achievement_progress.dart';
import '../models/training_continent.dart';
import '../cloud_save/cloud_save_session.dart';
import '../cloud_save/cloud_save_auto_save.dart';
import 'analytics_controller.dart';

enum GameServicesStatus {
  idle,
  unavailable,
  signingIn,
  connected,
  disconnected,
}

typedef GameServicesCatalogLoader = Future<GameServicesCatalog> Function();

class GameServicesController extends GetxController
    implements GetxService, CloudSaveSession {
  final GameProgressRepo progressRepo;
  final GameProgressSnapshotBuilder snapshotBuilder;
  final GameServicesGateway gateway;
  final GameAchievementEvaluator evaluator;
  final GameServicesCatalogLoader catalogLoader;
  final AnalyticsController? analytics;

  GameServicesController({
    required this.progressRepo,
    required this.snapshotBuilder,
    required this.gateway,
    this.evaluator = const GameAchievementEvaluator(),
    this.analytics,
    GameServicesCatalogLoader? catalogLoader,
  }) : catalogLoader = catalogLoader ?? GameServicesCatalog.load;

  GameServicesStatus _status = GameServicesStatus.idle;
  GameServicesStatus get status => _status;

  GameServicesCatalog? _catalog;
  GameServicesCatalog? get catalog => _catalog;

  String? _lastError;
  String? get lastError => _lastError;

  bool _initializationRequested = false;
  bool _isSignedIn = false;
  @override
  bool get isSignedIn => _isSignedIn;

  bool get isConfigured =>
      _catalog != null && gateway.supportsCatalog(_catalog!);

  bool get isBusy => _status == GameServicesStatus.signingIn;

  final Map<String, int> _lastReportedSteps = {};
  final Map<String, int> _lastSubmittedScores = {};
  final Map<String, RemoteAchievementProgress> _remoteAchievements = {};
  bool _hasLoadedRemoteAchievements = false;
  StreamSubscription<bool>? _authenticationSubscription;
  Future<void> _operationQueue = Future.value();

  Future<void> initialize() {
    if (_initializationRequested) return _operationQueue;
    _initializationRequested = true;
    return _enqueue(_initialize);
  }

  @override
  Future<void> signIn() {
    return _enqueue(() => _signInAndSync(source: 'manual'));
  }

  @override
  Future<void> syncStoredProgress() {
    return _enqueue(() async {
      if (!await _ensureSignedIn()) return;
      await _syncAchievements(force: true);
      await _syncLeaderboards(force: true);
      update();
    });
  }

  Future<void> recordTrainingCorrect({
    required TrainingScoreGame game,
    required TrainingContinent continent,
    required int streak,
  }) {
    return _enqueue(() async {
      await progressRepo.incrementCorrectAnswers(game);
      scheduleCloudAutoSave();
      await _syncAchievements(force: false);
      if (continent == TrainingContinent.all) {
        await _submitScoreForGame(game, streak, force: false);
      }
      update();
    });
  }

  Future<void> refreshLevelProgress() {
    return _enqueue(() => _syncAchievements(force: false));
  }

  Future<void> showAchievements() {
    return _enqueue(() async {
      if (!await _ensureSignedIn()) return;
      unawaited(
        analytics?.gameServicesOverlay(
              platform: gateway.platform.name,
              overlay: 'achievements',
            ) ??
            Future.value(),
      );
      await _guardPlatformCall(gateway.showAchievements);
    });
  }

  Future<void> showLeaderboards() {
    return _enqueue(() async {
      if (!await _ensureSignedIn()) return;
      unawaited(
        analytics?.gameServicesOverlay(
              platform: gateway.platform.name,
              overlay: 'leaderboards',
            ) ??
            Future.value(),
      );
      await _guardPlatformCall(gateway.showLeaderboards);
    });
  }

  Future<void> _initialize() async {
    try {
      _catalog = await catalogLoader();
      _lastError = null;
    } catch (error, stackTrace) {
      _status = GameServicesStatus.unavailable;
      _logError('Could not load game services catalog', error, stackTrace);
      update();
      return;
    }

    if (!isConfigured) {
      _status = GameServicesStatus.unavailable;
      await _syncAchievements(force: false);
      update();
      return;
    }

    _authenticationSubscription ??=
        gateway.authenticationChanges.listen(_handleAuthenticationChange);
    await _signInAndSync(source: 'launch');
  }

  Future<void> _signInAndSync({required String source}) async {
    _catalog ??= await catalogLoader();
    if (!isConfigured) {
      _status = GameServicesStatus.unavailable;
      update();
      return;
    }

    _status = GameServicesStatus.signingIn;
    _lastError = null;
    update();
    try {
      _isSignedIn = await gateway.signIn();
      _status = _isSignedIn
          ? GameServicesStatus.connected
          : GameServicesStatus.disconnected;
      if (_isSignedIn) {
        await _syncAchievements(force: true);
        await _syncLeaderboards(force: true);
      }
      unawaited(
        analytics?.gameServicesAuthentication(
              platform: gateway.platform.name,
              status: _isSignedIn ? 'connected' : 'disconnected',
              source: source,
            ) ??
            Future.value(),
      );
    } catch (error, stackTrace) {
      _isSignedIn = false;
      _status = GameServicesStatus.disconnected;
      _logError('Could not sign into game services', error, stackTrace);
      unawaited(
        analytics?.gameServicesAuthentication(
              platform: gateway.platform.name,
              status: 'error',
              source: source,
            ) ??
            Future.value(),
      );
    }
    update();
  }

  void _handleAuthenticationChange(bool signedIn) {
    _isSignedIn = signedIn;
    _status = signedIn
        ? GameServicesStatus.connected
        : GameServicesStatus.disconnected;
    update();
    if (signedIn) {
      _enqueue(() async {
        await _syncAchievements(force: true);
        await _syncLeaderboards(force: true);
      });
    }
  }

  Future<bool> _ensureSignedIn() async {
    if (_isSignedIn) return true;
    await _signInAndSync(source: 'overlay');
    return _isSignedIn;
  }

  Future<void> _syncAchievements({required bool force}) async {
    final catalog = _catalog;
    if (catalog == null) return;

    final snapshot = snapshotBuilder.build();
    final progressItems = catalog.achievements
        .map((definition) => evaluator.evaluate(definition, snapshot))
        .toList(growable: false);
    if (!_isSignedIn) return;

    if (force || !_hasLoadedRemoteAchievements) {
      await _loadRemoteAchievementProgress();
    }
    for (final progress in progressItems) {
      if (progress.clampedSteps <= 0) continue;
      if (!force &&
          _lastReportedSteps[progress.definition.key] ==
              progress.clampedSteps) {
        continue;
      }

      final remoteId = switch (gateway.platform) {
        GameNetworkPlatform.android => progress.definition.googleId,
        GameNetworkPlatform.ios => progress.definition.appleId,
        GameNetworkPlatform.unsupported => null,
      };
      if (remoteId == null || remoteId.isEmpty) continue;
      final remote = _remoteAchievements[remoteId];
      final fallbackSteps = gateway.platform == GameNetworkPlatform.android
          ? progressRepo.syncedGoogleSteps(progress.definition.key)
          : 0;
      final remoteSteps = remote?.completedSteps ?? fallbackSteps;

      try {
        await gateway.reportAchievement(
          progress: progress,
          remoteSteps: remoteSteps,
          remoteUnlocked: remote?.unlocked ?? false,
        );
        _lastReportedSteps[progress.definition.key] = progress.clampedSteps;
        if (gateway.platform == GameNetworkPlatform.android) {
          final syncedSteps = progress.clampedSteps > remoteSteps
              ? progress.clampedSteps
              : remoteSteps;
          await progressRepo.saveSyncedGoogleSteps(
            progress.definition.key,
            syncedSteps,
          );
          _remoteAchievements[remoteId] = RemoteAchievementProgress(
            id: remoteId,
            completedSteps: syncedSteps,
            totalSteps: progress.definition.steps,
            unlocked: progress.isUnlocked || (remote?.unlocked ?? false),
          );
        }
      } catch (error, stackTrace) {
        _logError(
          'Could not report ${progress.definition.key}',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> _loadRemoteAchievementProgress() async {
    try {
      final achievements = await gateway.loadAchievements();
      _remoteAchievements
        ..clear()
        ..addEntries(
          achievements
              .map((achievement) => MapEntry(achievement.id, achievement)),
        );
      _hasLoadedRemoteAchievements = true;
    } catch (error, stackTrace) {
      _logError('Could not load remote achievements', error, stackTrace);
    }
  }

  Future<void> _syncLeaderboards({required bool force}) async {
    final catalog = _catalog;
    if (catalog == null || !_isSignedIn) return;
    final snapshot = snapshotBuilder.build();
    for (final leaderboard in catalog.leaderboards) {
      final score = snapshot.recordFor(
        leaderboard.game,
        TrainingContinent.all,
      );
      await _submitLeaderboard(leaderboard.key, score, force: force);
    }
  }

  Future<void> _submitScoreForGame(
    TrainingScoreGame game,
    int score, {
    required bool force,
  }) async {
    final catalog = _catalog;
    if (catalog == null || !_isSignedIn) return;
    final leaderboard = catalog.leaderboards.firstWhereOrNull(
      (item) => item.game == game,
    );
    if (leaderboard == null) return;
    await _submitLeaderboard(leaderboard.key, score, force: force);
  }

  Future<void> _submitLeaderboard(
    String leaderboardKey,
    int score, {
    required bool force,
  }) async {
    if (score <= 0) return;
    final previousScore = _lastSubmittedScores[leaderboardKey] ?? 0;
    if (!force && score <= previousScore) return;
    final leaderboard = _catalog!.leaderboards.firstWhere(
      (item) => item.key == leaderboardKey,
    );
    try {
      await gateway.submitScore(leaderboard: leaderboard, score: score);
      _lastSubmittedScores[leaderboardKey] =
          score > previousScore ? score : previousScore;
    } catch (error, stackTrace) {
      _logError('Could not submit $leaderboardKey', error, stackTrace);
    }
  }

  Future<void> _guardPlatformCall(Future<void> Function() action) async {
    try {
      await action();
      _lastError = null;
    } catch (error, stackTrace) {
      _logError('Game services platform call failed', error, stackTrace);
    }
    update();
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final next = _operationQueue.then((_) => operation());
    _operationQueue = next.catchError((Object _, StackTrace __) {});
    return next;
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    _lastError = error.toString();
    debugPrint('$message: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  @override
  void onClose() {
    _authenticationSubscription?.cancel();
    super.onClose();
  }
}
