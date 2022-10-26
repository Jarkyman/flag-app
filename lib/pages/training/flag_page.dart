import 'dart:math';

import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controllers/hint_controller.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/sound_controller.dart';
import '../../helper/ad_helper.dart';
import '../../helper/dimensions.dart';
import '../../widget/Top bar/hint_bar.dart';
import '../../widget/ads/ad_banner_widget.dart';
import '../../widget/background_image.dart';
import '../../widget/buttons/guess_button.dart';
import '../../widget/popup/wrong_guess_dialog.dart';

class FlagPage extends StatefulWidget {
  const FlagPage({Key? key}) : super(key: key);

  @override
  State<FlagPage> createState() => _FlagPageState();
}

class _FlagPageState extends State<FlagPage> {
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
  bool isTryAgainUsed = false;
  bool isDelay = false;
  bool isAdLoaded = false;

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
      selectedCountry = Get.find<CountryController>().getACountry();
      countryOptions = Get.find<CountryController>()
          .generateCountries(selectedCountry.countryName.toString(), 4);
      highScore = Get.find<ScoreController>().getFlagScore;
      isLoading = false;
      isTryAgainUsed = false;
    });
    print(Get.find<ScoreController>().getFlagScore);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
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
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
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
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  void createBannerAd() {
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
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  void generateCountries() {
    setState(() {
      Duration(milliseconds: 500).delay(() {
        selectedCountry = Get.find<CountryController>().getACountry();
        countryOptions = Get.find<CountryController>()
            .generateCountries(selectedCountry.countryName.toString(), 4);
        print(selectedCountry.countryName);
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

  void checkWin(String country, int selected) {
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
          highScore = score;
          Get.find<ScoreController>().saveFlagScore(highScore);
        }
      });
      generateCountries();
    } else {
      Get.find<SoundController>().wrongSound();
      setState(() {
        correctColor[getCorrect()] = true;
        wrongColor[selected] = true;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveFlagScore(highScore);
        }
      });
      Duration(milliseconds: 500).delay(() {
        int randomInt = random.nextInt(3);
        if (_interstitialAd != null && randomInt == 2) {
          _interstitialAd?.show();
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
      isTryAgainUsed: isTryAgainUsed,
      adLoaded: isAdLoaded,
      onTapConfirm: () {
        _rewardedAd?.show(
          onUserEarnedReward: (_, reward) {
            generateCountries();
            Get.close(1);
            isTryAgainUsed = true;
          },
        );
      },
      onTapCancel: () {
        wrongChoice(selected);
        Get.find<CountryController>().resetCount();
        Get.close(1);
      },
    );
  }

  void wrongChoice(int selected) {
    setState(() {
      generateCountries();
      isTryAgainUsed = false;
      score = 0;
    });
  }

  int getCorrect() {
    return countryOptions.indexOf(selectedCountry);
  }

  void useCorrectHint(hints) {
    if (Get.find<HintController>().checkIfEnoughHints(hints) && !checkUsed) {
      Get.find<HintController>().useHint(hints);
      checkWin(selectedCountry.countryName!, getCorrect());
    }
  }

  void useFiftyFiftyHint(int hints) {
    if (Get.find<HintController>().checkIfEnoughHints(hints) &&
        !fiftyFiftyUsed) {
      Get.find<HintController>().useHint(hints);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.find<SoundController>().clickSound();
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        title: Text(
          score.toString(),
          style: TextStyle(
              fontSize: Dimensions.font26 * 1.2, color: AppColors.titleColor),
        ),
        backgroundColor: AppColors.mainColor,
        actions: [
          GetBuilder<ScoreController>(builder: (scoreController) {
            return Row(
              children: [
                Icon(Icons.star),
                SizedBox(
                  width: Dimensions.width5 / 2,
                ),
                Text(
                  highScore.toString(),
                  style: TextStyle(fontSize: Dimensions.font16 * 1.2),
                ),
                SizedBox(
                  width: Dimensions.width5,
                ),
              ],
            );
          }),
        ],
      ),
      body: BackgroundImage(
        child: SafeArea(
          child: GetBuilder<CountryController>(
            builder: (countryController) {
              String imgCode =
                  selectedCountry.countryCode.toString().toLowerCase();
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HintBar(
                      tapHintOne: () {
                        useCorrectHint(3);
                      },
                      tapHintTwo: () {
                        useFiftyFiftyHint(1);
                      },
                      iconOne: Icon(
                        Icons.check,
                        color: AppColors.mainColor,
                      ),
                      iconTwo: ImageIcon(
                        AssetImage('assets/icon/fifty_fifty.png'),
                        color: AppColors.mainColor,
                        size: Dimensions.iconSize24 * 1.4,
                      ),
                      hintPriceOne: '3',
                      hintPriceTwo: '1'),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: Dimensions.height10),
                      child: Container(
                        width: double.maxFinite,
                        //height: Dimensions.height20 * 14,
                        margin: EdgeInsets.symmetric(
                            horizontal: Dimensions.height20),
                        child: Center(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius10),
                            child: Image.asset(
                              'assets/image/flags/$imgCode.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                  Expanded(
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return GuessButton(
                            color: correctColor[index]
                                ? AppColors.correctColor
                                : wrongColor[index]
                                    ? Colors.red
                                    : Colors.white,
                            textColor: correctColor[index]
                                ? Colors.white
                                : wrongColor[index]
                                    ? Colors.white
                                    : AppColors.mainColor,
                            borderColor: correctColor[index]
                                ? Colors.white
                                : wrongColor[index]
                                    ? Colors.white
                                    : AppColors.mainColor,
                            country:
                                countryOptions[index].countryName.toString(),
                            onTap: () {
                              if (!isDelay) {
                                if (!wrongColor[index]) {
                                  checkWin(
                                      countryOptions[index]
                                          .countryName
                                          .toString(),
                                      index);
                                }
                              }
                            },
                          );
                        }),
                  ),
                  _bannerAd != null
                      ? adBannerWidget(bannerAd: _bannerAd)
                      : Container(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
