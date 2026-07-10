import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/models/training_continent.dart';
import 'package:flag_app/repos/score_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('keeps the legacy All record and continent records separate', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.FLAG_SCORE: 12,
      '${AppConstants.FLAG_SCORE}-africa': 4,
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = ScoreController(
      scoreRepo: ScoreRepo(sharedPreferences: preferences),
    );
    await controller.readAllScores();

    expect(
      controller.getTrainingScore(
        TrainingScoreGame.findFlag,
        TrainingContinent.all,
      ),
      12,
    );
    expect(
      controller.getTrainingScore(
        TrainingScoreGame.findFlag,
        TrainingContinent.africa,
      ),
      4,
    );

    await controller.saveTrainingScore(
      TrainingScoreGame.findFlag,
      TrainingContinent.africa,
      7,
    );

    expect(preferences.getInt(AppConstants.FLAG_SCORE), 12);
    expect(preferences.getInt('${AppConstants.FLAG_SCORE}-africa'), 7);
  });

  test('separates records by both game and continent', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = ScoreController(
      scoreRepo: ScoreRepo(sharedPreferences: preferences),
    );
    await controller.readAllScores();

    await controller.saveTrainingScore(
      TrainingScoreGame.findFlag,
      TrainingContinent.southAmerica,
      21,
    );
    await controller.saveTrainingScore(
      TrainingScoreGame.matchFlags,
      TrainingContinent.southAmerica,
      8,
    );
    await controller.saveTrainingScore(
      TrainingScoreGame.findFlag,
      TrainingContinent.europe,
      13,
    );

    expect(
      controller.getTrainingScore(
        TrainingScoreGame.findFlag,
        TrainingContinent.southAmerica,
      ),
      21,
    );
    expect(
      controller.getTrainingScore(
        TrainingScoreGame.matchFlags,
        TrainingContinent.southAmerica,
      ),
      8,
    );
    expect(
      controller.getTrainingScore(
        TrainingScoreGame.findFlag,
        TrainingContinent.europe,
      ),
      13,
    );
    expect(
      controller.getTrainingScore(
        TrainingScoreGame.whichCountry,
        TrainingContinent.southAmerica,
      ),
      0,
    );
  });

  test('saving All continues to use the original score key', () async {
    SharedPreferences.setMockInitialValues({AppConstants.COUNTRIES_SCORE: 5});
    final preferences = await SharedPreferences.getInstance();
    final controller = ScoreController(
      scoreRepo: ScoreRepo(sharedPreferences: preferences),
    );
    await controller.readAllScores();

    await controller.saveTrainingScore(
      TrainingScoreGame.whichCountry,
      TrainingContinent.all,
      9,
    );

    expect(preferences.getInt(AppConstants.COUNTRIES_SCORE), 9);
    expect(preferences.getInt('${AppConstants.COUNTRIES_SCORE}-all'), isNull);
  });
}
