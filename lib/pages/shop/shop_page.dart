import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../helper/ad_helper.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../widget/hint_widget.dart';
import '../../widget/menu_button.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    _loadRewardedAd();
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SwipeDetector(
        onSwipeDown: (value) {
          Get.back();
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Dimensions.width10, right: Dimensions.width10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: Dimensions.width20 * 2,
                        height: Dimensions.height20 * 2,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius20 * 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                    ),
                    GetBuilder<HintController>(builder: (hintController) {
                      return HintWidget(
                        onTap: () {
                          hintController.useHint(hintController.getHints);
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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        for (int i = 1; i <= 10; i++) {
                          Get.find<HintController>().addHint(5);
                        }
                      },
                      title: 'Buy 50 hints',
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        for (int i = 1; i <= 20; i++) {
                          Get.find<HintController>().addHint(5);
                        }
                      },
                      title: 'Buy 100 hints',
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        for (int i = 1; i <= 100; i++) {
                          Get.find<HintController>().addHint(5);
                        }
                      },
                      title: 'Buy 500 hints',
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        _rewardedAd?.show(
                          onUserEarnedReward: (_, reward) {
                            Get.find<HintController>().addHint(3);
                          },
                        );
                      },
                      title: 'Watch a video and get 3',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
