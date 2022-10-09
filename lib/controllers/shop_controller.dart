import 'dart:io';

import 'package:get/get.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
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
    'flags_50_hints_9',
    'flags_100_hints_17',
    'flags_500_hints_79',
    //'flags_unlock_levels',
    //'flags_remove_ads'
  ];

  late List<StoreProduct> _products;

  List<StoreProduct> get getProducts => _products;

  Future<void> loadShopSettings() async {
    levelsUnlockRead();
    removeAdsRead();
    Purchases.addCustomerInfoUpdateListener(
      (_) => updateCustomerStatus(),
    );
    _products = await Purchases.getProducts(_productsIds);
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
    final customerInfo = await Purchases.getCustomerInfo();
    final entitlementUnlock = customerInfo.entitlements.active['unlock_levels'];
    final entitlementAds = customerInfo.entitlements.active['remove_ads'];

    bool isUnlock = entitlementUnlock != null;
    bool isAdsRemove = entitlementAds != null;

    levelsUnlockSave(isUnlock);
    removeAdsSave(isAdsRemove);
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
