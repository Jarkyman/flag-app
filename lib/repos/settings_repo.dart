import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../helper/app_constants.dart';

class SettingsRepo {
  final SharedPreferences sharedPreferences;

  SettingsRepo({
    required this.sharedPreferences,
  });

  Future<String> languageSettingRead() async {
    String language = sharedPreferences.getString(AppConstants.LANGUAGE) ??
        (AppConstants.LOCALE_LIST.contains(Platform.localeName)
            ? Platform.localeName
            : 'en_US');
    return language;
  }

  Future<bool> languageSettingsSave(String language) async {
    return await sharedPreferences.setString(AppConstants.LANGUAGE, language);
  }

  Future<bool> soundSettingRead() async {
    bool sound = sharedPreferences.getBool(AppConstants.SOUND) ?? true;
    return sound;
  }

  Future<bool> soundSettingsSave(bool sound) async {
    return await sharedPreferences.setBool(AppConstants.SOUND, sound);
  }

  Future<bool> firstLaunchRead() async {
    bool first =
        sharedPreferences.getBool(AppConstants.FIRST_LAUNCH) ?? true;
    return first;
  }

  Future<bool> firstLaunchSave(bool first) async {
    return await sharedPreferences.setBool(AppConstants.FIRST_LAUNCH, first);
  }

  Future<bool> firstHelpGuessRead() async {
    bool first =
        sharedPreferences.getBool(AppConstants.FIRST_HELP_GUESS) ?? false;
    return first;
  }

  Future<void> firstHelpGuessSave(bool first) async {
    await sharedPreferences.setBool(AppConstants.FIRST_HELP_GUESS, first);
  }

  Future<bool> firstHelpTrainRead() async {
    bool first =
        sharedPreferences.getBool(AppConstants.FIRST_HELP_TRAIN) ?? false;
    return first;
  }

  Future<void> firstHelpTrainSave(bool first) async {
    await sharedPreferences.setBool(AppConstants.FIRST_HELP_TRAIN, first);
  }
}
