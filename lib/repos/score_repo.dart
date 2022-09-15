import 'package:shared_preferences/shared_preferences.dart';

import '../helper/app_constants.dart';

class ScoreRepo {
  final SharedPreferences sharedPreferences;

  ScoreRepo({
    required this.sharedPreferences,
  });

  Future<int> readFlagScore() async {
    String score =
        await sharedPreferences.getString(AppConstants.FLAG_SCORE) ?? '0';
    return int.parse(score);
  }

  Future<bool> saveFlagScore(String score) async {
    print('saved');
    return await sharedPreferences.setString(AppConstants.FLAG_SCORE, score);
  }

  Future<int> readFlagsScore() async {
    String score =
        await sharedPreferences.getString(AppConstants.FLAGS_SCORE) ?? '0';
    return int.parse(score);
  }

  Future<bool> saveFlagsScore(String score) async {
    print('saved');
    return await sharedPreferences.setString(AppConstants.FLAGS_SCORE, score);
  }
}
