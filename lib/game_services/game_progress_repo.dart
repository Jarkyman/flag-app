import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_continent.dart';

class GameProgressRepo {
  static const _prefix = 'game-services-v1';

  final SharedPreferences sharedPreferences;

  const GameProgressRepo({required this.sharedPreferences});

  int correctAnswersFor(TrainingScoreGame game) {
    return sharedPreferences.getInt(_correctAnswersKey(game)) ?? 0;
  }

  Future<void> incrementCorrectAnswers(TrainingScoreGame game) async {
    final nextValue = correctAnswersFor(game) + 1;
    await sharedPreferences.setInt(_correctAnswersKey(game), nextValue);
  }

  int syncedGoogleSteps(String achievementKey) {
    return sharedPreferences.getInt(_syncedGoogleStepsKey(achievementKey)) ?? 0;
  }

  Future<void> saveSyncedGoogleSteps(
    String achievementKey,
    int steps,
  ) {
    return sharedPreferences.setInt(
      _syncedGoogleStepsKey(achievementKey),
      steps,
    );
  }

  String _correctAnswersKey(TrainingScoreGame game) {
    return '$_prefix-correct-${game.name}';
  }

  String _syncedGoogleStepsKey(String achievementKey) {
    return '$_prefix-google-synced-$achievementKey';
  }
}
