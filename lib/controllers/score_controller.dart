import 'package:flag_app/repos/score_repo.dart';
import 'package:get/get.dart';

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

  Future<void> readAllScores() async {
    readFlagScore();
    readFlagsScore();
    readCapitalScore();
    readCountriesScore();
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
}
