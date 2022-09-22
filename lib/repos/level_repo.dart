import 'dart:convert';

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

  Future<String> readFlagLevels() async {
    final String response =
        await rootBundle.loadString('assets/json/flags.json');
    //print(response);
    return response;
    /*
    if (await sharedPreferences.getString(AppConstants.FLAGS) == null) {
      return list;
    }
    return await sharedPreferences.getString(AppConstants.FLAGS) as String;

     */
  }

  Future<bool> saveFlagLevels(List<LevelModel> flags) async {
    List<String> saveFlags = [];
    flags.forEach((element) {
      return saveFlags.add(jsonEncode(element));
    });

    return await sharedPreferences.setString(
        AppConstants.FLAGS, saveFlags.toString());
  }
}
