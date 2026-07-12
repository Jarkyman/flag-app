import 'dart:async';

import 'package:flag_app/controllers/game_services_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/game_services/game_progress_repo.dart';
import 'package:flag_app/game_services/game_progress_snapshot_builder.dart';
import 'package:flag_app/game_services/game_services_gateway.dart';
import 'package:flag_app/game_services/models/game_achievement_definition.dart';
import 'package:flag_app/game_services/models/game_achievement_progress.dart';
import 'package:flag_app/game_services/models/game_leaderboard_definition.dart';
import 'package:flag_app/game_services/models/game_services_catalog.dart';
import 'package:flag_app/game_services/models/remote_achievement_progress.dart';
import 'package:flag_app/models/training_continent.dart';
import 'package:flag_app/repos/level_repo.dart';
import 'package:flag_app/repos/score_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tracks answers offline and submits only All scores', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progressRepo = GameProgressRepo(sharedPreferences: preferences);
    final scoreController = ScoreController(
      scoreRepo: ScoreRepo(sharedPreferences: preferences),
    );
    await scoreController.readAllScores();
    final levelController = LevelController(
      levelRepo: LevelRepo(sharedPreferences: preferences),
    );
    final gateway = _FakeGameServicesGateway();
    final controller = GameServicesController(
      progressRepo: progressRepo,
      snapshotBuilder: GameProgressSnapshotBuilder(
        progressRepo: progressRepo,
        scoreController: scoreController,
        levelController: levelController,
      ),
      gateway: gateway,
      catalogLoader: () async => _catalog,
    );

    await controller.initialize();
    await controller.recordTrainingCorrect(
      game: TrainingScoreGame.findFlag,
      continent: TrainingContinent.africa,
      streak: 40,
    );
    expect(gateway.submittedScores, isEmpty);

    await controller.recordTrainingCorrect(
      game: TrainingScoreGame.findFlag,
      continent: TrainingContinent.all,
      streak: 2,
    );

    expect(progressRepo.correctAnswersFor(TrainingScoreGame.findFlag), 2);
    expect(gateway.submittedScores, {'leaderboard.find_flag.all': 2});
    expect(
      gateway.reportedAchievements,
      contains('achievement.first_correct'),
    );
  });

  test('missing Google IDs disables platform calls without disabling tracking',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progressRepo = GameProgressRepo(sharedPreferences: preferences);
    final scoreController = ScoreController(
      scoreRepo: ScoreRepo(sharedPreferences: preferences),
    );
    await scoreController.readAllScores();
    final gateway = _FakeGameServicesGateway(
      platform: GameNetworkPlatform.android,
      configured: false,
    );
    final controller = GameServicesController(
      progressRepo: progressRepo,
      snapshotBuilder: GameProgressSnapshotBuilder(
        progressRepo: progressRepo,
        scoreController: scoreController,
        levelController: LevelController(
          levelRepo: LevelRepo(sharedPreferences: preferences),
        ),
      ),
      gateway: gateway,
      catalogLoader: () async => _catalog,
    );

    await controller.initialize();
    await controller.recordTrainingCorrect(
      game: TrainingScoreGame.whichCountry,
      continent: TrainingContinent.all,
      streak: 1,
    );

    expect(controller.status, GameServicesStatus.unavailable);
    expect(progressRepo.correctAnswersFor(TrainingScoreGame.whichCountry), 1);
    expect(gateway.signInCalls, 0);
    expect(gateway.reportedAchievements, isEmpty);
    expect(gateway.submittedScores, isEmpty);
  });
}

const _catalog = GameServicesCatalog(
  achievements: [
    GameAchievementDefinition(
      key: 'achievement.first_correct',
      appleId: 'flags.achievement.first_correct',
      googleId: 'google-first-correct',
      type: 'standard',
      steps: 1,
      points: 5,
      hidden: false,
    ),
  ],
  leaderboards: [
    GameLeaderboardDefinition(
      key: 'leaderboard.find_flag.all',
      appleId: 'flags.leaderboard.find_flag.all',
      googleId: 'google-find-flag',
      game: TrainingScoreGame.findFlag,
    ),
    GameLeaderboardDefinition(
      key: 'leaderboard.match_flags.all',
      appleId: 'flags.leaderboard.match_flags.all',
      googleId: 'google-match-flags',
      game: TrainingScoreGame.matchFlags,
    ),
    GameLeaderboardDefinition(
      key: 'leaderboard.which_country.all',
      appleId: 'flags.leaderboard.which_country.all',
      googleId: 'google-which-country',
      game: TrainingScoreGame.whichCountry,
    ),
  ],
);

class _FakeGameServicesGateway implements GameServicesGateway {
  @override
  final GameNetworkPlatform platform;
  final bool configured;

  _FakeGameServicesGateway({
    this.platform = GameNetworkPlatform.ios,
    this.configured = true,
  });

  final reportedAchievements = <String>[];
  final submittedScores = <String, int>{};
  int signInCalls = 0;

  @override
  Stream<bool> get authenticationChanges => const Stream.empty();

  @override
  bool supportsCatalog(GameServicesCatalog catalog) => configured;

  @override
  Future<bool> signIn() async {
    signInCalls++;
    return true;
  }

  @override
  Future<bool> isSignedIn() async => true;

  @override
  Future<List<RemoteAchievementProgress>> loadAchievements() async => const [];

  @override
  Future<bool> reportAchievement({
    required GameAchievementProgress progress,
    required int remoteSteps,
    required bool remoteUnlocked,
  }) async {
    reportedAchievements.add(progress.definition.key);
    return true;
  }

  @override
  Future<void> submitScore({
    required GameLeaderboardDefinition leaderboard,
    required int score,
  }) async {
    submittedScores[leaderboard.key] = score;
  }

  @override
  Future<void> showAchievements() async {}

  @override
  Future<void> showLeaderboards() async {}
}
