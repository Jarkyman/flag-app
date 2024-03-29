import 'package:shared_preferences/shared_preferences.dart';

import '../helper/app_constants.dart';

class HintRepo {
  final SharedPreferences sharedPreferences;

  HintRepo({
    required this.sharedPreferences,
  });

  Future<int> readHints() async {
    int score = sharedPreferences.getInt(AppConstants.HINTS) ?? 3;
    return score;
  }

  Future<bool> saveHints(int hints) async {
    return await sharedPreferences.setInt(AppConstants.HINTS, hints);
  }
}
