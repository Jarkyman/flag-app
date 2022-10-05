import 'package:get/get.dart';

import '../repos/shop_repo.dart';

class ShopController extends GetxController implements GetxService {
  final ShopRepo shopRepo;

  ShopController({required this.shopRepo});

  bool _levelsUnlocked = false;

  bool get isLevelsUnlocked => _levelsUnlocked;

  bool _adsRemoved = false;

  bool get isAdsRemoved => _adsRemoved;

  Future<void> loadShopSettings() async {
    levelsUnlockRead();
    removeAdsRead();
    update();
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
