import '../models/training_continent.dart';
import 'models/game_achievement_definition.dart';
import 'models/game_achievement_progress.dart';
import 'models/game_progress_snapshot.dart';

class GameAchievementEvaluator {
  const GameAchievementEvaluator();

  GameAchievementProgress evaluate(
    GameAchievementDefinition definition,
    GameProgressSnapshot snapshot,
  ) {
    final steps = switch (definition.key) {
      'achievement.first_correct' => snapshot.totalCorrectAnswers,
      'achievement.streak_5_any' => snapshot.bestTrainingRecord,
      'achievement.streak_10_any' => snapshot.bestTrainingRecord,
      'achievement.find_flag_10_correct' =>
        snapshot.correctAnswers[TrainingScoreGame.findFlag] ?? 0,
      'achievement.match_flags_10_correct' =>
        snapshot.correctAnswers[TrainingScoreGame.matchFlags] ?? 0,
      'achievement.which_country_10_correct' =>
        snapshot.correctAnswers[TrainingScoreGame.whichCountry] ?? 0,
      'achievement.training_100_correct' => snapshot.totalCorrectAnswers,
      'achievement.africa_streak_10' =>
        snapshot.bestRecordForContinent(TrainingContinent.africa),
      'achievement.asia_streak_10' =>
        snapshot.bestRecordForContinent(TrainingContinent.asia),
      'achievement.europe_streak_10' =>
        snapshot.bestRecordForContinent(TrainingContinent.europe),
      'achievement.north_america_streak_10' =>
        snapshot.bestRecordForContinent(TrainingContinent.northAmerica),
      'achievement.oceania_streak_10' =>
        snapshot.bestRecordForContinent(TrainingContinent.oceania),
      'achievement.south_america_streak_10' =>
        snapshot.bestRecordForContinent(TrainingContinent.southAmerica),
      'achievement.world_tour' => _worldTourContinents(snapshot),
      'achievement.solve_10_puzzles' => snapshot.solvedPuzzlesTotal,
      'achievement.complete_first_level' => snapshot.hasCompletedLevel ? 1 : 0,
      'achievement.complete_flag_levels' => snapshot.solvedFlagPuzzles,
      'achievement.complete_country_levels' => snapshot.solvedCountryPuzzles,
      'achievement.complete_coat_of_arms_levels' =>
        snapshot.solvedCoatOfArmsPuzzles,
      'achievement.complete_all_levels' => snapshot.completedLevelCategories,
      'achievement.perfect_find_flag' => snapshot.recordFor(
          TrainingScoreGame.findFlag,
          TrainingContinent.all,
        ),
      'achievement.perfect_match_flags' => snapshot.recordFor(
          TrainingScoreGame.matchFlags,
          TrainingContinent.all,
        ),
      'achievement.perfect_which_country' => snapshot.recordFor(
          TrainingScoreGame.whichCountry,
          TrainingContinent.all,
        ),
      final key => throw StateError('No evaluator for achievement: $key'),
    };

    return GameAchievementProgress(
      definition: definition,
      currentSteps: steps,
    );
  }

  int _worldTourContinents(GameProgressSnapshot snapshot) {
    return TrainingContinent.values
        .where((continent) => continent != TrainingContinent.all)
        .where((continent) => snapshot.bestRecordForContinent(continent) >= 5)
        .length;
  }
}
