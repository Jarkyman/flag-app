import 'package:flag_app/repos/score_repo.dart';
import 'package:get/get.dart';

import '../models/training_continent.dart';

class ScoreController extends GetxController implements GetxService {
  final ScoreRepo scoreRepo;

  ScoreController({
    required this.scoreRepo,
  });

  int _flagScore = 0;

  int get getFlagScore => _flagScore;
  int _flagsScore = 0;

  int get getFlagsScore => _flagsScore;
  int _capitalScore = 0;

  int get getCapitalScore => _capitalScore;
  int _countriesScore = 0;

  int get getCountriesScore => _countriesScore;

  final Map<TrainingScoreGame, Map<String, int>> _continentScores = {};

  Future<void> readAllScores() async {
    await Future.wait([
      readFlagScore(),
      readFlagsScore(),
      readCapitalScore(),
      readCountriesScore(),
    ]);
  }

  Future<void> readFlagScore() async {
    _flagScore = await scoreRepo.readFlagScore();
  }

  Future<void> saveFlagScore(int score) async {
    _flagScore = score;
    scoreRepo.saveFlagScore(score);
  }

  Future<void> readFlagsScore() async {
    _flagsScore = await scoreRepo.readFlagsScore();
  }

  Future<void> saveFlagsScore(int score) async {
    _flagsScore = score;
    scoreRepo.saveFlagsScore(score);
  }

  Future<void> readCapitalScore() async {
    _capitalScore = await scoreRepo.readCapitalScore();
  }

  Future<void> saveCapitalScore(int score) async {
    _capitalScore = score;
    scoreRepo.saveCapitalScore(score);
  }

  Future<void> readCountriesScore() async {
    _countriesScore = await scoreRepo.readCountriesScore();
  }

  Future<void> saveCountriesScore(int score) async {
    _countriesScore = score;
    scoreRepo.saveCountriesScore(score);
  }

  int getTrainingScore(
    TrainingScoreGame game,
    TrainingContinent continent,
  ) {
    if (continent == TrainingContinent.all) {
      return switch (game) {
        TrainingScoreGame.findFlag => _flagScore,
        TrainingScoreGame.matchFlags => _flagsScore,
        TrainingScoreGame.whichCountry => _countriesScore,
      };
    }

    final gameScores = _continentScores.putIfAbsent(game, () => {});
    return gameScores.putIfAbsent(
      continent.id,
      () => scoreRepo.readTrainingScore(game.storageKey, continent.id),
    );
  }

  Future<void> saveTrainingScore(
    TrainingScoreGame game,
    TrainingContinent continent,
    int score,
  ) async {
    if (continent == TrainingContinent.all) {
      switch (game) {
        case TrainingScoreGame.findFlag:
          await saveFlagScore(score);
          return;
        case TrainingScoreGame.matchFlags:
          await saveFlagsScore(score);
          return;
        case TrainingScoreGame.whichCountry:
          await saveCountriesScore(score);
          return;
      }
    }

    _continentScores.putIfAbsent(game, () => {})[continent.id] = score;
    await scoreRepo.saveTrainingScore(game.storageKey, continent.id, score);
  }
}
