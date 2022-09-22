import 'dart:convert';

import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/repos/level_repo.dart';
import 'package:get/get.dart';

import '../models/level_model.dart';

class LevelController extends GetxController implements GetxService {
  final LevelRepo levelRepo;

  LevelController({required this.levelRepo});

  List<LevelModel> _flagLevels = [];
  List<LevelModel> get getFlagLevels => _flagLevels;

  int getLevelAmount(List<LevelModel> levels) {
    int amount = 0;
    levels.forEach((element) {
      if (amount < element.level!) {
        amount = element.level!;
      }
    });
    return amount;
  }

  List<LevelModel> getLevelList(int level, List<LevelModel> levelList) {
    List<LevelModel> levelListResult = [];
    levelList.forEach((element) {
      if (element.level == level) {
        levelListResult.add(element);
      }
    });
    return levelListResult;
  }

  int getFinishedLevels(int level, List<LevelModel> levelList) {
    int finishedLevels = 0;
    levelList.forEach((element) {
      if (element.level == level) {
        if (element.guessed!) {
          finishedLevels++;
        }
      }
    });
    return finishedLevels;
  }

  int getUnFinishedLevels(int level, List<LevelModel> levelList) {
    int finishedLevels = 0;
    levelList.forEach((element) {
      if (element.level == level) {
        finishedLevels++;
      }
    });
    return finishedLevels;
  }

  void guessed(String playOption, LevelModel country) {
    if (playOption == AppConstants.FLAGS) {
      _flagLevels.forEach((element) {
        if (element == country) {
          element.guessed = true;
          //country.guessed = true;
        }
      });
    }
    update();
  }

  List<LevelModel>? getList(String playOption) {
    if (playOption == AppConstants.FLAGS) {
      return _flagLevels;
    }
    return null;
  }

  Future<void> readAllLevels() async {
    await readFlagLevels();
  }

  Future<void> readFlagLevels() async {
    final list = json.decode(await levelRepo.readFlagLevels()) as List<dynamic>;
    _flagLevels = [];
    _flagLevels = list.map((e) => LevelModel.fromJson(e)).toList();
    update();
  }

  Future<bool> saveFlagLevels(List<LevelModel> flags) async {
    return await levelRepo.saveFlagLevels(flags);
  }
}
