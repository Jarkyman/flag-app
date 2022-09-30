import 'package:shared_preferences/shared_preferences.dart';

import '../helper/app_constants.dart';

class SettingsRepo {
  final SharedPreferences sharedPreferences;

  SettingsRepo({
    required this.sharedPreferences,
  });

  Future<String> languageSettingRead() async {
    String language =
        await sharedPreferences.getString(AppConstants.LANGUAGE) ?? 'en';
    return language;
  }

  Future<bool> languageSettingsSave(String language) async {
    return await sharedPreferences.setString(AppConstants.LANGUAGE, language);
  }

  Future<bool> soundSettingRead() async {
    bool sound = await sharedPreferences.getBool(AppConstants.SOUND) ?? true;
    return sound;
  }

  Future<bool> soundSettingsSave(bool sound) async {
    return await sharedPreferences.setBool(AppConstants.SOUND, sound);
  }
}
