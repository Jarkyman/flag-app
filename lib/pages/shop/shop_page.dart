import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/ad_helper.dart';
import '../../helper/dimensions.dart';
import '../../widget/Top bar/app_bar_row_exit.dart';
import '../../widget/buttons/menu_button.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  RewardedAd? _rewardedAd;
  List<StoreProduct> products = Get.find<ShopController>().getProducts;

  @override
  void initState() {
    _loadRewardedAd();
    //print(products[0]);
  }

  StoreProduct? getProductFromIdentifier(String identifier) {
    StoreProduct? result;
    print(products);
    for (var product in products) {
      if (product.identifier == identifier) {
        result = product;
      }
    }
    return result;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadRewardedAd() {
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
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  void purchaseErrorSnackbar() {
    Get.snackbar('Purchase failed'.tr, 'Failed to buy, try again later'.tr,
        backgroundColor: Colors.red.withOpacity(0.4));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SwipeDetector(
          onSwipeDown: (value) {
            Get.find<SoundController>().windSound();
            Get.back();
          },
          child: SafeArea(
            child: Column(
              children: [
                AppBarRowExit(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        onTap: () async {
                          try {
                            CustomerInfo customerInfo =
                                await Purchases.purchaseProduct(
                                    AppConstants.FIFTY_HINTS,
                                    type: PurchaseType.inapp);
                            debugPrint('Purchase info: $customerInfo');
                            for (int i = 1; i <= 10; i++) {
                              Get.find<HintController>().addHint(5);
                            }
                            Get.find<SoundController>().completeSound();
                          } on PlatformException catch (e) {
                            var errorCode =
                                PurchasesErrorHelper.getErrorCode(e);
                            if (errorCode !=
                                PurchasesErrorCode.purchaseCancelledError) {
                              debugPrint('Failed to purchase product.');
                              purchaseErrorSnackbar();
                            }
                          }
                        },
                        title: 'Buy 50 hints'.tr,
                        price:
                            getProductFromIdentifier(AppConstants.FIFTY_HINTS)
                                    ?.priceString ??
                                '',
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        onTap: () async {
                          try {
                            CustomerInfo customerInfo =
                                await Purchases.purchaseProduct(
                                    AppConstants.HUNDRED_HINTS,
                                    type: PurchaseType.inapp);
                            debugPrint('Purchase info: $customerInfo');
                            for (int i = 1; i <= 20; i++) {
                              Get.find<HintController>().addHint(5);
                            }
                            Get.find<SoundController>().completeSound();
                          } on PlatformException catch (e) {
                            var errorCode =
                                PurchasesErrorHelper.getErrorCode(e);
                            if (errorCode !=
                                PurchasesErrorCode.purchaseCancelledError) {
                              debugPrint('Failed to purchase product.');
                              purchaseErrorSnackbar();
                            }
                          }
                        },
                        title: 'Buy 100 hints'.tr,
                        price:
                            getProductFromIdentifier(AppConstants.HUNDRED_HINTS)
                                    ?.priceString ??
                                '',
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        onTap: () async {
                          try {
                            CustomerInfo customerInfo =
                                await Purchases.purchaseProduct(
                                    AppConstants.FIVEHUNDRED_HINTS,
                                    type: PurchaseType.inapp);
                            debugPrint('Purchase info: $customerInfo');
                            for (int i = 1; i <= 100; i++) {
                              Get.find<HintController>().addHint(5);
                            }
                            Get.find<SoundController>().completeSound();
                          } on PlatformException catch (e) {
                            var errorCode =
                                PurchasesErrorHelper.getErrorCode(e);
                            if (errorCode !=
                                PurchasesErrorCode.purchaseCancelledError) {
                              debugPrint('Failed to purchase product. ');
                              purchaseErrorSnackbar();
                            }
                          }
                        },
                        title: 'Buy 500 hints'.tr,
                        price: getProductFromIdentifier(
                                    AppConstants.FIVEHUNDRED_HINTS)
                                ?.priceString ??
                            '',
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        active: !Get.find<ShopController>().isLevelsUnlocked,
                        onTap: () async {
                          if (!Get.find<ShopController>().isLevelsUnlocked) {
                            try {
                              //await Purchases.purchaseProduct(AppConstants.UNLOCK_LEVELS);
                              Get.find<ShopController>().levelsUnlockSave(true);
                              Get.find<SoundController>().completeSound();
                            } catch (e) {
                              debugPrint('Failed to purchase product.');
                              purchaseErrorSnackbar();
                            }
                          } else {
                            Get.snackbar(
                              'Levels unlocked',
                              'You have already removed all levels',
                              backgroundColor:
                                  AppColors.correctColor.withOpacity(0.4),
                            );
                          }
                        },
                        title: 'Unlock all levels'.tr,
                        price: !Get.find<ShopController>().isLevelsUnlocked
                            ? getProductFromIdentifier(
                                        AppConstants.UNLOCK_LEVELS)
                                    ?.priceString ??
                                '0.00 \$'
                            : 'un',
                      ),
                      /*SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        active: !Get.find<ShopController>().isAdsRemoved,
                        onTap: () async {
                          if (!Get.find<ShopController>().isLevelsUnlocked) {
                            try {
                              //await Purchases.purchaseProduct(AppConstants.ADS_REMOVE);
                              Get.find<ShopController>().removeAdsSave(true);
                              Get.find<SoundController>().completeSound();
                              debugPrint('Removed adds');
                            } catch (e) {
                              debugPrint('Failed to purchase product.');
                              purchaseErrorSnackbar();
                            }
                          } else {
                            Get.snackbar(
                              'Levels unlocked'.tr,
                              'You have already unlocked all levels'.tr,
                              backgroundColor:
                                  AppColors.correctColor.withOpacity(0.4),
                            );
                          }
                        },
                        title: 'Remove ads'.tr,
                        price: !Get.find<ShopController>().isLevelsUnlocked
                            ? getProductFromIdentifier(
                                        AppConstants.ADS_REMOVE)
                                    ?.priceString ??
                                '0.00 \$'
                            : 'un',
                      ),*/
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        onTap: () {
                          _rewardedAd?.show(
                            onUserEarnedReward: (_, reward) {
                              Get.find<HintController>().addHint(3);
                              Get.find<SoundController>().completeSound();
                            },
                          );
                        },
                        title: 'Watch video (3 hints)'.tr,
                      ),
                      /*SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        onTap: () async {
                          try {
                            // PurchaserInfo restoredInfo = await Purchases.restoreTransactions();
                            // ... check restored purchaserInfo to see if entitlement is now active
                          } on PlatformException catch (e) {
                            // Error restoring purchases
                          }
                        },
                        title: 'Restore Purchases'.tr,
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
