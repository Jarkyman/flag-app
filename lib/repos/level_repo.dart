import 'dart:convert';
import 'dart:ui';

import 'package:flag_app/models/level_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/level_progress_merge.dart';

class LevelRepo {
  final SharedPreferences sharedPreferences;

  LevelRepo({
    required this.sharedPreferences,
  });

  Future<List<LevelModel>> readLevels(String option, Locale locale,
      {bool reset = false, bool hardReset = false}) async {
    final String response = await rootBundle.loadString(
        'assets/json/${locale.toString().split('_')[1].toLowerCase()}/${option.toLowerCase().removeAllWhitespace}Levels.json');
    final list = json.decode(response) as List<dynamic>;
    List<LevelModel> levelModels = [];
    levelModels = list.map((e) => LevelModel.fromJson(e)).toList();

    final responsePref = sharedPreferences.getStringList(option);
    if (responsePref == null) return levelModels;

    final savedLevels = responsePref
        .map((element) => LevelModel.fromJson(jsonDecode(element)))
        .toList(growable: false);
    return mergeSavedLevelProgress(
      templates: levelModels,
      savedLevels: savedLevels,
      restorePuzzleLetters: !reset,
    );
  }

  Future<bool> saveLevels(List<LevelModel> levelList, String option) async {
    List<String> levelsListSave = [];
    for (var element in levelList) {
      levelsListSave.add(jsonEncode(element));
    }
    return await sharedPreferences.setStringList(option, levelsListSave);
  }
}
