import 'package:shared_preferences/shared_preferences.dart';

import '../helper/app_constants.dart';

class ScoreRepo {
  final SharedPreferences sharedPreferences;

  ScoreRepo({
    required this.sharedPreferences,
  });

  Future<int> readFlagScore() async {
    int score = await sharedPreferences.getInt(AppConstants.FLAG_SCORE) ?? 0;
    return score;
  }

  Future<bool> saveFlagScore(int score) async {
    return await sharedPreferences.setInt(AppConstants.FLAG_SCORE, score);
  }

  Future<int> readFlagsScore() async {
    int score = await sharedPreferences.getInt(AppConstants.FLAGS_SCORE) ?? 0;
    return score;
  }

  Future<bool> saveFlagsScore(int score) async {
    return await sharedPreferences.setInt(AppConstants.FLAGS_SCORE, score);
  }

  Future<int> readCapitalScore() async {
    int score = await sharedPreferences.getInt(AppConstants.CAPITAL_SCORE) ?? 0;
    return score;
  }

  Future<bool> saveCapitalScore(int score) async {
    return await sharedPreferences.setInt(AppConstants.CAPITAL_SCORE, score);
  }
}
