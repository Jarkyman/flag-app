import 'dart:io';
import 'package:flag_app/controllers/shop_controller.dart';
import 'package:get/get.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (!Get.find<ShopController>().isAdsRemoved) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-9894760850635221/2351369277'; //'ca-app-pub-3940256099942544/6300978111'; //ca-app-pub-9894760850635221/2351369277
      } else if (Platform.isIOS) {
        return 'ca-app-pub-9894760850635221/2622546602'; //'ca-app-pub-3940256099942544/2934735716'; //ca-app-pub-9894760850635221/2622546602
      } else {
        throw new UnsupportedError('Unsupported platform');
      }
    } else {
      return 'No ad banner';
    }
  }

  static String get interstitialAdUnitId {
    if (!Get.find<ShopController>().isAdsRemoved) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-9894760850635221/5907470901'; //"ca-app-pub-3940256099942544/1033173712"; //ca-app-pub-9894760850635221/5907470901
      } else if (Platform.isIOS) {
        return 'ca-app-pub-9894760850635221/6348084916'; // "ca-app-pub-3940256099942544/4411468910"; //ca-app-pub-9894760850635221/6348084916
      } else {
        throw new UnsupportedError("Unsupported platform");
      }
    } else {
      return "no ad interstitialAd";
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9894760850635221/7336102646'; //"ca-app-pub-3940256099942544/5224354917"; //ca-app-pub-9894760850635221/7336102646
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9894760850635221/9272000845'; //"ca-app-pub-3940256099942544/1712485313"; //ca-app-pub-9894760850635221/9272000845
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}

// TEST
/*
class AdHelper {
  static String get bannerAdUnitId {
    if (!Get.find<ShopController>().isAdsRemoved) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; //'ca-app-pub-3940256099942544/6300978111'; //ca-app-pub-9894760850635221/2351369277
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; //'ca-app-pub-3940256099942544/2934735716'; //ca-app-pub-9894760850635221/2622546602
      } else {
        throw new UnsupportedError('Unsupported platform');
      }
    } else {
      return 'No ad banner';
    }
  }

  static String get interstitialAdUnitId {
    if (!Get.find<ShopController>().isAdsRemoved) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712'; //"ca-app-pub-3940256099942544/1033173712"; //ca-app-pub-9894760850635221/5907470901
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910'; // "ca-app-pub-3940256099942544/4411468910"; //ca-app-pub-9894760850635221/6348084916
      } else {
        throw new UnsupportedError("Unsupported platform");
      }
    } else {
      return "no ad interstitialAd";
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; //"ca-app-pub-3940256099942544/5224354917"; //ca-app-pub-9894760850635221/7336102646
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; //"ca-app-pub-3940256099942544/1712485313"; //ca-app-pub-9894760850635221/9272000845
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}*/
