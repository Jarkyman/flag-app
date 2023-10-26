import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/controllers/shop_controller.dart';
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
  List<StoreProduct> products = [];
  bool loadingProduct = true;
  bool isAdLoaded = false;
  bool loadAd = true;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
    _loadProducts();
  }

  void _loadProducts() async {
    products = await Get.find<ShopController>().getProducts;
    print(products);
    setState(() {
      loadingProduct = false;
    });
  }

  StoreProduct? getProductFromIdentifier(String identifier) {
    StoreProduct? result;
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
    setState(() {
      loadAd = true;
      isAdLoaded = false;
    });
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
            loadAd = false;
          });
          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          setState(() {
            isAdLoaded = false;
            loadAd = false;
          });
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
      body: SwipeDetector(
        onSwipeDown: (value) {
          Get.find<SoundController>().windSound();
          Get.back();
        },
        child: BackgroundImage(
          child: SafeArea(
            child: Column(
              children: [
                const AppBarRowExit(),
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
                                    AppConstants.TEN_HINTS_ID,
                                    type: PurchaseType.inapp);
                            for (int i = 1; i <= 2; i++) {
                              Get.find<HintController>().addHint(5);
                            }
                            Get.find<SoundController>().completeSound();
                          } on PlatformException catch (e) {
                            var errorCode =
                                PurchasesErrorHelper.getErrorCode(e);
                            if (errorCode !=
                                PurchasesErrorCode.purchaseCancelledError) {
                              purchaseErrorSnackbar();
                            }
                          }
                        },
                        title: 'Buy 10 hints'.tr,
                        loading: loadingProduct,
                        price:
                            getProductFromIdentifier(AppConstants.TEN_HINTS_ID)
                                    ?.priceString ??
                                '#',
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        onTap: () async {
                          try {
                            CustomerInfo customerInfo =
                                await Purchases.purchaseProduct(
                                    AppConstants.TWENTYFIVE_HINTS_ID,
                                    type: PurchaseType.inapp);
                            for (int i = 1; i <= 5; i++) {
                              Get.find<HintController>().addHint(5);
                            }
                            Get.find<SoundController>().completeSound();
                          } on PlatformException catch (e) {
                            var errorCode =
                                PurchasesErrorHelper.getErrorCode(e);
                            if (errorCode !=
                                PurchasesErrorCode.purchaseCancelledError) {
                              purchaseErrorSnackbar();
                            }
                          }
                        },
                        title: 'Buy 25 hints'.tr,
                        loading: loadingProduct,
                        price: getProductFromIdentifier(
                                    AppConstants.TWENTYFIVE_HINTS_ID)
                                ?.priceString ??
                            '#',
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        onTap: () async {
                          try {
                            CustomerInfo customerInfo =
                                await Purchases.purchaseProduct(
                                    AppConstants.SIXTY_HINTS_ID,
                                    type: PurchaseType.inapp);
                            for (int i = 1; i <= 12; i++) {
                              Get.find<HintController>().addHint(5);
                            }
                            Get.find<SoundController>().completeSound();
                          } on PlatformException catch (e) {
                            var errorCode =
                                PurchasesErrorHelper.getErrorCode(e);
                            if (errorCode !=
                                PurchasesErrorCode.purchaseCancelledError) {
                              purchaseErrorSnackbar();
                            }
                          }
                        },
                        title: 'Buy 60 hints'.tr,
                        loading: loadingProduct,
                        price: getProductFromIdentifier(
                                    AppConstants.SIXTY_HINTS_ID)
                                ?.priceString ??
                            '#',
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      GetBuilder<ShopController>(builder: (shopController) {
                        return MenuButton(
                          active: !shopController.isLevelsUnlocked,
                          disable: shopController.isLevelsUnlocked,
                          onTap: () async {
                            if (!shopController.isLevelsUnlocked) {
                              try {
                                CustomerInfo customerInfo =
                                    await Purchases.purchaseProduct(
                                        AppConstants.UNLOCK_LEVELS_ID,
                                        type: PurchaseType.inapp);
                                debugPrint('Purchase info: $customerInfo');
                                shopController.levelsUnlockSave(true);
                                Get.find<SoundController>().completeSound();
                                debugPrint('Levels unlocked');
                              } on PlatformException catch (e) {
                                var errorCode =
                                    PurchasesErrorHelper.getErrorCode(e);
                                if (errorCode !=
                                    PurchasesErrorCode.purchaseCancelledError) {
                                  debugPrint('Failed to purchase product. ');
                                  purchaseErrorSnackbar();
                                }
                              }
                            }
                          },
                          title: 'Unlock all levels'.tr,
                          price: !shopController.isLevelsUnlocked
                              ? getProductFromIdentifier(
                                          AppConstants.UNLOCK_LEVELS_ID)
                                      ?.priceString ??
                                  '#'
                              : '',
                        );
                      }),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      GetBuilder<ShopController>(builder: (shopController) {
                        return MenuButton(
                          active: !shopController.isAdsRemoved,
                          disable: shopController.isAdsRemoved,
                          onTap: () async {
                            if (!shopController.isAdsRemoved) {
                              try {
                                CustomerInfo customerInfo =
                                    await Purchases.purchaseProduct(
                                        AppConstants.REMOVE_ADS_ID,
                                        type: PurchaseType.inapp);
                                debugPrint('Purchase info: $customerInfo');
                                shopController.removeAdsSave(true);
                                Get.find<SoundController>().completeSound();
                                debugPrint('Removed adds');
                              } on PlatformException catch (e) {
                                var errorCode =
                                    PurchasesErrorHelper.getErrorCode(e);
                                if (errorCode !=
                                    PurchasesErrorCode.purchaseCancelledError) {
                                  debugPrint('Failed to purchase product. ');
                                  purchaseErrorSnackbar();
                                }
                              }
                            }
                          },
                          title: 'Remove ads'.tr,
                          loading: loadingProduct,
                          price: !shopController.isAdsRemoved
                              ? getProductFromIdentifier(
                                          AppConstants.REMOVE_ADS_ID)
                                      ?.priceString ??
                                  '#'
                              : '',
                        );
                      }),
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
                        active: isAdLoaded,
                        loading: loadAd,
                        disable: !isAdLoaded,
                        title: 'Watch video (3 hints)'.tr,
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      MenuButton(
                        onTap: () async {
                          try {
                            CustomerInfo restoredInfo =
                                await Purchases.restorePurchases();
                            final entitlementAds = restoredInfo.entitlements
                                .all[AppConstants.REMOVE_ADS_ID_ENT]?.isActive;
                            bool isAdsRemove = entitlementAds == true;

                            Get.find<ShopController>()
                                .removeAdsSave(isAdsRemove);
                          } on PlatformException catch (e) {
                            print(e);
                          }
                        },
                        title: 'Restore Purchases'.tr,
                      ),
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
