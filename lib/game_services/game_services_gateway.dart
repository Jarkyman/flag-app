import 'models/game_achievement_progress.dart';
import 'models/game_leaderboard_definition.dart';
import 'models/game_leaderboard_score.dart';
import 'models/game_services_catalog.dart';
import 'models/remote_achievement_progress.dart';

enum GameNetworkPlatform { android, ios, unsupported }

abstract class GameServicesGateway {
  GameNetworkPlatform get platform;

  Stream<bool> get authenticationChanges;

  bool supportsCatalog(GameServicesCatalog catalog);

  Future<bool> signIn();

  Future<bool> isSignedIn();

  Future<List<RemoteAchievementProgress>> loadAchievements();

  Future<bool> reportAchievement({
    required GameAchievementProgress progress,
    required int remoteSteps,
    required bool remoteUnlocked,
  });

  Future<void> submitScore({
    required GameLeaderboardDefinition leaderboard,
    required int score,
  });

  Future<void> showAchievements();

  Future<void> showLeaderboards();

  Future<void> showLeaderboard({
    required GameLeaderboardDefinition leaderboard,
    required GameLeaderboardPlayerScope playerScope,
    required GameLeaderboardTimeScope timeScope,
  });

  Future<List<GameLeaderboardScore>> loadLeaderboardScores({
    required GameLeaderboardDefinition leaderboard,
    required GameLeaderboardPlayerScope playerScope,
    required GameLeaderboardTimeScope timeScope,
    required int maxResults,
  });
}
