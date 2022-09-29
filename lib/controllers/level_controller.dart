import 'dart:convert';

import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/repos/level_repo.dart';
import 'package:flag_app/widget/popup/level_unlock_dialog.dart';
import 'package:get/get.dart';

import '../models/level_model.dart';

class LevelController extends GetxController implements GetxService {
  final LevelRepo levelRepo;

  LevelController({required this.levelRepo});

  List<LevelModel> _flagLevels = [];
  List<LevelModel> get getFlagLevels => _flagLevels;
  List<LevelModel> _countriesLevels = [];
  List<LevelModel> get getCountriesLevels => _countriesLevels;

  bool isLevelUnlocked(int index, String option) {
    int levelsToComplete = (index * 10) - 11;
    int levelsCompleted = getFinishedLevels(option);
    return levelsToComplete >= levelsCompleted;
  }

  int getFinishedLevel(String option) {
    List<LevelModel> levels = getList(option)!;
    int finishedLevel = 0;
    int levelAmount = getLevelAmount2(option);
    for (int i = 0; i < levelAmount; i++) {
      if (isLevelUnlocked(i, option)) {
        finishedLevel++;
      }
    }
    return finishedLevel;
  }

  int getFinishedLevels(String option) {
    List<LevelModel> levels = getList(option)!;
    int finishedLevels = 0;
    for (var element in levels) {
      if (element.guessed!) {
        finishedLevels++;
      }
    }
    return finishedLevels;
  }

  int getLevelAmount2(String option) {
    int amount = 0;
    getList(option)!.forEach((element) {
      if (amount < element.level!) {
        amount = element.level!;
      }
    });
    return amount;
  }

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

  int getFinishedLevelsForLevel(int level, List<LevelModel> levelList) {
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
          saveLevels(playOption);
        }
      });
    } else if (playOption == AppConstants.COUNTRIES) {
      _countriesLevels.forEach((element) {
        if (element == country) {
          element.guessed = true;
          //country.guessed = true;
          saveLevels(playOption);
        }
      });
    }

    update();
  }

  List<LevelModel>? getList(String playOption) {
    if (playOption == AppConstants.FLAGS) {
      return _flagLevels;
    } else if (playOption == AppConstants.COUNTRIES) {
      return _countriesLevels;
    }
    return null;
  }

  Future<void> readAllLevels() async {
    await readLevels();
  }

  Future<void> readLevels() async {
    _flagLevels = await levelRepo.readLevels(AppConstants.FLAGS);
    _countriesLevels = await levelRepo.readLevels(AppConstants.COUNTRIES);
    update();
  }

  Future<bool> saveLevels(String option) async {
    List<LevelModel> levelModels = getList(option)!;
    return await levelRepo.saveLevels(levelModels, option);
  }
}
