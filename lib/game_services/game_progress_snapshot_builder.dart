import '../controllers/level_controller.dart';
import '../controllers/score_controller.dart';
import '../helper/app_constants.dart';
import '../models/level_model.dart';
import '../models/training_continent.dart';
import 'game_progress_repo.dart';
import 'models/game_progress_snapshot.dart';

class GameProgressSnapshotBuilder {
  final GameProgressRepo progressRepo;
  final ScoreController scoreController;
  final LevelController levelController;

  const GameProgressSnapshotBuilder({
    required this.progressRepo,
    required this.scoreController,
    required this.levelController,
  });

  GameProgressSnapshot build() {
    final correctAnswers = {
      for (final game in TrainingScoreGame.values)
        game: progressRepo.correctAnswersFor(game),
    };
    final records = {
      for (final game in TrainingScoreGame.values)
        game: {
          for (final continent in TrainingContinent.values)
            continent: scoreController.getTrainingScore(game, continent),
        },
    };

    final flagLevels = levelController.getList(AppConstants.FLAGS) ?? const [];
    final countryLevels =
        levelController.getList(AppConstants.COUNTRIES) ?? const [];
    final coatOfArmsLevels =
        levelController.getList(AppConstants.COC) ?? const [];
    final levelCategories = [flagLevels, countryLevels, coatOfArmsLevels];

    return GameProgressSnapshot(
      correctAnswers: correctAnswers,
      records: records,
      solvedFlagPuzzles: _solvedCount(flagLevels),
      solvedCountryPuzzles: _solvedCount(countryLevels),
      solvedCoatOfArmsPuzzles: _solvedCount(coatOfArmsLevels),
      completedLevelCategories:
          levelCategories.where(_isCategoryComplete).length,
      hasCompletedLevel: levelCategories.any(_hasCompletedLevel),
    );
  }

  int _solvedCount(List<LevelModel> levels) {
    return levels.where((level) => level.guessed == true).length;
  }

  bool _isCategoryComplete(List<LevelModel> levels) {
    return levels.isNotEmpty && levels.every((level) => level.guessed == true);
  }

  bool _hasCompletedLevel(List<LevelModel> levels) {
    final levelsByNumber = <int, List<LevelModel>>{};
    for (final puzzle in levels) {
      final levelNumber = puzzle.level;
      if (levelNumber == null) continue;
      levelsByNumber.putIfAbsent(levelNumber, () => []).add(puzzle);
    }
    return levelsByNumber.values.any(
      (level) =>
          level.isNotEmpty && level.every((puzzle) => puzzle.guessed == true),
    );
  }
}
