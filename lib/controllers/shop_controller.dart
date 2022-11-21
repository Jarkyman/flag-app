import 'dart:io';

import 'package:flag_app/helper/app_constants.dart';
import 'package:flutter/services.dart';
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
    AppConstants.TEN_HINTS_ID,
    AppConstants.TWENTYFIVE_HINTS_ID,
    AppConstants.SIXTY_HINTS_ID,
    AppConstants.REMOVE_ADS_ID,
    AppConstants.UNLOCK_LEVELS_ID,
  ];

  List<StoreProduct> _products = [];

  Future<List<StoreProduct>> get getProducts async {
    _products =
        await Purchases.getProducts(_productsIds, type: PurchaseType.inapp);
    return _products;
  }

  Future<void> loadShopSettings() async {
    await initPlatformState();
    levelsUnlockRead();
    removeAdsRead();
    Purchases.addCustomerInfoUpdateListener(
      (_) => updateCustomerStatus(),
    );
    try {
      _products =
          await Purchases.getProducts(_productsIds, type: PurchaseType.inapp);
    } catch (e) {
      print(e);
      _products = [];
    }

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

  Future updateCustomerStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      final entitlementAds = customerInfo
          .entitlements.all[AppConstants.Remove_ADS_ID_ENT]?.isActive;
      final entitlementLevel = customerInfo
          .entitlements.all[AppConstants.UNLOCK_LEVELS_ID_ENT]?.isActive;

      bool isAdsRemove = entitlementAds == true;
      bool isUnlockLevels = entitlementLevel == true;

      levelsUnlockSave(isUnlockLevels);
      removeAdsSave(isAdsRemove);
    } on PlatformException catch (e) {
      print(e);
    }
  }

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
