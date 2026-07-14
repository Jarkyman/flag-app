import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controllers/country_controller.dart';
import '../../controllers/analytics_controller.dart';
import '../../controllers/game_services_controller.dart';
import '../../controllers/hint_controller.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/score_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../controllers/sound_controller.dart';
import '../../helper/ad_helper.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../helper/help_widgets.dart';
import '../../models/country_model.dart';
import '../../models/training_continent.dart';
import '../../widget/ads/ad_banner_widget.dart';
import '../../widget/menu_background.dart';
import '../../widget/popup/continent_filter_dialog.dart';
import '../../widget/popup/help_dialog.dart';
import '../../widget/popup/wrong_guess_dialog.dart';
import '../../widget/training/training_game_widgets.dart';

class FlagsPage extends StatefulWidget {
  const FlagsPage({super.key});

  @override
  State<FlagsPage> createState() => _FlagsPageState();
}

class _FlagsPageState extends State<FlagsPage> {
  static const String _gameMode = 'match_flags';

  late CountryModel selectedCountry;
  late List<CountryModel> countryOptions;
  List<bool> correctColor = [false, false, false, false, false, false];
  List<bool> wrongColor = [false, false, false, false, false, false];
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
  bool _isInterstitialAdLoading = false;
  bool _isRewardedAdLoading = false;

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
        6,
        continent: _continentFilter,
      );
      highScore = _recordFor(selectedContinent);
      isLoading = false;
    });
    debugPrint('Flags high score: $highScore');
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
    if (!AdHelper.forcedAdsEnabled ||
        _interstitialAd != null ||
        _isInterstitialAdLoading) {
      return;
    }

    _isInterstitialAdLoading = true;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterstitialAdLoading = false;
          if (!mounted || !AdHelper.forcedAdsEnabled) {
            ad.dispose();
            return;
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: _finishInterstitialAd,
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint(
                'Failed to show an interstitial ad: ${error.message}',
              );
              _finishInterstitialAd(ad);
            },
          );
          setState(() {
            _interstitialAd?.dispose();
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          _isInterstitialAdLoading = false;
          debugPrint('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  void _finishInterstitialAd(InterstitialAd ad) {
    ad.dispose();
    if (!mounted) return;

    _interstitialAd = null;
    openWrongDialog();
    _loadInterstitialAd();
  }

  void _loadRewardedAd() {
    if (!AdHelper.adsEnabled || _rewardedAd != null || _isRewardedAdLoading) {
      return;
    }

    _isRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isRewardedAdLoading = false;
          if (!mounted) {
            ad.dispose();
            return;
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: _finishRewardedAd,
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint(
                'Failed to show a rewarded ad: ${error.message}',
              );
              _finishRewardedAd(ad);
            },
          );
          setState(() {
            _rewardedAd?.dispose();
            _rewardedAd = ad;
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (err) {
          _isRewardedAdLoading = false;
          if (!mounted) return;
          setState(() {
            isAdLoaded = false;
          });
          debugPrint('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  void _finishRewardedAd(RewardedAd ad) {
    ad.dispose();
    if (!mounted) return;

    setState(() {
      _rewardedAd = null;
      isAdLoaded = false;
    });
    _loadRewardedAd();
  }

  void createBannerAd() {
    if (AdHelper.forcedAdsEnabled) {
      BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted || !AdHelper.forcedAdsEnabled) {
              ad.dispose();
              return;
            }
            setState(() {
              _bannerAd?.dispose();
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
          6,
          continent: _continentFilter,
        );
        debugPrint('Correct index: ${getCorrect() + 1}');
        correctColor = [false, false, false, false, false, false];
        wrongColor = [false, false, false, false, false, false];
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
            TrainingScoreGame.matchFlags,
            selectedContinent,
            highScore,
          );
        }
        generateCountries();
      });
      unawaited(
        Get.find<GameServicesController>().recordTrainingCorrect(
          game: TrainingScoreGame.matchFlags,
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
    } else {
      Get.find<SoundController>().wrongSound();
      setState(() {
        correctColor[getCorrect()] = true;
        wrongColor[selected] = true;
        if (score > highScore) {
          hasNewRecordThisRun = true;
          highScore = score;
          Get.find<ScoreController>().saveTrainingScore(
            TrainingScoreGame.matchFlags,
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
        if (!mounted) return;
        int randomInt = random.nextInt(10);
        if (_interstitialAd != null &&
            randomInt == 2 &&
            !Get.find<ShopController>().isAdsRemoved) {
          final ad = _interstitialAd!;
          _interstitialAd = null;
          ad.show();
        } else {
          openWrongDialog();
          ReviewController.checkReviewPopup(context);
        }
      });
    }
  }

  void openWrongDialog() {
    wrongGuessDialog(
      score: score,
      isNewRecord: hasNewRecordThisRun,
      isTryAgainUsed: isTryAgainUsed || !isAdLoaded,
      adLoaded: isAdLoaded,
      onTapConfirm: () {
        final ad = _rewardedAd;
        if (ad == null) return;
        setState(() {
          _rewardedAd = null;
          isAdLoaded = false;
        });
        ad.show(
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
      wrongColor = [false, false, false, false, false, false];
      Random ran = Random();
      int ran1 = ran.nextInt(6);
      int ran2 = ran.nextInt(6);
      int ran3 = ran.nextInt(6);
      while (ran1 == correct ||
          ran1 == ran2 ||
          ran2 == correct ||
          ran1 == ran3 ||
          ran2 == ran3 ||
          ran3 == correct) {
        ran1 = ran.nextInt(6);
        ran2 = ran.nextInt(6);
        ran3 = ran.nextInt(6);
      }
      setState(() {
        wrongColor[ran1] = true;
        wrongColor[ran2] = true;
        wrongColor[ran3] = true;
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
      TrainingScoreGame.matchFlags,
      continent,
    );
  }

  Future<void> _chooseContinent() async {
    final nextContinent = await showContinentFilterDialog(
      context: context,
      selectedContinent: selectedContinent,
      accentColor: AppColors.purpleColor,
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
      6,
      continent: continentFilter,
    );

    setState(() {
      selectedContinent = nextContinent;
      selectedCountry = nextCountry;
      countryOptions = nextOptions;
      correctColor = [false, false, false, false, false, false];
      wrongColor = [false, false, false, false, false, false];
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
          child: GetBuilder<CountryController>(builder: (countryController) {
            return Column(
              children: [
                TrainingGameHeader(
                  score: score,
                  highScore: highScore,
                  accentColor: AppColors.purpleColor,
                  selectedContinent: selectedContinent,
                  onContinentTap: isDelay ? null : _chooseContinent,
                ),
                TrainingHintActions(
                  onCorrectAnswer: () => useCorrectHint(3),
                  onFiftyFifty: () => useFiftyFiftyHint(1),
                  correctAnswerUsed: checkUsed,
                  fiftyFiftyUsed: fiftyFiftyUsed,
                  accentColor: AppColors.purpleColor,
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
                        SizedBox(
                          height: Dimensions.height20 * 4.5,
                          child: TrainingTextPrompt(
                            text: selectedCountry.countryName.toString(),
                            accentColor: AppColors.purpleColor,
                          ),
                        ),
                        SizedBox(height: Dimensions.height15),
                        Expanded(
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.45,
                              mainAxisSpacing: Dimensions.height10,
                              crossAxisSpacing: Dimensions.width10,
                            ),
                            itemCount: countryOptions.length,
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
                              final imageCode = countryOptions[index]
                                  .countryCode
                                  .toString()
                                  .toLowerCase();

                              return TrainingFlagAnswerCard(
                                image: 'assets/image/flags/$imageCode.png',
                                accentColor: AppColors.purpleColor,
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
                      _bannerAd?.dispose();
                      _bannerAd = null;
                      _interstitialAd?.dispose();
                      _interstitialAd = null;
                    }
                    return _bannerAd != null && !shopController.isAdsRemoved
                        ? AdBannerWidget(bannerAd: _bannerAd)
                        : const SizedBox.shrink();
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
