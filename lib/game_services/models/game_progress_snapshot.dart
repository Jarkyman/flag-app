import '../../models/training_continent.dart';

class GameProgressSnapshot {
  final Map<TrainingScoreGame, int> correctAnswers;
  final Map<TrainingScoreGame, Map<TrainingContinent, int>> records;
  final int solvedFlagPuzzles;
  final int solvedCountryPuzzles;
  final int solvedCoatOfArmsPuzzles;
  final int completedLevelCategories;
  final bool hasCompletedLevel;

  const GameProgressSnapshot({
    required this.correctAnswers,
    required this.records,
    required this.solvedFlagPuzzles,
    required this.solvedCountryPuzzles,
    required this.solvedCoatOfArmsPuzzles,
    required this.completedLevelCategories,
    required this.hasCompletedLevel,
  });

  int get totalCorrectAnswers =>
      correctAnswers.values.fold(0, (sum, value) => sum + value);

  int get solvedPuzzlesTotal =>
      solvedFlagPuzzles + solvedCountryPuzzles + solvedCoatOfArmsPuzzles;

  int recordFor(TrainingScoreGame game, TrainingContinent continent) {
    return records[game]?[continent] ?? 0;
  }

  int bestRecordForContinent(TrainingContinent continent) {
    return TrainingScoreGame.values
        .map((game) => recordFor(game, continent))
        .fold(0, (best, value) => value > best ? value : best);
  }

  int get bestTrainingRecord {
    var best = 0;
    for (final game in TrainingScoreGame.values) {
      for (final continent in TrainingContinent.values) {
        final value = recordFor(game, continent);
        if (value > best) best = value;
      }
    }
    return best;
  }
}
