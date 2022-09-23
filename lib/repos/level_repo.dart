import 'dart:convert';

import 'package:flag_app/models/level_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/app_constants.dart';

class LevelRepo {
  final SharedPreferences sharedPreferences;

  LevelRepo({
    required this.sharedPreferences,
  });

  Future<List<LevelModel>> readFlagLevels(String option) async {
    if (await sharedPreferences.getStringList(AppConstants.FLAGS) == null) {
      final String response = await rootBundle
          .loadString('assets/json/${option.toLowerCase()}.json');

      final list = json.decode(response) as List<dynamic>;
      List<LevelModel> levelModels = [];
      levelModels = list.map((e) => LevelModel.fromJson(e)).toList();

      saveFlagLevels(levelModels, option);
      return levelModels;
    } else {
      List<String> response = await sharedPreferences.getStringList(option)!;
      List<LevelModel> levelModels = [];

      response.forEach((element) =>
          levelModels.add(LevelModel.fromJson(jsonDecode(element))));
      return levelModels;
    }
  }

  Future<bool> saveFlagLevels(List<LevelModel> flags, String option) async {
    List<String> saveFlags = [];
    flags.forEach((element) {
      return saveFlags.add(jsonEncode(element));
    });

    return await sharedPreferences.setStringList(option, saveFlags);
  }
}
