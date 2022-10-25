import 'dart:convert';
import 'dart:ui';

import 'package:flag_app/models/level_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (sharedPreferences.getStringList(option) != null) {
      List<String> responsePref = sharedPreferences.getStringList(option)!;
      List<LevelModel> levelModelPref = [];
      for (var element in responsePref) {
        levelModelPref.add(LevelModel.fromJson(jsonDecode(element)));
      }
      for (int i = 0; i < levelModels.length; i++) {
        if (levelModelPref[i].guessed!) {
          levelModels[i].guessed = true;
        }
        if (!reset) {
          if (levelModelPref[i].allLetters != null ||
              levelModelPref[i].allLetters!.isNotEmpty) {
            levelModels[i].allLetters = levelModelPref[i].allLetters!;
          }
          if (levelModelPref[i].answerLetters != null ||
              levelModelPref[i].answerLetters!.isNotEmpty) {
            levelModels[i].answerLetters = levelModelPref[i].answerLetters!;
          }
          if (levelModelPref[i].bombUsed!) {
            levelModels[i].bombUsed = true;
          }
        }
      }
    }
    return levelModels;
  }

  Future<bool> saveLevels(List<LevelModel> levelList, String option) async {
    List<String> levelsListSave = [];
    for (var element in levelList) {
      levelsListSave.add(jsonEncode(element));
    }
    return await sharedPreferences.setStringList(option, levelsListSave);
  }
}
