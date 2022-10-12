import 'dart:io';

import 'package:flag_app/helper/app_constants.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../repos/shop_repo.dart';

class ShopController extends GetxController implements GetxService {
  final ShopRepo shopRepo;

  ShopController({required this.shopRepo});

  bool _levelsUnlocked = false;

  bool get isLevelsUnlocked => _levelsUnlocked;

  bool _adsRemoved = false;

  bool get isAdsRemoved => _adsRemoved;

  final List<String> _productsIds = [
    AppConstants.FIFTY_HINTS,
    AppConstants.HUNDRED_HINTS,
    AppConstants.FIVEHUNDRED_HINTS,
    //'flags_unlock_levels',
    //'flags_remove_ads'
  ];

  List<StoreProduct> _products = [];

  List<StoreProduct> get getProducts => _products;

  Future<void> loadShopSettings() async {
    await initPlatformState();
    levelsUnlockRead();
    removeAdsRead();
    /*Purchases.addCustomerInfoUpdateListener(
      (_) => updateCustomerStatus(),
    );*/
    _products = await Purchases.getProducts(_productsIds);
    print(_products);
    update();
  }

  Future<void> initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration =
          PurchasesConfiguration("goog_aFvMfMgfGuwqMGeaReDwwGbqbTE");
    } else if (Platform.isIOS) {
      configuration =
          PurchasesConfiguration("appl_eEHKYOTQjTUkCIilqUeqEzETXQj");
    }
    await Purchases.configure(configuration!);
  }

  /*Future updateCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    final entitlementUnlock = customerInfo.entitlements.active['unlock_levels'];
    final entitlementAds = customerInfo.entitlements.active['remove_ads'];

    bool isUnlock = entitlementUnlock != null;
    bool isAdsRemove = entitlementAds != null;

    levelsUnlockSave(isUnlock);
    removeAdsSave(isAdsRemove);
  }*/

  Future<void> levelsUnlockRead() async {
    _levelsUnlocked = await shopRepo.levelsUnlockRead();
  }

  Future<void> levelsUnlockSave(bool unlock) async {
    _levelsUnlocked = unlock;
    await shopRepo.levelsUnlockSave(unlock);
    update();
  }

  Future<void> removeAdsRead() async {
    _adsRemoved = await shopRepo.levelsUnlockRead();
  }

  Future<void> removeAdsSave(bool removeAds) async {
    _adsRemoved = removeAds;
    await shopRepo.levelsUnlockSave(removeAds);
    update();
  }
}
