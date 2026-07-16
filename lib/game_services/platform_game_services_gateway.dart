import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

import 'game_services_gateway.dart';
import 'models/game_achievement_progress.dart';
import 'models/game_leaderboard_definition.dart';
import 'models/game_services_catalog.dart';
import 'models/remote_achievement_progress.dart';
import 'platform_game_auth_session.dart';

class PlatformGameServicesGateway implements GameServicesGateway {
  PlatformGameServicesGateway({PlatformGameAuthSession? authSession})
      : _authSession = authSession ?? PlatformGameAuthSession.instance;

  final PlatformGameAuthSession _authSession;

  @override
  GameNetworkPlatform get platform {
    if (kIsWeb) return GameNetworkPlatform.unsupported;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => GameNetworkPlatform.android,
      TargetPlatform.iOS => GameNetworkPlatform.ios,
      _ => GameNetworkPlatform.unsupported,
    };
  }

  @override
  Stream<bool> get authenticationChanges =>
      _authSession.authenticationChanges.distinct();

  @override
  bool supportsCatalog(GameServicesCatalog catalog) {
    return switch (platform) {
      GameNetworkPlatform.ios => catalog.achievements.every(
            (achievement) => achievement.appleId.isNotEmpty,
          ) &&
          catalog.leaderboards.every(
            (leaderboard) => leaderboard.appleId.isNotEmpty,
          ),
      GameNetworkPlatform.android => catalog.achievements.every(
            (achievement) => achievement.googleId?.isNotEmpty == true,
          ) &&
          catalog.leaderboards.every(
            (leaderboard) => leaderboard.googleId?.isNotEmpty == true,
          ),
      GameNetworkPlatform.unsupported => false,
    };
  }

  @override
  Future<bool> signIn() => _authSession.signIn();

  @override
  Future<bool> isSignedIn() async => _authSession.isSignedIn;

  @override
  Future<List<RemoteAchievementProgress>> loadAchievements() async {
    final achievements = await Achievements.loadAchievements(
      forceRefresh: true,
      ignoreImages: true,
    );
    return achievements
            ?.map(
              (achievement) => RemoteAchievementProgress(
                id: achievement.id,
                completedSteps: achievement.completedSteps,
                totalSteps: achievement.totalSteps,
                unlocked: achievement.unlocked,
              ),
            )
            .toList(growable: false) ??
        const [];
  }

  @override
  Future<bool> reportAchievement({
    required GameAchievementProgress progress,
    required int remoteSteps,
    required bool remoteUnlocked,
  }) async {
    final definition = progress.definition;
    if (progress.clampedSteps <= 0) return false;

    switch (platform) {
      case GameNetworkPlatform.ios:
        await Achievements.unlock(
          achievement: Achievement(
            iOSID: definition.appleId,
            percentComplete: progress.percentComplete,
            showsCompletionBanner: true,
          ),
        );
        return true;
      case GameNetworkPlatform.android:
        final googleId = definition.googleId;
        if (googleId == null || googleId.isEmpty) return false;
        if (!definition.isIncremental) {
          if (!progress.isUnlocked || remoteUnlocked) return false;
          await Achievements.unlock(
            achievement: Achievement(androidID: googleId),
          );
          return true;
        }
        final stepsToAdd = progress.clampedSteps - remoteSteps;
        if (stepsToAdd <= 0 || remoteUnlocked) return false;
        await Achievements.increment(
          achievement: Achievement(
            androidID: googleId,
            steps: stepsToAdd,
          ),
        );
        return true;
      case GameNetworkPlatform.unsupported:
        return false;
    }
  }

  @override
  Future<void> submitScore({
    required GameLeaderboardDefinition leaderboard,
    required int score,
  }) {
    return Leaderboards.submitScore(
      score: Score(
        iOSLeaderboardID: leaderboard.appleId,
        androidLeaderboardID: leaderboard.googleId,
        value: score,
      ),
    );
  }

  @override
  Future<void> showAchievements() => Achievements.showAchievements();

  @override
  Future<void> showLeaderboards() => Leaderboards.showLeaderboards();
}
