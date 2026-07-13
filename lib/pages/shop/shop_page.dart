import 'dart:async';

import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/controllers/analytics_controller.dart';
import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/ad_helper.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../widget/app_swipe_detector.dart';
import '../../widget/buttons/shop_button.dart';
import '../../widget/menu_page_header.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

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

  Future<void> _loadProducts() async {
    try {
      final loadedProducts = await Get.find<ShopController>().getProducts;
      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        loadingProduct = false;
      });
    } catch (error) {
      debugPrint('Failed to load products: $error');
      if (!mounted) return;

      setState(() {
        products = [];
        loadingProduct = false;
      });
    }
  }

  StoreProduct? getProductFromIdentifier(String identifier) {
    for (final product in products) {
      if (product.identifier == identifier) return product;
    }
    return null;
  }

  String _priceFor(String identifier) {
    return getProductFromIdentifier(identifier)?.priceString ?? '#';
  }

  Future<void> _purchaseProduct({
    required String identifier,
    required VoidCallback onPurchased,
  }) async {
    final product = getProductFromIdentifier(identifier);
    if (product == null) return;

    try {
      await Purchases.purchase(PurchaseParams.storeProduct(product));
      onPurchased();
      unawaited(
        Get.find<AnalyticsController>().purchaseCompleted(
          productId: identifier,
        ),
      );
      if (identifier == AppConstants.REMOVE_ADS_ID) {
        unawaited(
          Get.find<AnalyticsController>().updateAppContext(
            language: Get.locale?.toString() ?? 'en_US',
            adsRemoved: true,
          ),
        );
      }
      Get.find<SoundController>().completeSound();
    } on PlatformException catch (error) {
      final errorCode = PurchasesErrorHelper.getErrorCode(error);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        unawaited(
          Get.find<AnalyticsController>().purchaseFailed(
            productId: identifier,
            reason: errorCode.name,
          ),
        );
        purchaseErrorSnackbar();
      }
    }
  }

  void _addHints(int incrementsOfFive) {
    for (var i = 0; i < incrementsOfFive; i++) {
      Get.find<HintController>().addHint(5);
    }
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
              if (!mounted) return;
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _rewardedAd = ad;
            isAdLoaded = true;
            loadAd = false;
          });
        },
        onAdFailedToLoad: (error) {
          if (!mounted) return;
          setState(() {
            isAdLoaded = false;
            loadAd = false;
          });
          debugPrint('Failed to load a rewarded ad: ${error.message}');
        },
      ),
    );
  }

  void purchaseErrorSnackbar() {
    Get.snackbar(
      'Purchase failed'.tr,
      'Failed to buy, try again later'.tr,
      backgroundColor: AppColors.wrongColor.withValues(alpha: 0.18),
      colorText: AppColors.mainBlackColor,
    );
  }

  Future<void> _restorePurchases() async {
    try {
      final restoredInfo = await Purchases.restorePurchases();
      final entitlementAds = restoredInfo
          .entitlements.all[AppConstants.REMOVE_ADS_ID_ENT]?.isActive;
      await Get.find<ShopController>().removeAdsSave(entitlementAds == true);
    } on PlatformException catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppSwipeDetector(
        onSwipeDown: () {
          Get.find<SoundController>().windSound();
          Get.back();
        },
        child: BackgroundImage(
          child: SafeArea(
            child: Column(
              children: [
                MenuPageHeader(
                  title: 'Shop'.tr,
                  leadingIcon: Icons.close_rounded,
                  leadingAccentColor: AppColors.coralColor,
                  trailing: const MenuHintBadge(interactive: false),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      Dimensions.width20,
                      Dimensions.height15,
                      Dimensions.width20,
                      Dimensions.height30,
                    ),
                    child: Column(
                      children: [
                        ShopButton(
                          title: 'Buy 10 hints'.tr,
                          icon: Icons.lightbulb_outline_rounded,
                          loading: loadingProduct,
                          price: _priceFor(AppConstants.TEN_HINTS_ID),
                          onTap: () => _purchaseProduct(
                            identifier: AppConstants.TEN_HINTS_ID,
                            onPurchased: () => _addHints(2),
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        ShopButton(
                          title: 'Buy 25 hints'.tr,
                          icon: Icons.lightbulb_outline_rounded,
                          loading: loadingProduct,
                          price: _priceFor(AppConstants.TWENTYFIVE_HINTS_ID),
                          onTap: () => _purchaseProduct(
                            identifier: AppConstants.TWENTYFIVE_HINTS_ID,
                            onPurchased: () => _addHints(5),
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        ShopButton(
                          title: 'Buy 60 hints'.tr,
                          icon: Icons.lightbulb_outline_rounded,
                          loading: loadingProduct,
                          price: _priceFor(AppConstants.SIXTY_HINTS_ID),
                          onTap: () => _purchaseProduct(
                            identifier: AppConstants.SIXTY_HINTS_ID,
                            onPurchased: () => _addHints(12),
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        GetBuilder<ShopController>(
                          builder: (shopController) {
                            final purchased = shopController.isLevelsUnlocked;
                            return ShopButton(
                              title: 'Unlock all levels'.tr,
                              icon: Icons.lock_open_rounded,
                              loading: loadingProduct && !purchased,
                              price: purchased
                                  ? ''
                                  : _priceFor(AppConstants.UNLOCK_LEVELS_ID),
                              disabled: purchased,
                              purchased: purchased,
                              onTap: () => _purchaseProduct(
                                identifier: AppConstants.UNLOCK_LEVELS_ID,
                                onPurchased: () =>
                                    shopController.levelsUnlockSave(true),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: Dimensions.height10),
                        GetBuilder<ShopController>(
                          builder: (shopController) {
                            final purchased = shopController.isAdsRemoved;
                            return ShopButton(
                              title: 'Remove ads'.tr,
                              icon: Icons.block_rounded,
                              loading: loadingProduct && !purchased,
                              price: purchased
                                  ? ''
                                  : _priceFor(AppConstants.REMOVE_ADS_ID),
                              disabled: purchased,
                              purchased: purchased,
                              onTap: () => _purchaseProduct(
                                identifier: AppConstants.REMOVE_ADS_ID,
                                onPurchased: () =>
                                    shopController.removeAdsSave(true),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: Dimensions.height10),
                        ShopButton(
                          title: 'Watch video (3 hints)'.tr,
                          icon: Icons.ondemand_video_rounded,
                          loading: loadAd,
                          disabled: !isAdLoaded,
                          onTap: () {
                            _rewardedAd?.show(
                              onUserEarnedReward: (_, reward) {
                                Get.find<HintController>().addHint(3);
                                unawaited(
                                  Get.find<AnalyticsController>()
                                      .rewardedAdCompleted(
                                    placement: 'shop_hints',
                                  ),
                                );
                                Get.find<SoundController>().completeSound();
                              },
                            );
                          },
                        ),
                        SizedBox(height: Dimensions.height10),
                        ShopButton(
                          title: 'Restore Purchases'.tr,
                          icon: Icons.restore_rounded,
                          onTap: _restorePurchases,
                        ),
                      ],
                    ),
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
