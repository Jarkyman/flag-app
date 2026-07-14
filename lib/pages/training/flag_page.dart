import 'dart:async';
import 'dart:math';

import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controllers/hint_controller.dart';
import '../../controllers/analytics_controller.dart';
import '../../controllers/game_services_controller.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../controllers/sound_controller.dart';
import '../../helper/ad_helper.dart';
import '../../helper/dimensions.dart';
import '../../helper/help_widgets.dart';
import '../../helper/image_decode_size.dart';
import '../../models/training_continent.dart';
import '../../widget/ads/ad_banner_widget.dart';
import '../../widget/menu_background.dart';
import '../../widget/popup/continent_filter_dialog.dart';
import '../../widget/popup/help_dialog.dart';
import '../../widget/popup/wrong_guess_dialog.dart';
import '../../widget/training/training_game_widgets.dart';

class FlagPage extends StatefulWidget {
  const FlagPage({super.key});

  @override
  State<FlagPage> createState() => _FlagPageState();
}

class _FlagPageState extends State<FlagPage> {
  static const String _gameMode = 'find_flag';

  late CountryModel selectedCountry;
  late List<CountryModel> countryOptions;
  List<bool> correctColor = [false, false, false, false];
  List<bool> wrongColor = [false, false, false, false];
  bool isLoading = true;
  bool fiftyFiftyUsed = false;
  bool checkUsed = false;
  late int selected;
  int score = 0;
  late int highScore;
  bool hasNewRecordThisRun = false;
  bool isTryAgainUsed = false;
  bool isDelay = false;
  bool isAdLoaded = false;
  TrainingContinent selectedContinent = TrainingContinent.all;

