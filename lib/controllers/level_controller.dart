import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/repos/level_repo.dart';
import 'package:get/get.dart';

import '../models/level_model.dart';

class LevelController extends GetxController implements GetxService {
  final LevelRepo levelRepo;

  LevelController({required this.levelRepo});

  List<LevelModel> _flagLevels = [];

  List<LevelModel> get getFlagLevels => _flagLevels;
  int _unlockedFlagLevels = 0;

  int get getUnlockedFlagLevels => _unlockedFlagLevels;

  List<LevelModel> _countriesLevels = [];

  List<LevelModel> get getCountriesLevels => _countriesLevels;
  int _unlockedCountryLevels = 0;

  int get getUnlockedCountryLevels => _unlockedCountryLevels;

  List<LevelModel> _cocLevels = [];

  List<LevelModel> get getCocLevels => _cocLevels;
  int _unlockedCOCLevels = 0;

  int get getUnlockedCOCLevels => _unlockedCOCLevels;

  void initUnlockedLevels() {
    if (Get.find<ShopController>().isLevelsUnlocked) {
      _unlockedFlagLevels = getLevelAmount(AppConstants.FLAGS);
      _unlockedCountryLevels = getLevelAmount(AppConstants.COUNTRIES);
      _unlockedCOCLevels = getLevelAmount(AppConstants.COC);
    } else {
      for (int i = 0; i < getLevelAmount(AppConstants.FLAGS); i++) {
        if (!isLevelUnlocked(i, AppConstants.FLAGS)) {
          _unlockedFlagLevels = i + 1;
        }
      }
      for (int i = 0; i < getLevelAmount(AppConstants.COUNTRIES); i++) {
        if (!isLevelUnlocked(i, AppConstants.COUNTRIES)) {
          _unlockedCountryLevels = i + 1;
        }
      }
      for (int i = 0; i < getLevelAmount(AppConstants.COC); i++) {
        if (!isLevelUnlocked(i, AppConstants.COC)) {
          _unlockedCOCLevels = i + 1;
        }
      }
    }
  }

  bool isNewLevelUnlocked(String playOption) {
    bool unlock = false;
    int amount = 0;

    for (int i = 0; i < getLevelAmount(playOption); i++) {
      if (!isLevelUnlocked(i, playOption)) {
        amount = i + 1;
      }
    }
    if (amount > getUnlockedLevelsByOption(playOption)) {
      _addToLevelUnlock(playOption);
      unlock = true;
      Get.snackbar(
          'Level unlocked'.tr, '${'Level'.tr} $amount ${'is unlocked'.tr}');
    }

    return unlock;
  }

  void _addToLevelUnlock(String playOption) {
    if (playOption == AppConstants.FLAGS) {
      _unlockedFlagLevels += 1;
    }
    if (playOption == AppConstants.COUNTRIES) {
      _unlockedCountryLevels += 1;
    }
    if (playOption == AppConstants.COC) {
      _unlockedCOCLevels += 1;
    }
  }

  int getUnlockedLevelsByOption(String playOption) {
    if (playOption == AppConstants.FLAGS) {
      return _unlockedFlagLevels;
    }
    if (playOption == AppConstants.COUNTRIES) {
      return _unlockedCountryLevels;
    }
    if (playOption == AppConstants.COC) {
      return _unlockedCOCLevels;
    }
    return 0;
  }

  int getLevelsToComplete(int index) {
    return (index * 10) - 13 + (index * 2);
  }

  bool isLevelUnlocked(int index, String playOption) {
    int levelsCompleted = getFinishedLevels(playOption);
    return getLevelsToComplete(index) >= levelsCompleted;
  }

  int getFinishedLevels(String playOption) {
    List<LevelModel> levels = getList(playOption)!;
    int finishedLevels = 0;
    for (var element in levels) {
      if (element.guessed!) {
        finishedLevels++;
      }
    }
    return finishedLevels;
  }

  int getLevelAmount(String playOption) {
    List<LevelModel> levels = getList(playOption)!;
    int amount = 0;
    for (var element in levels) {
      if (amount < element.level!) {
        amount = element.level!;
      }
    }
    return amount;
  }

  List<LevelModel> getLevelList(int level, String playOption) {
    List<LevelModel> levelListResult = [];
    for (var element in getList(playOption)!) {
      if (element.level == level) {
        levelListResult.add(element);
      }
    }
    return levelListResult;
  }

