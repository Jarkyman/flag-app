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
      everyElement(197),
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
              TrainingScoreGame.findFlag => 197,
              TrainingScoreGame.matchFlags => 20,
              TrainingScoreGame.whichCountry => 197,
            },
            TrainingContinent.africa: 10,
            TrainingContinent.asia: 11,
            TrainingContinent.europe: 12,
            TrainingContinent.northAmerica: 13,
            TrainingContinent.oceania: 14,
            TrainingContinent.southAmerica: 15,
          },
      },
      solvedFlagPuzzles: 197,
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
    expect(progress['achievement.complete_flag_levels'], 197);
    expect(progress['achievement.complete_country_levels'], 100);
    expect(progress['achievement.complete_coat_of_arms_levels'], 50);
    expect(progress['achievement.complete_all_levels'], 1);
    expect(progress['achievement.perfect_find_flag'], 197);
    expect(progress['achievement.perfect_match_flags'], 20);
    expect(progress['achievement.perfect_which_country'], 197);
  });

  test('all six complete achievements unlock at 197, not 196', () {
    const evaluator = GameAchievementEvaluator();
    const completeKeys = {
      'achievement.complete_flag_levels',
      'achievement.complete_country_levels',
      'achievement.complete_coat_of_arms_levels',
      'achievement.perfect_find_flag',
      'achievement.perfect_match_flags',
      'achievement.perfect_which_country',
    };
    final definitions = catalog.achievements
        .where((achievement) => completeKeys.contains(achievement.key))
        .toList(growable: false);

    expect(definitions, hasLength(6));
    for (final definition in definitions) {
      expect(
        evaluator.evaluate(definition, _countryPoolSnapshot(196)).isUnlocked,
        isFalse,
        reason: '${definition.key} must require all 197 countries.',
      );
      expect(
        evaluator.evaluate(definition, _countryPoolSnapshot(197)).isUnlocked,
        isTrue,
        reason: '${definition.key} must unlock at 197 countries.',
      );
    }
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

GameProgressSnapshot _countryPoolSnapshot(int progress) {
  return GameProgressSnapshot(
    correctAnswers: const {},
    records: {
      for (final game in TrainingScoreGame.values)
        game: {TrainingContinent.all: progress},
    },
    solvedFlagPuzzles: progress,
    solvedCountryPuzzles: progress,
    solvedCoatOfArmsPuzzles: progress,
    completedLevelCategories: 0,
    hasCompletedLevel: false,
  );
}