  Random random = Random();

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    createBannerAd();
    _loadRewardedAd();
    _loadInterstitialAd();
    setState(() {
      selectedCountry = Get.find<CountryController>().getACountry(
        continent: _continentFilter,
      );
      countryOptions = Get.find<CountryController>().generateCountries(
        selectedCountry.countryName.toString(),
        4,
        continent: _continentFilter,
      );
      highScore = _recordFor(selectedContinent);
      isLoading = false;
      isTryAgainUsed = false;
    });
    debugPrint('Flag high score: $highScore');
    unawaited(
      Get.find<AnalyticsController>().gameStarted(
        gameMode: _gameMode,
        continent: selectedContinent,
      ),
    );
  }

  @override
  void dispose() {
    if (score > 0) {
      unawaited(
        Get.find<AnalyticsController>().gameFinished(
          gameMode: _gameMode,
          score: score,
          newRecord: hasNewRecordThisRun,
          reason: 'exit',
          continent: selectedContinent,
        ),
      );
    }
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    if (AdHelper.forcedAdsEnabled) {
      InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                openWrongDialog();
                _loadInterstitialAd();
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

  void _loadRewardedAd() {
    if (!AdHelper.adsEnabled) return;

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );
          setState(() {
            isAdLoaded = true;
          });

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          setState(() {
            isAdLoaded = false;
          });
          debugPrint('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  void createBannerAd() {
    if (AdHelper.forcedAdsEnabled) {
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

  void generateCountries() {
    setState(() {
      const Duration(milliseconds: 500).delay(() {
        selectedCountry = Get.find<CountryController>().getACountry(
          continent: _continentFilter,
        );
        countryOptions = Get.find<CountryController>().generateCountries(
          selectedCountry.countryName.toString(),
          4,
          continent: _continentFilter,
        );
        debugPrint(selectedCountry.countryName);
        correctColor = [false, false, false, false];
        wrongColor = [false, false, false, false];
        isLoading = false;
        fiftyFiftyUsed = false;
        checkUsed = false;
        isDelay = false;
      });
      isLoading = false;
    });
  }

  void checkWin(String country, int selected, {bool usedHint = false}) {
    isDelay = true;
    this.selected = selected;
    if (country == selectedCountry.countryName.toString()) {
      Get.find<SoundController>().correctSound();
      correctColor[selected] = true;
      setState(() {
        checkUsed = true;
        isLoading = true;
        score++;
        if (score > highScore) {
          hasNewRecordThisRun = true;
          highScore = score;
          Get.find<ScoreController>().saveTrainingScore(
            TrainingScoreGame.findFlag,
            selectedContinent,
            highScore,
          );
        }
      });
      unawaited(
        Get.find<GameServicesController>().recordTrainingCorrect(
          game: TrainingScoreGame.findFlag,
          continent: selectedContinent,
          streak: score,
        ),
      );
      unawaited(
        Get.find<AnalyticsController>().answerSubmitted(
          gameMode: _gameMode,
          correct: true,
          streak: score,
          usedHint: usedHint,
          newRecord: score == highScore && hasNewRecordThisRun,
          continent: selectedContinent,
        ),
      );
      generateCountries();
    } else {
      Get.find<SoundController>().wrongSound();
      setState(() {
        correctColor[getCorrect()] = true;
        wrongColor[selected] = true;
        if (score > highScore) {
          hasNewRecordThisRun = true;
          highScore = score;
          Get.find<ScoreController>().saveTrainingScore(
            TrainingScoreGame.findFlag,
            selectedContinent,
            highScore,
          );
        }
      });
      unawaited(
        Get.find<AnalyticsController>().answerSubmitted(
          gameMode: _gameMode,
          correct: false,
          streak: score,
          usedHint: false,
          newRecord: hasNewRecordThisRun,
          continent: selectedContinent,
        ),
      );
      const Duration(milliseconds: 500).delay(() {
        int randomInt = random.nextInt(10);
        if (_interstitialAd != null &&
            randomInt == 2 &&
            !Get.find<ShopController>().isAdsRemoved) {
          _interstitialAd?.show();
        } else {
          openWrongDialog();
          ReviewController.checkReviewPopup(context);
        }
      });
    }
  }

  void openWrongDialog() {
    debugPrint('isAdLoaded: $isAdLoaded');
    wrongGuessDialog(
      score: score,
      isNewRecord: hasNewRecordThisRun,
      isTryAgainUsed: isTryAgainUsed || !isAdLoaded,
      adLoaded: isAdLoaded,
      onTapConfirm: () {
        _rewardedAd?.show(
          onUserEarnedReward: (_, reward) {
            unawaited(
              Get.find<AnalyticsController>().rewardedAdCompleted(
                placement: '${_gameMode}_continue',
              ),
            );
            generateCountries();
            Get.close(1);
            isTryAgainUsed = true;
          },
        );
      },
      onTapCancel: () {
        unawaited(
          Get.find<AnalyticsController>().gameFinished(
            gameMode: _gameMode,
            score: score,
            newRecord: hasNewRecordThisRun,
            reason: 'wrong_answer',
            continent: selectedContinent,
          ),
        );
        wrongChoice(selected);
        Get.find<CountryController>().resetCount(
          continent: _continentFilter,
        );
        Get.close(1);
      },
    );
  }

  void wrongChoice(int selected) {
    setState(() {
      generateCountries();
      isTryAgainUsed = false;
      hasNewRecordThisRun = false;
      score = 0;
    });
  }

  int getCorrect() {
    return countryOptions.indexOf(selectedCountry);
  }

  void useCorrectHint(int hints) {
    if (Get.find<HintController>().checkIfEnoughHints(hints) && !checkUsed) {
      Get.find<HintController>().useHint(hints);
      unawaited(
        Get.find<AnalyticsController>().hintUsed(
          gameMode: _gameMode,
          hintType: 'correct_answer',
          cost: hints,
        ),
      );
      checkWin(selectedCountry.countryName!, getCorrect(), usedHint: true);
    }
  }

  void useFiftyFiftyHint(int hints) {
    if (Get.find<HintController>().checkIfEnoughHints(hints) &&
        !fiftyFiftyUsed) {
      Get.find<HintController>().useHint(hints);
      unawaited(
        Get.find<AnalyticsController>().hintUsed(
          gameMode: _gameMode,
          hintType: 'fifty_fifty',
          cost: hints,
        ),
      );
      int correct = getCorrect();
      wrongColor = [false, false, false, false];
      Random ran = Random();
      int ran1 = ran.nextInt(4);
      int ran2 = ran.nextInt(4);
      while (ran1 == correct || ran1 == ran2 || ran2 == correct) {
        ran1 = ran.nextInt(4);
        ran2 = ran.nextInt(4);
      }
      setState(() {
        wrongColor[ran1] = true;
        wrongColor[ran2] = true;
        fiftyFiftyUsed = true;
      });
    }
  }

  int _countDialogOpen = 0;

  String? get _continentFilter => selectedContinent == TrainingContinent.all
      ? null
      : selectedContinent.assetNameFor(Get.locale!);

  int _recordFor(TrainingContinent continent) {
    return Get.find<ScoreController>().getTrainingScore(
      TrainingScoreGame.findFlag,
      continent,
    );
  }

  Future<void> _chooseContinent() async {
    final nextContinent = await showContinentFilterDialog(
      context: context,
      selectedContinent: selectedContinent,
      accentColor: AppColors.coralColor,
      recordFor: _recordFor,
    );
    if (!mounted ||
        nextContinent == null ||
        nextContinent == selectedContinent) {
      return;
    }

    if (score > 0) {
      unawaited(
        Get.find<AnalyticsController>().gameFinished(
          gameMode: _gameMode,
          score: score,
          newRecord: hasNewRecordThisRun,
          reason: 'continent_changed',
          continent: selectedContinent,
        ),
      );
    }
    unawaited(
      Get.find<AnalyticsController>().continentSelected(
        gameMode: _gameMode,
        continent: nextContinent,
      ),
    );

    final continentFilter = nextContinent == TrainingContinent.all
        ? null
        : nextContinent.assetNameFor(Get.locale!);
    final countryController = Get.find<CountryController>();
    final nextCountry = countryController.getACountry(
      continent: continentFilter,
    );
    final nextOptions = countryController.generateCountries(
      nextCountry.countryName.toString(),
      4,
      continent: continentFilter,
    );

    setState(() {
      selectedContinent = nextContinent;
      selectedCountry = nextCountry;
      countryOptions = nextOptions;
      correctColor = [false, false, false, false];
      wrongColor = [false, false, false, false];
      score = 0;
      highScore = _recordFor(nextContinent);
      hasNewRecordThisRun = false;
      isTryAgainUsed = false;
      fiftyFiftyUsed = false;
      checkUsed = false;
      isDelay = false;
      isLoading = false;
    });
    unawaited(
      Get.find<AnalyticsController>().gameStarted(
        gameMode: _gameMode,
        continent: nextContinent,
      ),
    );
  }

  void openHelpDialog() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countDialogOpen == 0) {
        if (!Get.find<SettingsController>().getFirstTrainHelp) {
          helpDialog(trainingHelpWidgets());
          Get.find<SettingsController>().firstHelpTrainSave(true);
          _countDialogOpen++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    openHelpDialog();
    return Scaffold(
      body: MenuBackground(
        showDottedWorldMap: false,
        child: SafeArea(
          bottom: false,
          child: GetBuilder<CountryController>(
            builder: (countryController) {
              final imgCode =
                  selectedCountry.countryCode.toString().toLowerCase();

              return Column(
                children: [
                  TrainingGameHeader(
                    score: score,
                    highScore: highScore,
                    accentColor: AppColors.coralColor,
                    selectedContinent: selectedContinent,
                    onContinentTap: isDelay ? null : _chooseContinent,
                  ),
                  TrainingHintActions(
                    onCorrectAnswer: () => useCorrectHint(3),
                    onFiftyFifty: () => useFiftyFiftyHint(1),
                    correctAnswerUsed: checkUsed,
                    fiftyFiftyUsed: fiftyFiftyUsed,
                    accentColor: AppColors.coralColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Dimensions.width15,
                        0,
                        Dimensions.width15,
                        Dimensions.height10,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TrainingPromptCard(
                              accentColor: AppColors.coralColor,
                              padding: EdgeInsets.all(Dimensions.width20),
                              child: Image.asset(
                                'assets/image/flags/$imgCode.png',
                                fit: BoxFit.contain,
                                cacheWidth: imageDecodeWidth(
                                  logicalWidth: Dimensions.screenWidth,
                                  devicePixelRatio:
                                      MediaQuery.devicePixelRatioOf(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Dimensions.height15),
                          Expanded(
                            flex: 6,
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: countryOptions.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: Dimensions.height10),
                              itemBuilder: (context, index) {
                                final eliminated = fiftyFiftyUsed &&
                                    !isDelay &&
                                    wrongColor[index];
                                final state = correctColor[index]
                                    ? TrainingAnswerState.correct
                                    : eliminated
                                        ? TrainingAnswerState.disabled
                                        : wrongColor[index]
                                            ? TrainingAnswerState.wrong
                                            : TrainingAnswerState.idle;

                                return TrainingTextAnswerCard(
                                  text: countryOptions[index]
                                      .countryName
                                      .toString(),
                                  accentColor: AppColors.coralColor,
                                  state: state,
                                  onTap: isDelay || eliminated
                                      ? null
                                      : () => checkWin(
                                            countryOptions[index]
                                                .countryName
                                                .toString(),
                                            index,
                                          ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GetBuilder<ShopController>(
                    builder: (shopController) {
                      if (shopController.isAdsRemoved) {
                        _interstitialAd?.dispose();
                      }
                      return _bannerAd != null && !shopController.isAdsRemoved
                          ? AdBannerWidget(bannerAd: _bannerAd)
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
