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

  Future<void> readAllScores() async {
    readFlagScore();
  }

  Future<void> readFlagScore() async {
    _flagScore = await scoreRepo.readFlagScore();
  }

  Future<void> saveFlagScore(String score) async {
    _flagScore = int.parse(score);
    scoreRepo.saveFlagScore(score);
  }

  Future<void> readsFlagScore() async {
    _flagsScore = await scoreRepo.readFlagsScore();
  }

  Future<void> saveFlagsScore(String score) async {
    _flagsScore = int.parse(score);
    scoreRepo.saveFlagsScore(score);
  }
}
