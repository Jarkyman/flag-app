import 'dart:math';

import 'package:flag_app/widget/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controllers/country_controller.dart';
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
import '../../widget/Top bar/hint_bar.dart';
import '../../widget/ads/ad_banner_widget.dart';
import '../../widget/popup/help_dialog.dart';
import '../../widget/popup/wrong_guess_dialog.dart';

class FlagsPage extends StatefulWidget {
  const FlagsPage({Key? key}) : super(key: key);

  @override
  State<FlagsPage> createState() => _FlagsPageState();
}

class _FlagsPageState extends State<FlagsPage> {
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
          .generateCountries(selectedCountry.countryName.toString(), 6);
      highScore = Get.find<ScoreController>().getFlagsScore;
      isLoading = false;
    });
    print(Get.find<ScoreController>().getFlagsScore);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    if (!Get.find<ShopController>().isAdsRemoved) {
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
            print('Failed to load a banner ad: ${err.message}');
            ad.dispose();
          },
        ),
      ).load();
    }
  }

  void generateCountries() {
    setState(() {
      Duration(milliseconds: 500).delay(() {
        selectedCountry = Get.find<CountryController>().getACountry();
        countryOptions = Get.find<CountryController>()
            .generateCountries(selectedCountry.countryName.toString(), 6);
        print(getCorrect() + 1);
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
          Get.find<ScoreController>().saveFlagsScore(highScore);
        }
        generateCountries();
      });
    } else {
      Get.find<SoundController>().wrongSound();
      setState(() {
        correctColor[getCorrect()] = true;
        wrongColor[selected] = true;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveFlagsScore(highScore);
        }
      });
      Duration(milliseconds: 500).delay(() {
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
    wrongGuessDialog(
      score: score,
      isTryAgainUsed: isTryAgainUsed || !isAdLoaded,
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
          child: GetBuilder<CountryController>(builder: (countryController) {
            return Column(
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
                  hintPriceTwo: '1',
                ),
                Container(
                  height: Dimensions.height30 * 2,
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Dimensions.width10),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          selectedCountry.countryName.toString(),
                          style: TextStyle(
                            fontSize: Dimensions.font26 * 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 20,
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.grey,
                ),
                Expanded(
                  child: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 3 / 2,
                    mainAxisSpacing: Dimensions.height20,
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    crossAxisCount: 2,
                    // Generate 100 widgets that display their index in the List.
                    children: List.generate(6, (index) {
                      return GestureDetector(
                        onTap: () {
                          if (!isDelay) {
                            checkWin(
                                countryOptions[index].countryName.toString(),
                                index);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 -
                              Dimensions.width20,
                          margin: EdgeInsets.symmetric(
                            horizontal: Dimensions.height10,
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius10),
                                  child: Image.asset(
                                    'assets/image/flags/${countryOptions[index].countryCode.toString().toLowerCase()}.png',
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  height: Dimensions.height20 * 3.5,
                                  width: Dimensions.height20 * 3.5,
                                  decoration: BoxDecoration(
                                    color: correctColor[index]
                                        ? AppColors.correctColor
                                        : wrongColor[index]
                                            ? AppColors.wrongColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radius20 * 3.5,
                                    ),
                                    border: Border.all(
                                      width: 2,
                                      color: correctColor[index]
                                          ? Colors.black
                                          : wrongColor[index]
                                              ? Colors.black
                                              : Colors.transparent,
                                    ),
                                  ),
                                  child: correctColor[index]
                                      ? Icon(
                                          Icons.check,
                                          size: Dimensions.iconSize16 * 2.5,
                                        )
                                      : wrongColor[index]
                                          ? Icon(
                                              Icons.close,
                                              size: Dimensions.iconSize16 * 2.5,
                                            )
                                          : Container(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                GetBuilder<ShopController>(builder: (shopController) {
                  return _bannerAd != null && !shopController.isAdsRemoved
                      ? adBannerWidget(bannerAd: _bannerAd)
                      : Container();
                })
              ],
            );
          }),
        ),
      ),
    );
  }
}
/*
image: DecorationImage(
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            correctColor[index]
                                ? AppColors.correctColor
                                : wrongColor[index]
                                    ? AppColors.wrongColor
                                    : Colors.transparent,
                            BlendMode.color,
                          ),
                          image: AssetImage(
                            'assets/image/flags/${countryOptions[index].countryCode.toString().toLowerCase()}.png',
                          ),
                        ),
 */
