import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/repos/level_repo.dart';
import 'package:get/get.dart';

import '../models/level_model.dart';

class LevelController extends GetxController implements GetxService {
  final LevelRepo levelRepo;

  LevelController({required this.levelRepo});

  List<LevelModel> _flagLevels = [];

  List<LevelModel> get getFlagLevels => _flagLevels;
  List<LevelModel> _countriesLevels = [];

  List<LevelModel> get getCountriesLevels => _countriesLevels;

  List<LevelModel> _cocLevels = [];

  List<LevelModel> get getCocLevels => _cocLevels;

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

  List<LevelModel> getLevelList(int level, String playOption) {
    List<LevelModel> levelListResult = [];
    getList(playOption)!.forEach((element) {
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

  Future<void> readAllLevels() async {
    await readLevels();
  }

  Future<void> readLevels() async {
    print('ReadLevels' + Get.locale!.toString());
    _flagLevels = await levelRepo.readLevels(AppConstants.FLAGS, Get.locale!);
    _countriesLevels =
        await levelRepo.readLevels(AppConstants.COUNTRIES, Get.locale!);
    _cocLevels = await levelRepo.readLevels(AppConstants.COC, Get.locale!);
    update();
  }

  Future<bool> saveLevels(String option) async {
    List<LevelModel> levelModels = getList(option)!;
    return await levelRepo.saveLevels(levelModels, option);
  }

  /*
  REMOVE CODE BELOW
   */

  void guessedRemove(String playOption, LevelModel country) {
    if (playOption == AppConstants.FLAGS) {
      _flagLevels.forEach((element) {
        if (element == country) {
          element.guessed = false;
          //country.guessed = true;
          saveLevels(playOption);
        }
      });
    } else if (playOption == AppConstants.COUNTRIES) {
      _countriesLevels.forEach((element) {
        if (element == country) {
          element.guessed = false;
          //country.guessed = true;
          saveLevels(playOption);
        }
      });
    } else if (playOption == AppConstants.COC) {
      _cocLevels.forEach((element) {
        if (element == country) {
          element.guessed = false;
          //country.guessed = true;
          saveLevels(playOption);
        }
      });
    }

    update();
  }
}
