import 'dart:math';

import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flag_app/widget/popup/wrong_guess_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../controllers/hint_controller.dart';
import '../helper/ad_helper.dart';
import '../helper/dimensions.dart';
import '../helper/route_helper.dart';
import '../widget/ads/ad_banner_widget.dart';
import '../widget/guess_button.dart';
import '../widget/hint_widget.dart';

class CountriesPage extends StatefulWidget {
  const CountriesPage({Key? key}) : super(key: key);

  @override
  State<CountriesPage> createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> {
  late CountryModel selectedCountry;
  late List<CountryModel> countryOptions;
  List<bool> correctColor = [false, false, false, false];
  List<bool> wrongColor = [false, false, false, false];
  bool isLoading = true;
  bool fiftyFiftyUsed = false;
  bool checkUsed = false;
  int score = 0;
  late int highScore;
  bool isTryAgainUsed = false;

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    createBannerAd();
    _loadRewardedAd();
    setState(() {
      selectedCountry = Get.find<CountryController>().getACountry();
      countryOptions = Get.find<CountryController>()
          .generateCountries(selectedCountry.countryName.toString(), 4);
      highScore = Get.find<ScoreController>().getCountriesScore;
      isLoading = false;
      isTryAgainUsed = false;
    });
    print(Get.find<ScoreController>().getCountriesScore);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
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
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
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
      });
      isLoading = false;
    });
  }

  void checkWin(String country, int selected) {
    if (country == selectedCountry.countryName.toString()) {
      correctColor[selected] = true;
      setState(() {
        checkUsed = true;
        isLoading = true;
        score++;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveCountriesScore(highScore);
        }
      });
      generateCountries();
    } else {
      setState(() {
        correctColor[getCorrect()] = true;
        wrongColor[selected] = true;
        if (score > highScore) {
          highScore = score;
          Get.find<ScoreController>().saveCountriesScore(highScore);
        }
      });
      wrongGuessDialog(
        score: score,
        isTryAgainUsed: isTryAgainUsed,
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
          Get.close(1);
        },
      );
    }
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

  void getFiftyFifty() {
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

    print(ran1.toString() + " / " + ran2.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Countries',
          style: TextStyle(
              fontSize: Dimensions.font26, color: AppColors.titleColor),
        ),
        backgroundColor: AppColors.mainColor,
        actions: [
          GetBuilder<ScoreController>(builder: (scoreController) {
            return Text(
              'Score: $score \nHigh score: $highScore ',
              style: TextStyle(fontSize: Dimensions.font16),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : GetBuilder<CountryController>(
                builder: (countryController) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: Dimensions.height10,
                            bottom: Dimensions.height10),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: Dimensions.width10,
                              right: Dimensions.width10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GetBuilder<HintController>(
                                        builder: (hintController) {
                                      return HintWidget(
                                        onTap: () {
                                          if (hintController.getCorrect() &&
                                              !checkUsed) {
                                            hintController.useHint(3);
                                            checkWin(
                                                selectedCountry.countryName!,
                                                getCorrect());
                                          }
                                        },
                                        icon: Icon(
                                          Icons.check,
                                          color: AppColors.mainColor,
                                        ),
                                        num: '3',
                                      );
                                    }),
                                    SizedBox(
                                      width: Dimensions.width10,
                                    ),
                                    GetBuilder<HintController>(
                                        builder: (hintController) {
                                      return HintWidget(
                                        onTap: () {
                                          if (hintController.getFiftyFifty() &&
                                              !fiftyFiftyUsed) {
                                            hintController.useHint(1);
                                            getFiftyFifty();
                                          }
                                        },
                                        icon: ImageIcon(
                                          AssetImage(
                                              'assets/icon/fifty_fifty.png'),
                                          color: AppColors.mainColor,
                                          size: Dimensions.iconSize24 * 1.4,
                                        ),
                                        num: '1',
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              GetBuilder<HintController>(
                                  builder: (hintController) {
                                return HintWidget(
                                  onTap: () {
                                    Get.toNamed(RouteHelper.getShopPage());
                                  },
                                  icon: Icon(
                                    Icons.lightbulb_outline,
                                    color: AppColors.mainColor,
                                  ),
                                  num: hintController.getHints.toString(),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.maxFinite,
                          //height: Dimensions.height20 * 14,
                          margin: EdgeInsets.symmetric(
                              horizontal: Dimensions.height20),
                          decoration: BoxDecoration(),
                          child: Image.asset(
                            'assets/image/countries/${selectedCountry.countryCode.toString().toLowerCase()}.png',
                            fit: BoxFit.contain,
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
                                country: countryOptions[index]
                                    .countryName
                                    .toString(),
                                onTap: () {
                                  if (!wrongColor[index]) {
                                    checkWin(
                                        countryOptions[index]
                                            .countryName
                                            .toString(),
                                        index);
                                  }
                                },
                              );
                            }),
                      ),
                      if (_bannerAd != null)
                        adBannerWidget(bannerAd: _bannerAd),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
