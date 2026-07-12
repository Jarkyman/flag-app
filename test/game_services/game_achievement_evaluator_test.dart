import 'dart:convert';
import 'dart:io';

import 'package:flag_app/game_services/game_achievement_evaluator.dart';
import 'package:flag_app/game_services/models/game_progress_snapshot.dart';
import 'package:flag_app/game_services/models/game_services_catalog.dart';
import 'package:flag_app/models/training_continent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameServicesCatalog catalog;

  setUpAll(() {
    catalog = GameServicesCatalog.fromJson(
      achievementJson: jsonDecode(
        File('game_services/achievements/catalog.json').readAsStringSync(),
      ) as Map<String, dynamic>,
      leaderboardJson: jsonDecode(
        File('game_services/leaderboards/catalog.json').readAsStringSync(),
      ) as Map<String, dynamic>,
    );
  });

  test('catalog contains the approved platform scope', () {
    expect(catalog.achievements, hasLength(23));
    expect(
      catalog.achievements.where((achievement) => achievement.hidden),
      hasLength(3),
    );
    expect(
      catalog.achievements.fold<int>(
        0,
        (sum, achievement) => sum + achievement.points,
      ),
      915,
    );
    expect(
      catalog.achievements
          .where((achievement) => achievement.hidden)
          .map((achievement) => achievement.steps),
      everyElement(194),
    );
    expect(catalog.leaderboards, hasLength(3));
    expect(
      catalog.leaderboards.map((leaderboard) => leaderboard.game).toSet(),
      TrainingScoreGame.values.toSet(),
    );
  });

  test('evaluates all 23 achievement rules from one snapshot', () {
    const evaluator = GameAchievementEvaluator();
    final snapshot = GameProgressSnapshot(
      correctAnswers: const {
        TrainingScoreGame.findFlag: 12,
        TrainingScoreGame.matchFlags: 10,
        TrainingScoreGame.whichCountry: 100,
      },
      records: {
        for (final game in TrainingScoreGame.values)
          game: {
            TrainingContinent.all: switch (game) {
              TrainingScoreGame.findFlag => 194,
              TrainingScoreGame.matchFlags => 20,
              TrainingScoreGame.whichCountry => 194,
            },
            TrainingContinent.africa: 10,
            TrainingContinent.asia: 11,
            TrainingContinent.europe: 12,
            TrainingContinent.northAmerica: 13,
            TrainingContinent.oceania: 14,
            TrainingContinent.southAmerica: 15,
          },
      },
      solvedFlagPuzzles: 194,
      solvedCountryPuzzles: 100,
      solvedCoatOfArmsPuzzles: 50,
      completedLevelCategories: 1,
      hasCompletedLevel: true,
    );
    final progress = {
      for (final achievement in catalog.achievements)
        achievement.key: evaluator.evaluate(achievement, snapshot).clampedSteps,
    };

    expect(progress, hasLength(23));
    expect(progress['achievement.first_correct'], 1);
    expect(progress['achievement.streak_5_any'], 5);
    expect(progress['achievement.streak_10_any'], 10);
    expect(progress['achievement.find_flag_10_correct'], 10);
    expect(progress['achievement.match_flags_10_correct'], 10);
    expect(progress['achievement.which_country_10_correct'], 10);
    expect(progress['achievement.training_100_correct'], 100);
    expect(progress['achievement.africa_streak_10'], 10);
    expect(progress['achievement.asia_streak_10'], 10);
    expect(progress['achievement.europe_streak_10'], 10);
    expect(progress['achievement.north_america_streak_10'], 10);
    expect(progress['achievement.oceania_streak_10'], 10);
    expect(progress['achievement.south_america_streak_10'], 10);
    expect(progress['achievement.world_tour'], 6);
    expect(progress['achievement.solve_10_puzzles'], 10);
    expect(progress['achievement.complete_first_level'], 1);
    expect(progress['achievement.complete_flag_levels'], 194);
    expect(progress['achievement.complete_country_levels'], 100);
    expect(progress['achievement.complete_coat_of_arms_levels'], 50);
    expect(progress['achievement.complete_all_levels'], 1);
    expect(progress['achievement.perfect_find_flag'], 194);
    expect(progress['achievement.perfect_match_flags'], 20);
    expect(progress['achievement.perfect_which_country'], 194);
  });

  test('world tour requires five on every separate continent', () {
    const evaluator = GameAchievementEvaluator();
    final definition = catalog.achievements.firstWhere(
      (achievement) => achievement.key == 'achievement.world_tour',
    );
    final snapshot = GameProgressSnapshot(
      correctAnswers: const {},
      records: {
        TrainingScoreGame.findFlag: {
          TrainingContinent.africa: 5,
          TrainingContinent.asia: 5,
          TrainingContinent.europe: 5,
          TrainingContinent.northAmerica: 5,
          TrainingContinent.oceania: 5,
          TrainingContinent.southAmerica: 4,
        },
      },
      solvedFlagPuzzles: 0,
      solvedCountryPuzzles: 0,
      solvedCoatOfArmsPuzzles: 0,
      completedLevelCategories: 0,
      hasCompletedLevel: false,
    );

    expect(evaluator.evaluate(definition, snapshot).currentSteps, 5);
  });
}
