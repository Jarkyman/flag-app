import 'dart:math';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/controllers/settings_controller.dart';
import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/models/level_model.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flag_app/widget/tiles/empty_tile.dart';
import 'package:flag_app/widget/tiles/letter_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shake/shake.dart';

import '../../../controllers/country_controller.dart';
import '../../../controllers/hint_controller.dart';
import '../../../controllers/sound_controller.dart';
import '../../../helper/ad_helper.dart';
import '../../../helper/app_colors.dart';
import '../../../helper/app_constants.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/help_widgets.dart';
import '../../../helper/route_helper.dart';
import '../../../models/country_model.dart';
import '../../../widget/Top bar/hint_bar.dart';
import '../../../widget/ads/ad_banner_widget.dart';
import '../../../widget/info_column.dart';
import '../../../widget/popup/help_dialog.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});

  @override
  State<GuessPage> createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {
  late List<LevelModel> levels;
  late List<LevelModel> levelList;
  late LevelModel country;
  late List<List<String>> correctLettersList;
  late List<List<String>> lettersListAnswer;
  late List<List<String>> wrongLettersList;
  late List<String> allLetters;
  final int tilesPrRow = 9;
  bool bombUsed = false;
  bool shakeTile = false;
  bool removeCountry = false;

  Random random = Random();

  late ShakeDetector detector;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  late String argType;
  late int argLevel;
  late int argFlagIndex;

  @override
  void initState() {
    super.initState();
    argType = Get.arguments[0];
    argLevel = Get.arguments[1];
    argFlagIndex = Get.arguments[2];

    setInit();
    createBannerAd();
    detector = ShakeDetector.autoStart(
      onPhoneShake: (_) {
        setState(() {
          allLetters.shuffle();
        });
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    detector.stopListening();
    super.dispose();
  }

  void _loadInterstitialAd() {
    if (!Get.find<ShopController>().isAdsRemoved) {
      InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                Get.find<SoundController>().windSound();
                Get.back();
              },
            );

            setState(() {
              _interstitialAd = ad;
            });
          },
          onAdFailedToLoad: (err) {
            debugPrint('Failed to load an interstitial ad: ${err.message}');
          },
        ),
      );
    }
  }

  void createBannerAd() {
    if (!Get.find<ShopController>().isAdsRemoved) {
      BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('Failed to load a banner ad: ${err.message}');
            ad.dispose();
          },
        ),
      ).load();
    }
  }

  void setInit() {
    setState(() {
      _loadInterstitialAd();
      var levelController = Get.find<LevelController>();
      levels = levelController.getList(argType)!;
      levelList =
          levelController.getLevelList(argLevel, argType);
      country = levelList[argFlagIndex];
      correctLettersList = getCorrectLettersList(country.country!);
      if (country.answerLetters!.isEmpty) {
        lettersListAnswer = getLettersListEmpty(country.country!);
      } else {
        lettersListAnswer = country.answerLetters!;
      }
      if (country.allLetters!.isEmpty) {
        allLetters =
            generateRandomLetters(country.country!.toUpperCase().split(''));
        levelController.saveAllLetters(argType, country, allLetters);
      } else {
        allLetters = country.allLetters!;
      }
      bombUsed = false;
      if (country.bombUsed!) {
        useBombStart();
      }
      wrongLettersList = getLettersListEmpty(country.country!);
    });
  }

  void checkWin() {
    if (countryAnswer().removeAllWhitespace.toUpperCase() ==
        country.country!.removeAllWhitespace.toUpperCase()) {
      Get.find<SoundController>().completeSound();
      Get.find<LevelController>().guessed(argType, country, true);
      Get.find<LevelController>().isNewLevelUnlocked(argType);
    } else {
      bool done = true;
      for (int i = 0; i < lettersListAnswer.length; i++) {
        if (!lettersListAnswer[i].contains('') && done) {
          done = true;
        } else {
          done = false;
        }
      }
      if (done) {
        done = false;
        List<List<String>> wrongLetters = wrongLettersInAnswer(
            lettersListAnswer, correctLettersList, country.country!);
        if ((country.country!.length * 0.3).ceil() >=
            amountOfWrongLetters(wrongLetters)) {
          wrongLettersList = wrongLetters;
          const Duration(milliseconds: 500).delay(() {
            setState(() {
              wrongLettersList = getLettersListEmpty(country.country!);
            });
          });
        } else {
          shakeTile = true;
          Get.find<SoundController>().wrongSound();
          const Duration(milliseconds: 500).delay(() {
            setState(() {
              shakeTile = false;
            });
          });
        }
      }
    }
  }

  String countryAnswer() {
    int wordAmount = lettersListAnswer.length;
    List<String> words = [];
    String result = '';
    for (int i = 0; i < wordAmount; i++) {
      words.add(lettersListAnswer[i].join(''));
    }

    result = words.join(' ');

    List<String> temp = result.split('');
    for (int i = 0; i < temp.length; i++) {
      if (temp[i] == String.fromCharCode(8626) || temp[i] == '/') {
        temp.remove(temp[i]);
      }
    }

    result = temp.join('');

    return result;
  }

  int getWordAmount(String word) {
    return word.split(' ').length;
  }

  List<List<String>> getCorrectLettersList(String word) {
    List<String> words = word.toUpperCase().split(' ');
    List<List<String>> lettersList = [];
    for (var word in words) {
      List<String> wordSplit = word.split('');
      if (wordSplit.length > tilesPrRow) {
        List<String> temp = [];
        int maxLength = tilesPrRow - 2;
        if (wordSplit.contains('-') &&
            wordSplit.indexOf('-') + 1 <= tilesPrRow) {
          maxLength = wordSplit.indexOf('-') + 1;
        }
        for (int i = 0; i < wordSplit.length; i++) {
          if (temp.length == maxLength || temp.contains('-')) {
            if (!wordSplit.contains('-')) {
              temp.add(String.fromCharCode(8626));
            }
            lettersList.add(temp);
            temp = [];
            temp.add(wordSplit[i]);
            if (temp.length >= tilesPrRow) {
              maxLength += 2;
            }
          } else {
            temp.add(wordSplit[i]);
          }
        }
        if (temp.isNotEmpty) {
          if (temp.length <= 2) {
            if (lettersList.last.contains(String.fromCharCode(8626))) {
              lettersList.last.remove(String.fromCharCode(8626));
            }
            lettersList.last.addAll(temp);
          } else {
            lettersList.add(temp);
          }
        }
      } else {
        lettersList.add(word.split(''));
      }
    }

    if (lettersList.length > 1) {
      for (int i = 0; i < lettersList.length - 1; i++) {
        if ((lettersList[i].length + lettersList[i + 1].length) <=
            tilesPrRow - 1) {
          lettersList[i].add('/');
          lettersList[i].addAll(lettersList[i + 1]);
          lettersList.removeAt(i + 1);
        }
      }
    }

    return lettersList;
  }

  List<List<String>> getLettersListEmpty(String word) {
    List<List<String>> lettersList = getCorrectLettersList(word);

    for (var words in lettersList) {
      for (int i = 0; i < words.length; i++) {
        if (words[i] == '-' ||
            words[i] == String.fromCharCode(8626) ||
            words[i] == '/') {
        } else {
          words[i] = '';
        }
      }
    }

    return lettersList;
  }

  int getAmountOfTileRows(int amount) {
    int tileRows =
        (country.country!.toUpperCase().split('').length / amount).ceil();
    if (tileRows < 2) {
      tileRows = 2;
    }
    return tileRows;
  }

  List<String> generateRandomLetters(List<String> correctLetters) {
    List<String> result = correctLetters;
    int tileRows = getAmountOfTileRows(tilesPrRow);
    int maxLetters = tilesPrRow * tileRows;
    Random random = Random();

    for (int i = 0; i < result.length; i++) {
      if (result[i] == ' ' || result[i] == '-') {
        result.remove(result[i]);
      }
    }

    for (int i = result.length; i < maxLetters; i++) {
      int nextLetter = random.nextInt(25) + 65; //65 to 90
      result.add(String.fromCharCode(nextLetter).toUpperCase());
    }

    result.shuffle();
    result.shuffle();
    result.shuffle();

    return result;
  }

  int getAnswerLetterAmount() {
    int amount = 0;
    for (int i = 0; i < lettersListAnswer.length; i++) {
      amount += lettersListAnswer[i].length;
    }
    return amount;
  }

  int getInputLetterAmount() {
    int amount = 0;
    for (int i = 0; i < lettersListAnswer.length; i++) {
      for (int j = 0; j < lettersListAnswer[i].length; j++) {
        if (lettersListAnswer[i][j] == '' || lettersListAnswer[i][j] == ' ') {
        } else {
          amount++;
        }
      }
    }
    return amount;
  }

  bool isAnswerFull() {
    if (getAnswerLetterAmount() == getInputLetterAmount()) {
      return true;
    }
    return false;
  }

  List<List<String>> wrongLettersInAnswer(List<List<String>> checkerList,
      List<List<String>> answerList, String country) {
    List<List<String>> wrongLetters = getLettersListEmpty(country);

    for (int i = 0; i < answerList.length; i++) {
      for (int j = 0; j < answerList[i].length; j++) {
        if (checkerList[i][j] != answerList[i][j]) {
          wrongLetters[i][j] = checkerList[i][j];
        }
      }
    }
    return wrongLetters;
  }

  int amountOfWrongLetters(List<List<String>> wrongLetterList) {
    int result = 0;
    for (var words in wrongLetterList) {
      for (int i = 0; i < words.length; i++) {
        if (words[i] != '' &&
            words[i] != String.fromCharCode(8626) &&
            words[i] != '-' &&
            words[i] != '/') {
          result++;
        }
      }
    }
    return result;
  }

  void putLetterInBox(String letter, int index) {
    if (isAnswerFull()) {
    } else {
      bool isDone = false;
      for (int j = 0; j < lettersListAnswer.length; j++) {
        for (int i = 0; i < lettersListAnswer[j].length; i++) {
          setState(() {
            if (lettersListAnswer[j][i] == '') {
              lettersListAnswer[j][i] = letter;
              i = lettersListAnswer[j].length;
              isDone = true;
            }
          });
        }
        if (isDone) {
          j = lettersListAnswer.length;
        }
      }

      setState(() {
        allLetters[index] = '';
      });
      checkWin();
    }
    Get.find<LevelController>()
        .saveAnswerLetters(argType, country, lettersListAnswer);
  }

  void removeLetter(String letter, int index, int wordIndex) {
    if (letter != '-' && letter != String.fromCharCode(8626)) {
      for (int i = 0; i < allLetters.length; i++) {
        setState(() {
          if (allLetters[i] == '') {
            allLetters[i] = letter;
            i = allLetters.length;
          }
        });
      }

      for (int i = 0; i < lettersListAnswer[wordIndex].length; i++) {
        setState(() {
          if (lettersListAnswer[wordIndex][index] == letter) {
            lettersListAnswer[wordIndex][index] = '';
            i = lettersListAnswer[wordIndex].length;
          }
        });
      }
    }
  }

  String firstLetterUpperCase(String word) {
    List<String> wordList = word.split('');
    while (wordList[0] == ' ') {
      wordList.removeAt(0);
    }
    wordList[0] = wordList[0].toUpperCase();
    return wordList.join('');
  }

  void useFirstLetterHint(int hints) {
    if (Get.find<HintController>().getHints >= hints) {
      String letter = '';
      int index = 0;
      bool isDone = false;
      List<String> usedLetters = [];

      for (var use in lettersListAnswer) {
        usedLetters.addAll(use);
      }

      for (int i = 0; i < lettersListAnswer.length; i++) {
        for (int j = 0; j < lettersListAnswer[i].length; j++) {
          if (lettersListAnswer[i][j] == '') {
            letter = correctLettersList[i][j];
            isDone = true;
            j = lettersListAnswer[i].length;
          } else if (lettersListAnswer[i][j] != correctLettersList[i][j]) {
            for (int k = 0; k < allLetters.length; k++) {
              if (allLetters[k] == '') {
                removeLetter(lettersListAnswer[i][j], j, i);
                isDone = true;
                letter = correctLettersList[i][j];
                k = allLetters.length;
                j = lettersListAnswer[i].length;
              }
            }
          }
        }
        if (isDone) {
          i = lettersListAnswer.length;
        }
      }

      if (allLetters.contains(letter)) {
        for (int i = 0; i < allLetters.length; i++) {
          if (allLetters[i] == letter) {
            index = i;
          }
        }
        putLetterInBox(letter, index);
        Get.find<HintController>().useHint(hints);
      } else if (usedLetters.contains(letter)) {
        for (int i = 0; i < lettersListAnswer.length; i++) {
          if (lettersListAnswer[i].contains(letter)) {
            int letterIndex = lettersListAnswer[i].indexOf(letter);
            if (lettersListAnswer[i][letterIndex] !=
                correctLettersList[i][letterIndex]) {
              removeLetter(letter, letterIndex, i);
              for (int j = 0; j < allLetters.length; j++) {
                if (allLetters[j] == letter) {
                  index = j;
                }
              }
              putLetterInBox(letter, index);
              Get.find<HintController>().useHint(hints);
            }
          }
        }
      }
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  void useBombStart() {
    if (!bombUsed) {
      List<String> reducedLetters = [];
      List<String> tempAllList = [];
      List<String> correctList =
          country.country!.removeAllWhitespace.toUpperCase().split('');
      List<String> usedLetters = [];
      List<String> correctUsedLetters = [];

      for (var use in lettersListAnswer) {
        usedLetters.addAll(use);
      }
      usedLetters.removeWhere((element) => element == '');

      for (var use in usedLetters) {
        if (correctList.contains(use)) {
          correctList.remove(use);
        } else {
          correctUsedLetters.add(use);
        }
      }

      for (int i = 0; i < allLetters.length; i++) {
        tempAllList.add(allLetters[i]);
        reducedLetters.add('');
      }

      for (int j = 0; j < correctList.length; j++) {
        int index = tempAllList.indexOf(correctList[j]);
        tempAllList[index] = '';
        reducedLetters[index] = correctList[j];
      }

      correctUsedLetters.remove(String.fromCharCode(8626));
      correctUsedLetters.remove('-');

      for (int i = 0; i < usedLetters.length; i++) {
        bool tempDone = false;
        if (correctUsedLetters.contains(usedLetters[i])) {
          for (int j = 0; j < lettersListAnswer.length; j++) {
            if (lettersListAnswer[j].contains(usedLetters[i]) && !tempDone) {
              for (int k = 0; k < lettersListAnswer[j].length; k++) {
                if (lettersListAnswer[j][k] == usedLetters[i] && !tempDone) {
                  lettersListAnswer[j][k] = '';
                  tempDone = true;
                }
              }
            }
          }
        }
      }

      setState(() {
        allLetters = reducedLetters;
        bombUsed = true;
        Get.find<LevelController>()
            .saveBombUsed(argType, country, true);
        Get.find<LevelController>()
            .saveAllLetters(argType, country, allLetters);
      });
    }
  }

  void useBombHint(int hints) {
    if (Get.find<HintController>().getHints >= hints) {
      if (!bombUsed) {
        List<String> reducedLetters = [];
        List<String> tempAllList = [];
        List<String> correctList =
            country.country!.removeAllWhitespace.toUpperCase().split('');
        List<String> usedLetters = [];
        List<String> correctUsedLetters = [];

        for (var use in lettersListAnswer) {
          usedLetters.addAll(use);
        }
        usedLetters.removeWhere((element) => element == '');

        for (var use in usedLetters) {
          if (correctList.contains(use)) {
            correctList.remove(use);
          } else {
            correctUsedLetters.add(use);
          }
        }

        for (int i = 0; i < allLetters.length; i++) {
          tempAllList.add(allLetters[i]);
          reducedLetters.add('');
        }

        for (int j = 0; j < correctList.length; j++) {
          int index = tempAllList.indexOf(correctList[j]);
          tempAllList[index] = '';
          reducedLetters[index] = correctList[j];
        }

        correctUsedLetters.remove(String.fromCharCode(8626));
        correctUsedLetters.remove('-');

        for (int i = 0; i < usedLetters.length; i++) {
          bool tempDone = false;
          if (correctUsedLetters.contains(usedLetters[i])) {
            for (int j = 0; j < lettersListAnswer.length; j++) {
              if (lettersListAnswer[j].contains(usedLetters[i]) && !tempDone) {
                for (int k = 0; k < lettersListAnswer[j].length; k++) {
                  if (lettersListAnswer[j][k] == usedLetters[i] && !tempDone) {
                    lettersListAnswer[j][k] = '';
                    tempDone = true;
                  }
                }
              }
            }
          }
        }

        setState(() {
          allLetters = reducedLetters;
          bombUsed = true;
          Get.find<LevelController>()
              .saveBombUsed(argType, country, true);
          Get.find<LevelController>()
              .saveAllLetters(argType, country, allLetters);
        });
        Get.find<HintController>().useHint(hints);
      }
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  void useFinishHint(int hints) {
    if (Get.find<HintController>().getHints >= hints) {
      //setState(() {
      Get.find<LevelController>().guessed(argType, country, true);
      //});
      Get.find<HintController>().useHint(hints);
      Get.find<SoundController>().completeSound();
      Get.find<LevelController>().isNewLevelUnlocked(argType);
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  // Dialog open count - currently unused but kept for future use
  // ignore: unused_field
  int _countDialogOpen = 0;

  void openHelpDialog() {
    Future.delayed(const Duration(seconds: 1), () {
      //if (_countDialogOpen == 0) {
        if (!Get.find<SettingsController>().getFirstGuessHelp) {
          helpDialog(guessHelpWidgets());
          Get.find<SettingsController>().firstHelpGuessSave(true);
          _countDialogOpen++;
        }
      //}
    });
  }

  @override
  Widget build(BuildContext context) {
    //openHelpDialog();
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              int randomInt = random.nextInt(10);
              if (_interstitialAd != null &&
                  randomInt == 3 &&
                  !Get.find<ShopController>().isAdsRemoved) {
                _interstitialAd?.show();
              } else {
                Get.find<SoundController>().windSound();
                Get.back();
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          backgroundColor: AppColors.mainColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.question_mark_outlined),
              onPressed: () {
                helpDialog(guessHelpWidgets());
              },
            ),
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            int randomInt = random.nextInt(10);
            if (_interstitialAd != null &&
                randomInt == 3 &&
                !Get.find<ShopController>().isAdsRemoved) {
              _interstitialAd?.show();
            } else {
              Get.find<SoundController>().windSound();
              Get.back();
            }
          },
          child: SwipeDetector(
            onSwipeRight: (value) {
              int nextPageIndex = argFlagIndex;
              nextPageIndex = argFlagIndex - 1;

              if (nextPageIndex > -1) {
                Get.find<SoundController>().windSound();
                setState(() {
                  argFlagIndex = nextPageIndex;
                  setInit();
                });
              }
            },
            onSwipeLeft: (value) {
              int nextPageIndex = argFlagIndex;
              nextPageIndex = argFlagIndex + 1;
              if (nextPageIndex < levelList.length) {
                Get.find<SoundController>().windSound();
                setState(() {
                  argFlagIndex = nextPageIndex;
                  setInit();
                });
              }
            },
            child: BackgroundImage(
              child: GetBuilder<LevelController>(
                builder: (levelController) {
                  debugPrint('Type = $argType');
                  debugPrint('Level = $argLevel');
                  debugPrint('Flag index = $argFlagIndex');

                  String countryCodeImg =
                      Get.find<CountryController>().getCountryCode(country.country!).toLowerCase();
                  String countryCodeImgCountry =
                      Get.find<CountryController>().getCountryCode(country.country!).toLowerCase();
                  if (AppConstants.FULL_FLAG_LIST.contains(countryCodeImg) &&
                      country.guessed! &&
                      argType == AppConstants.FLAGS) {
                    countryCodeImg =
                        '${Get.find<CountryController>().getCountryCode(country.country!).toLowerCase()}-full';
                  }
                  if (argType == AppConstants.COUNTRIES) {
                    countryCodeImg =
                        '${Get.find<CountryController>().getCountryCode(country.country!).toLowerCase()}-full';
                  }
                  if (AppConstants.FULL_COC_LIST.contains(countryCodeImg) &&
                      country.guessed! &&
                      argType == AppConstants.COC) {
                    countryCodeImg =
                        '${Get.find<CountryController>().getCountryCode(country.country!).toLowerCase()}-full';
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      country.guessed!
                          ? Container(
                              height: Dimensions.height20 * 2,
                            )
                          : HintBar(
                              tapHintOne: () {
                                useFinishHint(5);
                              },
                              iconOne: const Icon(
                                Icons.check,
                                color: AppColors.mainColor,
                              ),
                              hintPriceOne: '5',
                              tapHintTwo: () {
                                if (!bombUsed) {
                                  useBombHint(2);
                                }
                              },
                              iconTwo: ImageIcon(
                                const AssetImage('assets/icon/bomb.png'),
                                color: AppColors.mainColor,
                                size: Dimensions.iconSize24,
                              ),
                              hintPriceTwo: '2',
                              disableTwo: bombUsed,
                              tapHintThree: () {
                                useFirstLetterHint(1);
                              },
                              iconThree: ImageIcon(
                                const AssetImage('assets/icon/a.png'),
                                color: AppColors.mainColor,
                                size: Dimensions.iconSize24,
                              ),
                              hintPriceThree: '1',
                            ),
                      SizedBox(height: Dimensions.height10),
                      argType == AppConstants.COUNTRIES
                          ? SizedBox(
                              height: Dimensions.height20 * 10,
                              child: Stack(
                                children: [
                                  Hero(
                                    tag:
                                        countryCodeImgCountry.toLowerCase(),
                                    /*flightShuttleBuilder:
                                        ((flightContext, animation, _, __, ___) {
                                      animation.addStatusListener((status) {
                                        if (status == AnimationStatus.completed) {
                                          setState(() {
                                            removeCountry = true;
                                            print('hero done');
                                          });
                                        } else if (status ==
                                            AnimationStatus.dismissed) {
                                          setState(() {
                                            removeCountry = false;
                                            print('hero dismiss');
                                          });
                                        }
                                      });
                                      return Container();
                                    }),*/
                                    child: Center(
                                      child: Image.asset(
                                          'assets/image/${argType.toString().toLowerCase()}/${countryCodeImgCountry.toLowerCase()}.png',
                                          fit: BoxFit.contain,
                                          color: Colors.transparent),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      height: Dimensions.height20 * 10,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: Dimensions.height20),
                                      decoration: const BoxDecoration(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius15),
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius15),
                                          child: Image.asset(
                                            'assets/image/${argType.toString().toLowerCase()}/${countryCodeImg.toLowerCase()}.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Hero(
                              tag: countryCodeImg.toLowerCase(),
                              child: Container(
                                height: Dimensions.height20 * 10,
                                margin: EdgeInsets.symmetric(
                                    horizontal: Dimensions.height20),
                                decoration: const BoxDecoration(),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radius10),
                                    child: Image.asset(
                                      'assets/image/${argType.toString().toLowerCase()}/${countryCodeImg.toLowerCase()}.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      country.guessed!
                          ? Expanded(
                              child: guessTiles(correctLettersList, true),
                            )
                          : Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  guessTiles(lettersListAnswer, false),
                                  tilesAtBottom(),
                                ],
                              ),
                            ),
                      finishInfoBox(
                          Get.find<CountryController>()
                              .getCountryByName(country.country!),
                          !country.guessed!),
                    ],
                  );
                },
              ),
            ),
          ),
        ));
  }

  Widget finishInfoBox(CountryModel country, bool isGuessed) {
    return GetBuilder<ShopController>(
      builder: (shopController) {
        return Stack(
          alignment: Alignment.center,
          children: [
            !isGuessed
                ? Container(
                    height: country.countryCode!.toLowerCase() == 'vc'
                        ? Dimensions.screenHeight / 4.5
                        : Dimensions.screenHeight / 3.4,
                    decoration: BoxDecoration(
                      color: AppColors.mainColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radius30),
                        topRight: Radius.circular(Dimensions.radius30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: Dimensions.width20,
                          right: Dimensions.width20,
                          top: Dimensions.width20),
                      child: Column(
                        children: [
                          InfoColumn(
                            header: 'Continent'.tr,
                            info: firstLetterUpperCase(
                                Get.find<CountryContinentController>()
                                    .getContinentNameByCountryModel(country)),
                          ),
                          InfoColumn(
                            header: 'Country'.tr,
                            info: country.countryName!.toLowerCase() ==
                                    'Côte dIvoire'.toLowerCase()
                                ? 'Côte d\'Ivoire'
                                : firstLetterUpperCase(country.countryName!),
                          ),
                          InfoColumn(
                            header: 'Capital'.tr,
                            info: firstLetterUpperCase(country.capital!),
                          ),
                          InfoColumn(
                            header: 'Currency'.tr,
                            info:
                                '${firstLetterUpperCase(country.currencyName!)} (${country.currencyCode!})',
                            divider: false,
                          ),
                        ],
                      ),
                    ),
                  )
                : _bannerAd != null &&
                        getAmountOfTileRows(tilesPrRow) < 4 &&
                        !shopController.isAdsRemoved
                    ? Container(
                        height: _bannerAd!.size.height.toDouble(),
                      )
                    : Container(),
            (_bannerAd != null &&
                    getAmountOfTileRows(tilesPrRow) < 4 &&
                    !shopController.isAdsRemoved)
                ? Positioned(
                    bottom: 0,
                    child: AdBannerWidget(bannerAd: _bannerAd),
                  )
                : Container(
                    height: Dimensions.height20,
                  ),
          ],
        );
      },
    );
  }

  Padding tilesAtBottom() {
    return Padding(
      padding: EdgeInsets.all(Dimensions.width10),
      child: Column(
          children:
              List.generate(getAmountOfTileRows(tilesPrRow), (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(tilesPrRow, (tileIndex) {
            int index = tileIndex + (tilesPrRow * rowIndex);

            return Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height10 / 2),
              child: allLetters[index] == ''
                  ? const EmptyTile()
                  : GestureDetector(
                      onTap: () {
                        putLetterInBox(allLetters[index], index);
                      },
                      child: LetterTile(letter: allLetters[index]),
                    ),
            );
          }),
        );
      })),
    );
  }

  Padding guessTiles(List<List<String>> identifier, bool isGuessed) {
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width5,
          right: Dimensions.width5,
          top: Dimensions.height10),
      child: Column(
        children: List.generate(lettersListAnswer.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: Dimensions.height10 / 1.5),
            child: tileList(
              correctLettersList[index],
              identifier[index],
              index,
              isGuessed,
            ),
          );
        }),
      ),
    );
  }

  Wrap tileList(
      List<String> words, List<String> answer, int wordIndex, bool isGuessed) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: List.generate(
        words.length,
        (index) => answer[index] == ''
            ? const EmptyTile()
            : answer[index] == '/'
                ? Container(
                    width: Dimensions.screenWidth / 10,
                  )
                : ShakeAnimatedWidget(
                    enabled:
                        answer[index] == wrongLettersList[wordIndex][index] &&
                                answer[index] != '/' &&
                                answer[index] != '-' &&
                                answer[index] != String.fromCharCode(8626)
                            ? true
                            : shakeTile,
                    duration: const Duration(milliseconds: 500),
                    shakeAngle:
                        answer[index] == wrongLettersList[wordIndex][index] &&
                                answer[index] != '/' &&
                                answer[index] != '-' &&
                                answer[index] != String.fromCharCode(8626)
                            ? Rotation.deg(x: 80)
                            : Rotation.deg(z: 40),
                    curve: Curves.linear,
                    child: GestureDetector(
                      onTap: () {
                        if (!isGuessed) {
                          removeLetter(answer[index], index, wordIndex);
                        }
                      },
                      child: LetterTile(letter: answer[index]),
                    ),
                  ),
      ),
    );
  }
}
