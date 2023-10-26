import 'package:shared_preferences/shared_preferences.dart';

import '../helper/app_constants.dart';

class ShopRepo {
  final SharedPreferences sharedPreferences;

  ShopRepo({
    required this.sharedPreferences,
  });

  Future<bool> levelsUnlockRead() async {
    bool levelsUnlocked =
        sharedPreferences.getBool(AppConstants.UNLOCK_LEVELS) ?? false;
    return levelsUnlocked;
  }

  Future<bool> levelsUnlockSave(bool unlock) async {
    return await sharedPreferences.setBool(AppConstants.UNLOCK_LEVELS, unlock);
  }

  Future<bool> removeAdsRead() async {
    bool removeAds =
        sharedPreferences.getBool(AppConstants.ADS_REMOVE) ?? false;
    return removeAds;
  }

  Future<bool> removeAdsSave(bool removeAds) async {
    return await sharedPreferences.setBool(AppConstants.ADS_REMOVE, removeAds);
  }
}
