import 'dart:convert';
import 'dart:ui';

import 'package:flag_app/models/level_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/app_constants.dart';

class LevelRepo {
  final SharedPreferences sharedPreferences;

  LevelRepo({
    required this.sharedPreferences,
  });

  Future<List<LevelModel>> readLevels(String option, Locale locale) async {
    final String response = await rootBundle.loadString(
        'assets/json/${locale.toString().split('_')[1].toLowerCase()}/${option.toLowerCase()}Levels.json');

    final list = json.decode(response) as List<dynamic>;
    List<LevelModel> levelModels = [];
    levelModels = list.map((e) => LevelModel.fromJson(e)).toList();

    if (await sharedPreferences.getStringList(option) != null) {
      List<String> responsePref =
          await sharedPreferences.getStringList(option)!;
      List<LevelModel> levelModelPref = [];
      responsePref.forEach((element) {
        levelModelPref.add(LevelModel.fromJson(jsonDecode(element)));
      });

      for (int i = 0; i < levelModels.length; i++) {
        if (levelModelPref[i].guessed!) {
          levelModels[i].guessed = true;
        }
      }
    }

    return levelModels;
  }

  Future<bool> saveLevels(List<LevelModel> flags, String option) async {
    List<String> saveFlags = [];
    flags.forEach((element) {
      return saveFlags.add(jsonEncode(element));
    });

    return await sharedPreferences.setStringList(option, saveFlags);
  }
}
