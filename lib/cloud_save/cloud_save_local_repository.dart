import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/hint_controller.dart';
import '../controllers/level_controller.dart';
import '../controllers/score_controller.dart';
import '../game_services/game_progress_repo.dart';
import '../helper/app_constants.dart';
import '../models/level_model.dart';
import '../models/training_continent.dart';
import 'cloud_save_store.dart';
import 'models/cloud_save_data.dart';

class CloudSaveLocalRepository implements CloudSaveStore {
  static const _lastSaveAtKey = 'cloud-save-v1-last-saved-at';
  static const _pendingChangeAtKey = 'cloud-save-v1-pending-change-at';

  final SharedPreferences sharedPreferences;
  final LevelController levelController;
  final ScoreController scoreController;
  final HintController hintController;
  final GameProgressRepo progressRepo;

  const CloudSaveLocalRepository({
    required this.sharedPreferences,
    required this.levelController,
    required this.scoreController,
    required this.hintController,
    required this.progressRepo,
  });

  @override
  DateTime? get lastCloudSaveAt {
    final value = sharedPreferences.getString(_lastSaveAtKey);
    return value == null ? null : DateTime.tryParse(value)?.toUtc();
  }

  @override
  DateTime? get pendingChangeAt {
    final value = sharedPreferences.getString(_pendingChangeAtKey);
    return value == null ? null : DateTime.tryParse(value)?.toUtc();
  }

  @override
  CloudSaveData createSnapshot(DateTime savedAtUtc) {
    final levels = <String, List<Map<String, dynamic>>>{
      for (final option in _levelOptions)
        option: levelController
            .getList(option)!
            .map((level) => level.toJson())
            .toList(growable: false),
    };

    final scores = <String, int>{
      AppConstants.FLAG_SCORE: scoreController.getFlagScore,
      AppConstants.FLAGS_SCORE: scoreController.getFlagsScore,
      AppConstants.CAPITAL_SCORE: scoreController.getCapitalScore,
      AppConstants.COUNTRIES_SCORE: scoreController.getCountriesScore,
    };
    for (final game in TrainingScoreGame.values) {
      for (final continent in TrainingContinent.values) {
        if (continent == TrainingContinent.all) continue;
        scores[_continentScoreKey(game, continent)] =
            scoreController.getTrainingScore(game, continent);
      }
    }

    return CloudSaveData(
      savedAtUtc: savedAtUtc.toUtc(),
      levels: levels,
      scores: scores,
      hints: hintController.getHints,
      correctAnswers: {
        for (final game in TrainingScoreGame.values)
          game.name: progressRepo.correctAnswersFor(game),
      },
    );
  }

  @override
  Future<void> restore(CloudSaveData data) async {
    final restoredLevels = _validatedLevels(data.levels);
    final scores = _validatedScores(data.scores);
    final correctAnswers = _validatedCorrectAnswers(data.correctAnswers);
    if (data.hints < 0) {
      throw const FormatException('Cloud save contains invalid hints.');
    }

    for (final option in _levelOptions) {
      await levelController.levelRepo.saveLevels(
        restoredLevels[option]!,
        option,
      );
    }
    await levelController.readLevels();
    levelController.initUnlockedLevels();

    await Future.wait([
      scoreController.saveFlagScore(scores[AppConstants.FLAG_SCORE]!),
      scoreController.saveFlagsScore(scores[AppConstants.FLAGS_SCORE]!),
      scoreController.saveCapitalScore(scores[AppConstants.CAPITAL_SCORE]!),
      scoreController.saveCountriesScore(
        scores[AppConstants.COUNTRIES_SCORE]!,
      ),
      for (final game in TrainingScoreGame.values)
        for (final continent in TrainingContinent.values)
          if (continent != TrainingContinent.all)
            scoreController.saveTrainingScore(
              game,
              continent,
              scores[_continentScoreKey(game, continent)]!,
            ),
    ]);
    scoreController.update();

    await hintController.saveHints(data.hints);
    hintController.update();
    for (final game in TrainingScoreGame.values) {
      await progressRepo.saveCorrectAnswers(
        game,
        correctAnswers[game.name]!,
      );
    }
  }

  @override
  Future<void> markPendingChanges(DateTime changedAtUtc) {
    return sharedPreferences.setString(
      _pendingChangeAtKey,
      changedAtUtc.toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> markCloudSaveComplete(DateTime savedAtUtc) async {
    await sharedPreferences.setString(
      _lastSaveAtKey,
      savedAtUtc.toUtc().toIso8601String(),
    );
    final pending = pendingChangeAt;
    if (pending == null || !pending.isAfter(savedAtUtc)) {
      await clearPendingChanges();
    }
  }

  @override
  Future<void> clearPendingChanges() {
    return sharedPreferences.remove(_pendingChangeAtKey);
  }

  Map<String, List<LevelModel>> _validatedLevels(
    Map<String, List<Map<String, dynamic>>> rawLevels,
  ) {
    if (rawLevels.length != _levelOptions.length ||
        !_levelOptions.every(rawLevels.containsKey)) {
      throw const FormatException('Cloud save has missing level categories.');
    }

    return {
      for (final option in _levelOptions)
        option: _validateLevelList(option, rawLevels[option]!),
    };
  }

  List<LevelModel> _validateLevelList(
    String option,
    List<Map<String, dynamic>> rawLevels,
  ) {
    final localLevels = levelController.getList(option)!;
    if (rawLevels.length != localLevels.length) {
      throw FormatException(
        'Cloud save has ${rawLevels.length} $option entries; '
        'this app version expects ${localLevels.length}.',
      );
    }

    final restored = rawLevels.map(LevelModel.fromJson).toList(growable: false);
    for (var index = 0; index < restored.length; index++) {
      if (restored[index].level != localLevels[index].level) {
        throw FormatException('Cloud save has invalid $option ordering.');
      }
    }
    return restored;
  }

  Map<String, int> _validatedScores(Map<String, int> rawScores) {
    final expectedKeys = <String>{
      AppConstants.FLAG_SCORE,
      AppConstants.FLAGS_SCORE,
      AppConstants.CAPITAL_SCORE,
      AppConstants.COUNTRIES_SCORE,
      for (final game in TrainingScoreGame.values)
        for (final continent in TrainingContinent.values)
          if (continent != TrainingContinent.all)
            _continentScoreKey(game, continent),
    };
    if (rawScores.length != expectedKeys.length ||
        !expectedKeys.every(rawScores.containsKey) ||
        rawScores.values.any((score) => score < 0)) {
      throw const FormatException('Cloud save contains invalid scores.');
    }
    return rawScores;
  }

  Map<String, int> _validatedCorrectAnswers(Map<String, int> rawAnswers) {
    final expectedKeys = TrainingScoreGame.values.map((game) => game.name);
    if (rawAnswers.length != TrainingScoreGame.values.length ||
        !expectedKeys.every(rawAnswers.containsKey) ||
        rawAnswers.values.any((value) => value < 0)) {
      throw const FormatException(
        'Cloud save contains invalid correct-answer counters.',
      );
    }
    return rawAnswers;
  }

  static String _continentScoreKey(
    TrainingScoreGame game,
    TrainingContinent continent,
  ) {
    return '${game.storageKey}-${continent.id}';
  }
}

const _levelOptions = [
  AppConstants.FLAGS,
  AppConstants.COUNTRIES,
  AppConstants.COC,
];
