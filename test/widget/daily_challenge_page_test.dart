import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flag_app/controllers/daily_challenge_controller.dart';
import 'package:flag_app/controllers/game_services_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/daily_challenge/daily_challenge_reminder.dart';
import 'package:flag_app/daily_challenge/daily_challenge_repository.dart';
import 'package:flag_app/daily_challenge/models/daily_challenge_progress.dart';
import 'package:flag_app/game_services/game_progress_repo.dart';
import 'package:flag_app/game_services/game_progress_snapshot_builder.dart';
import 'package:flag_app/game_services/game_services_gateway.dart';
import 'package:flag_app/game_services/models/game_achievement_progress.dart';
import 'package:flag_app/game_services/models/game_leaderboard_definition.dart';
import 'package:flag_app/game_services/models/game_leaderboard_score.dart';
import 'package:flag_app/game_services/models/game_services_catalog.dart';
import 'package:flag_app/game_services/models/remote_achievement_progress.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flag_app/repos/level_repo.dart';
import 'package:flag_app/repos/score_repo.dart';
import 'package:flag_app/pages/daily_challenge/daily_challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('starts the challenge without overflowing on a small screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final countries = (jsonDecode(
      File('assets/json/us/countries.json').readAsStringSync(),
    ) as List<dynamic>)
        .take(30)
        .map(
          (value) => CountryModel.fromJson(
            value as Map<String, dynamic>,
          ),
        )
        .toList();
    final controller = DailyChallengeController(
      repository: DailyChallengeRepository(
        sharedPreferences: preferences,
      ),
      reminder: const _Reminder(),
      countriesProvider: () => countries,
      submitScore: ({
        required int scoreMilliseconds,
        required String dayKey,
      }) async {},
      now: () => DateTime.utc(2026, 7, 27, 12),
      answerTransitionDuration: Duration.zero,
    );
    Get.put(controller);

    await tester.pumpWidget(
      const GetMaterialApp(home: DailyChallengePage()),
    );
    await tester.pump();

    expect(find.text('Start challenge'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Start challenge'));
    await tester.pump();

    expect(find.text('Identify the country'), findsOneWidget);
    expect(find.text('1/10'), findsOneWidget);
    expect(tester.takeException(), isNull);

    Get.delete<DailyChallengeController>(force: true);
    await tester.pump();
  });

  testWidgets(
      'completed challenge stays centered and shows friends leaderboard actions',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.padding = FakeViewPadding(
      bottom: 24 * tester.view.devicePixelRatio,
    );
    addTearDown(() => tester.view.resetPadding());
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final countries = (jsonDecode(
      File('assets/json/us/countries.json').readAsStringSync(),
    ) as List<dynamic>)
        .take(30)
        .map(
          (value) => CountryModel.fromJson(value as Map<String, dynamic>),
        )
        .toList();
    final repository = DailyChallengeRepository(
      sharedPreferences: preferences,
    );
    await repository.saveProgress(
      DailyChallengeProgress(
        dayKey: '2026-07-27',
        status: DailyChallengeStatus.completed,
        startedAtUtc: DateTime.utc(2026, 7, 27, 11, 59, 40),
        completedAtUtc: DateTime.utc(2026, 7, 27, 12),
        currentQuestionIndex: 10,
        wrongAnswers: 1,
        rawElapsedMilliseconds: 20000,
        scoreMilliseconds: 23000,
      ),
    );
    var resubmissions = 0;
    final dailyController = DailyChallengeController(
      repository: repository,
      reminder: const _Reminder(),
      countriesProvider: () => countries,
      submitScore: ({
        required int scoreMilliseconds,
        required String dayKey,
      }) async {
        resubmissions++;
      },
      now: () => DateTime.utc(2026, 7, 27, 12),
      answerTransitionDuration: Duration.zero,
    );
    final progressRepo = GameProgressRepo(sharedPreferences: preferences);
    final gameServices = GameServicesController(
      progressRepo: progressRepo,
      snapshotBuilder: GameProgressSnapshotBuilder(
        progressRepo: progressRepo,
        scoreController: ScoreController(
          scoreRepo: ScoreRepo(sharedPreferences: preferences),
        ),
        levelController: LevelController(
          levelRepo: LevelRepo(sharedPreferences: preferences),
        ),
      ),
      gateway: const _GameServicesGateway(),
      catalogLoader: () async => _dailyCatalog,
    );
    Get.put(dailyController);
    Get.put(gameServices);
    await gameServices.initialize();

    await tester.pumpWidget(
      const GetMaterialApp(home: DailyChallengePage()),
    );
    await tester.pump();

    final completedText = tester.widget<Text>(
      find.text('Challenge complete'),
    );
    expect(completedText.textAlign, TextAlign.center);
    final localBoundary = DateTime.utc(2026, 7, 28, 7).toLocal();
    final expectedClock = '${localBoundary.hour.toString().padLeft(2, '0')}:'
        '${localBoundary.minute.toString().padLeft(2, '0')}';
    expect(find.text('Next challenge $expectedClock'), findsOneWidget);
    expect(find.text('View leaderboard'), findsOneWidget);
    expect(find.text('Invite friends'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('View leaderboard'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(resubmissions, 1);
    expect(find.text('Friends today'), findsOneWidget);
    expect(find.text('Flag Friend'), findsOneWidget);
    expect(find.text('00:12.34'), findsOneWidget);
    expect(find.text('Open global leaderboard'), findsOneWidget);
    final sheetRect = tester.getRect(
      find.byKey(const ValueKey('daily-leaderboard-sheet-background')),
    );
    final screenBottom = tester.getRect(find.byType(Scaffold).first).bottom;
    expect(sheetRect.bottom, screenBottom);
    expect(tester.takeException(), isNull);
  });
}

const _dailyCatalog = GameServicesCatalog(
  achievements: [],
  leaderboards: [
    GameLeaderboardDefinition(
      key: 'leaderboard.daily_challenge',
      appleId: 'flags.leaderboard.daily_challenge',
      googleId: 'google-daily-challenge',
      game: null,
      appleScoreDivisor: 10,
    ),
  ],
);

class _GameServicesGateway implements GameServicesGateway {
  const _GameServicesGateway();

  @override
  GameNetworkPlatform get platform => GameNetworkPlatform.ios;

  @override
  Stream<bool> get authenticationChanges => const Stream.empty();

  @override
  bool supportsCatalog(GameServicesCatalog catalog) => true;

  @override
  Future<bool> signIn() async => true;

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
    return true;
  }

  @override
  Future<void> submitScore({
    required GameLeaderboardDefinition leaderboard,
    required int score,
  }) async {}

  @override
  Future<void> showAchievements() async {}

  @override
  Future<void> showLeaderboards() async {}

  @override
  Future<void> showLeaderboard({
    required GameLeaderboardDefinition leaderboard,
    required GameLeaderboardPlayerScope playerScope,
    required GameLeaderboardTimeScope timeScope,
  }) async {}

  @override
  Future<List<GameLeaderboardScore>> loadLeaderboardScores({
    required GameLeaderboardDefinition leaderboard,
    required GameLeaderboardPlayerScope playerScope,
    required GameLeaderboardTimeScope timeScope,
    required int maxResults,
  }) async {
    return const [
      GameLeaderboardScore(
        rank: 2,
        displayScore: '00:12.34',
        rawScore: 12340,
        playerName: 'Flag Friend',
        playerId: 'friend-1',
        playerAvatarBase64: null,
      ),
    ];
  }
}

class _Reminder implements DailyChallengeReminder {
  const _Reminder();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> enable({
    required String title,
    required String body,
  }) async {
    return true;
  }

  @override
  Future<void> disable() async {}
}