  int getFinishedLevelsForLevel(int level, String playOption) {
    List<LevelModel> levelList = getList(playOption)!;
    int finishedLevels = 0;
    for (var element in levelList) {
      if (element.level == level) {
        if (element.guessed!) {
          finishedLevels++;
        }
      }
    }
    return finishedLevels;
  }

  int getFinishedLevelsTotal(String playOption) {
    List<LevelModel> levelList = getList(playOption)!;
    int finishedLevels = 0;
    for (var element in levelList) {
      if (element.guessed!) {
        finishedLevels++;
      }
    }
    return finishedLevels;
  }

  int getAmountOfLevelsTotal(String playOption) {
    List<LevelModel> levelList = getList(playOption)!;
    return levelList.length;
  }

  int getAmountOfFieldsInLevels(int level, String playOption) {
    List<LevelModel> levelList = getList(playOption)!;
    int finishedLevels = 0;
    for (var element in levelList) {
      if (element.level == level) {
        finishedLevels++;
      }
    }
    return finishedLevels;
  }

  void guessed(String playOption, LevelModel country, bool state) {
    if (playOption == AppConstants.FLAGS) {
      for (var element in _flagLevels) {
        if (element == country) {
          element.guessed = true;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
    } else if (playOption == AppConstants.COUNTRIES) {
      for (var element in _countriesLevels) {
        if (element == country) {
          element.guessed = state;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
      print('country amount = ${_cocLevels.length}');
    } else if (playOption == AppConstants.COC) {
      for (var element in _cocLevels) {
        if (element == country) {
          element.guessed = state;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
      print('coc amount = ${_cocLevels.length}');
    }

    update();
  }

  void saveBombUsed(String playOption, LevelModel country, bool state) {
    if (playOption == AppConstants.FLAGS) {
      for (var element in _flagLevels) {
        if (element == country) {
          element.bombUsed = state;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
    } else if (playOption == AppConstants.COUNTRIES) {
      for (var element in _countriesLevels) {
        if (element == country) {
          element.bombUsed = state;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
      print('country amount = ${_cocLevels.length}');
    } else if (playOption == AppConstants.COC) {
      for (var element in _cocLevels) {
        if (element == country) {
          element.bombUsed = state;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
      print('coc amount = ${_cocLevels.length}');
    }
  }

  void saveAnswerLetters(
      String playOption, LevelModel country, List<List<String>> answerLetters) {
    if (playOption == AppConstants.FLAGS) {
      for (var element in _flagLevels) {
        if (element == country) {
          element.answerLetters = answerLetters;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
    } else if (playOption == AppConstants.COUNTRIES) {
      for (var element in _countriesLevels) {
        if (element == country) {
          element.answerLetters = answerLetters;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
      print('country amount = ${_cocLevels.length}');
    } else if (playOption == AppConstants.COC) {
      for (var element in _cocLevels) {
        if (element == country) {
          element.answerLetters = answerLetters;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
      print('coc amount = ${_cocLevels.length}');
    }
  }

  void saveAllLetters(
      String playOption, LevelModel country, List<String> allLetters) {
    if (playOption == AppConstants.FLAGS) {
      for (var element in _flagLevels) {
        if (element == country) {
          print('save allletters');
          element.allLetters = allLetters;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
    } else if (playOption == AppConstants.COUNTRIES) {
      for (var element in _countriesLevels) {
        if (element == country) {
          element.allLetters = allLetters;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
    } else if (playOption == AppConstants.COC) {
      for (var element in _cocLevels) {
        if (element == country) {
          element.allLetters = allLetters;
          //country.guessed = true;
          saveLevels(playOption);
        }
      }
    }
  }

  List<LevelModel>? getList(String playOption) {
    if (playOption == AppConstants.FLAGS) {
      return _flagLevels;
    } else if (playOption == AppConstants.COUNTRIES) {
      return _countriesLevels;
    } else if (playOption == AppConstants.COC) {
      return _cocLevels;
    }
    return null;
  }

  Future<void> readLevels({bool reset = false}) async {
    print('ReadLevels${Get.locale!}');
    _flagLevels = await levelRepo.readLevels(AppConstants.FLAGS, Get.locale!,
        reset: reset);
    _countriesLevels = await levelRepo
        .readLevels(AppConstants.COUNTRIES, Get.locale!, reset: reset);
    _cocLevels =
        await levelRepo.readLevels(AppConstants.COC, Get.locale!, reset: reset);
    update();
  }

  Future<bool> saveLevels(String option) async {
    List<LevelModel> levelModels = getList(option)!;
    return await levelRepo.saveLevels(levelModels, option);
  }
}
