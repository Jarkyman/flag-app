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

  Future<void> readAllScores() async {
    readFlagScore();
    readFlagsScore();
    readCapitalScore();
  }

  Future<void> readFlagScore() async {
    _flagScore = await scoreRepo.readFlagScore();
    print('############################################### Reading FLAG score');
  }

  Future<void> saveFlagScore(int score) async {
    _flagScore = score;
    scoreRepo.saveFlagScore(score);
    print('############################################### Saving FLAG score');
  }

  Future<void> readFlagsScore() async {
    _flagsScore = await scoreRepo.readFlagsScore();
    print(
        '############################################### Reading FLAGS score');
  }

  Future<void> saveFlagsScore(int score) async {
    _flagsScore = score;
    scoreRepo.saveFlagsScore(score);
    print('############################################### Saving FLAGS score');
  }

  Future<void> readCapitalScore() async {
    _capitalScore = await scoreRepo.readCapitalScore();
    print(
        '############################################### Reading CAPITAL score');
  }

  Future<void> saveCapitalScore(int score) async {
    _capitalScore = score;
    scoreRepo.saveCapitalScore(score);
    print(
        '############################################### Saving CAPITAL score');
  }
}
