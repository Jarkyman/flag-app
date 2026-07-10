import 'dart:math';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/controllers/settings_controller.dart';
import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/models/level_model.dart';
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
import '../../../helper/guess_puzzle_logic.dart';
import '../../../helper/help_widgets.dart';
import '../../../helper/route_helper.dart';
import '../../../models/country_model.dart';
import '../../../widget/ads/ad_banner_widget.dart';
import '../../../widget/menu_background.dart';
import '../../../widget/play/guess_game_widgets.dart';
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
      levelList = levelController.getLevelList(argLevel, argType);
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
    return GuessPuzzleLogic.buildCorrectLetters(
      word,
      tilesPerRow: tilesPrRow,
    );
  }

  List<List<String>> getLettersListEmpty(String word) {
    return GuessPuzzleLogic.buildEmptyAnswer(
      word,
      tilesPerRow: tilesPrRow,
    );
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
      final result = GuessPuzzleLogic.applyCorrectLetterHint(
        correctLetters: correctLettersList,
        answerLetters: lettersListAnswer,
        allLetters: allLetters,
      );

      if (result.applied) {
        setState(() {
          lettersListAnswer = result.answerLetters;
          allLetters = result.allLetters;
        });

        final levelController = Get.find<LevelController>();
        levelController.saveAnswerLetters(
          argType,
          country,
          lettersListAnswer,
        );
        levelController.saveAllLetters(argType, country, allLetters);
        Get.find<HintController>().useHint(hints);
        checkWin();
      }
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  void useBombStart() {
    if (!bombUsed) {
      _applyBomb();
    }
  }

  void useBombHint(int hints) {
    if (Get.find<HintController>().getHints >= hints) {
      if (!bombUsed) {
        _applyBomb();
        Get.find<HintController>().useHint(hints);
      }
    } else {
      Get.toNamed(RouteHelper.getShopPage());
    }
  }

  void _applyBomb() {
    final result = GuessPuzzleLogic.applyBomb(
      correctLetters: correctLettersList,
      answerLetters: lettersListAnswer,
      allLetters: allLetters,
    );

    setState(() {
      lettersListAnswer = result.answerLetters;
      allLetters = result.allLetters;
      bombUsed = true;
    });

    final levelController = Get.find<LevelController>();
    levelController.saveAnswerLetters(argType, country, lettersListAnswer);
    levelController.saveBombUsed(argType, country, true);
    levelController.saveAllLetters(argType, country, allLetters);
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

  void _closePage() {
    final randomInt = random.nextInt(10);
    if (_interstitialAd != null &&
        randomInt == 3 &&
        !Get.find<ShopController>().isAdsRemoved) {
      _interstitialAd?.show();
    } else {
      Get.find<SoundController>().windSound();
      Get.back();
    }
  }

  Color get _accentColor {
    switch (argType) {
      case AppConstants.FLAGS:
        return AppColors.coralColor;
      case AppConstants.COUNTRIES:
        return AppColors.skyColor;
      case AppConstants.COC:
        return AppColors.purpleColor;
      default:
        return AppColors.mainColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    //openHelpDialog();
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) _closePage();
        },
        child: SwipeDetector(
          onSwipeRight: (value) {
            final nextPageIndex = argFlagIndex - 1;
            if (nextPageIndex > -1) {
              Get.find<SoundController>().windSound();
              setState(() {
                argFlagIndex = nextPageIndex;
                setInit();
              });
            }
          },
          onSwipeLeft: (value) {
            final nextPageIndex = argFlagIndex + 1;
            if (nextPageIndex < levelList.length) {
              Get.find<SoundController>().windSound();
              setState(() {
                argFlagIndex = nextPageIndex;
                setInit();
              });
            }
          },
          child: MenuBackground(
            child: SafeArea(
              bottom: false,
              child: GetBuilder<LevelController>(
                builder: (levelController) {
                  final countryController = Get.find<CountryController>();
                  final baseCountryCode = countryController
                      .getCountryCode(country.country!)
                      .toLowerCase();
                  var imageCode = baseCountryCode;

                  if (AppConstants.FULL_FLAG_LIST.contains(imageCode) &&
                      country.guessed! &&
                      argType == AppConstants.FLAGS) {
                    imageCode = '$baseCountryCode-full';
                  }
                  if (argType == AppConstants.COUNTRIES) {
                    imageCode = '$baseCountryCode-full';
                  }
                  if (AppConstants.FULL_COC_LIST.contains(imageCode) &&
                      country.guessed! &&
                      argType == AppConstants.COC) {
                    imageCode = '$baseCountryCode-full';
                  }

                  final countryModel =
                      countryController.getCountryByName(country.country!);

                  return Column(
                    children: [
                      GuessGameHeader(
                        title: '${'Level'.tr} $argLevel',
                        subtitle:
                            '${argType.tr}  •  ${argFlagIndex + 1}/${levelList.length}',
                        onBack: _closePage,
                        onHelp: () => helpDialog(guessHelpWidgets()),
                      ),
                      if (!country.guessed!)
                        GuessHintActions(
                          onFinish: () => useFinishHint(5),
                          onBomb: bombUsed ? null : () => useBombHint(2),
                          onLetter: () => useFirstLetterHint(1),
                          accentColor: _accentColor,
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width15,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: Dimensions.height10 * 0.4),
                              SizedBox(
                                height: Dimensions.height20 * 9.3,
                                child: GuessPromptCard(
                                  accentColor: _accentColor,
                                  child: _promptImage(
                                    imageCode: imageCode,
                                    heroCode: baseCountryCode,
                                  ),
                                ),
                              ),
                              SizedBox(height: Dimensions.height10),
                              if (country.guessed!) ...[
                                guessTiles(
                                  correctLettersList,
                                  true,
                                  _accentColor,
                                ),
                                const Spacer(),
                                GuessFactsCard(
                                  accentColor: _accentColor,
                                  facts: _countryFacts(countryModel),
                                ),
                              ] else
                                Expanded(
                                  child: Column(
                                    children: [
                                      guessTiles(
                                        lettersListAnswer,
                                        false,
                                        _accentColor,
                                      ),
                                      const Spacer(),
                                      GuessLetterTray(
                                        accentColor: _accentColor,
                                        child: tilesAtBottom(_accentColor),
                                      ),
                                      SizedBox(
                                        height: Dimensions.height10,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      _buildBanner(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _promptImage({
    required String imageCode,
    required String heroCode,
  }) {
    final imagePath =
        'assets/image/${argType.toLowerCase()}/${imageCode.toLowerCase()}.png';

    if (argType == AppConstants.COUNTRIES) {
      return Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: heroCode.toLowerCase(),
              child: Image.asset(
                'assets/image/${argType.toLowerCase()}/${heroCode.toLowerCase()}.png',
                fit: BoxFit.contain,
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ],
      );
    }

    return Hero(
      tag: imageCode.toLowerCase(),
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }

  List<GuessFactData> _countryFacts(CountryModel country) {
    final countryName =
        country.countryName!.toLowerCase() == 'Côte dIvoire'.toLowerCase()
            ? 'Côte d\'Ivoire'
            : firstLetterUpperCase(country.countryName!);

    return [
      GuessFactData(
        icon: Icons.public_rounded,
        label: 'Continent'.tr,
        value: firstLetterUpperCase(
          Get.find<CountryContinentController>()
              .getContinentNameByCountryModel(country),
        ),
      ),
      GuessFactData(
        icon: Icons.flag_rounded,
        label: 'Country'.tr,
        value: countryName,
      ),
      GuessFactData(
        icon: Icons.location_city_rounded,
        label: 'Capital'.tr,
        value: firstLetterUpperCase(country.capital!),
      ),
      GuessFactData(
        icon: Icons.payments_rounded,
        label: 'Currency'.tr,
        value:
            '${firstLetterUpperCase(country.currencyName!)} (${country.currencyCode!})',
      ),
    ];
  }

  Widget _buildBanner() {
    return GetBuilder<ShopController>(
      builder: (shopController) {
        final showBanner = !country.guessed! &&
            _bannerAd != null &&
            getAmountOfTileRows(tilesPrRow) < 4 &&
            !shopController.isAdsRemoved;

        return showBanner
            ? AdBannerWidget(bannerAd: _bannerAd!)
            : const SizedBox.shrink();
      },
    );
  }

  Widget tilesAtBottom(Color accentColor) {
    return Column(
      children: List.generate(getAmountOfTileRows(tilesPrRow), (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(tilesPrRow, (tileIndex) {
            final index = tileIndex + (tilesPrRow * rowIndex);

            return Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height10 / 2),
              child: allLetters[index] == ''
                  ? EmptyTile(accentColor: accentColor)
                  : GestureDetector(
                      onTap: () {
                        putLetterInBox(allLetters[index], index);
                      },
                      child: LetterTile(
                        letter: allLetters[index],
                        accentColor: accentColor,
                      ),
                    ),
            );
          }),
        );
      }),
    );
  }

  Padding guessTiles(
    List<List<String>> identifier,
    bool isGuessed,
    Color accentColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width5),
      child: Column(
        children: List.generate(lettersListAnswer.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: Dimensions.height10 / 1.5),
            child: tileList(
              correctLettersList[index],
              identifier[index],
              index,
              isGuessed,
              accentColor,
            ),
          );
        }),
      ),
    );
  }

  Wrap tileList(
    List<String> words,
    List<String> answer,
    int wordIndex,
    bool isGuessed,
    Color accentColor,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Dimensions.width5,
      runSpacing: Dimensions.height10 / 2,
      children: List.generate(
        words.length,
        (index) => answer[index] == ''
            ? EmptyTile(
                accentColor: accentColor,
                isAnswer: true,
              )
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
                      child: LetterTile(
                        letter: answer[index],
                        accentColor: accentColor,
                        isAnswer: true,
                      ),
                    ),
                  ),
      ),
    );
  }
}
