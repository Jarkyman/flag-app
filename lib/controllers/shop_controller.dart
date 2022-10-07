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

  final _configurationAppl =
      PurchasesConfiguration('appl_eEHKYOTQjTUkCIilqUeqEzETXQj');

  final _configurationGoog =
      PurchasesConfiguration('goog_aFvMfMgfGuwqMGeaReDwwGbqbTE');

  get getPurchasesConfiguration {
    if (Platform.isAndroid) {
      return _configurationGoog;
    } else if (Platform.isIOS) {
      return _configurationAppl;
    }
    return null;
  }

  Future<void> loadShopSettings() async {
    levelsUnlockRead();
    removeAdsRead();
    Purchases.addCustomerInfoUpdateListener(
      (_) => updateCustomerStatus(),
    );
    update();
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
