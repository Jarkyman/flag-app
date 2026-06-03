import 'dart:io';

import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (!Get.find<ShopController>().isAdsRemoved) {
      if (kDebugMode) {
        if (Platform.isAndroid) {
          return 'ca-app-pub-3940256099942544/6300978111';
        } else if (Platform.isIOS) {
          return 'ca-app-pub-3940256099942544/2934735716';
        }
      }

      if (Platform.isAndroid) {
        return 'ca-app-pub-9894760850635221/2351369277';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-9894760850635221/2622546602';
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    } else {
      return 'No ad banner';
    }
  }

  static String get interstitialAdUnitId {
    if (!Get.find<ShopController>().isAdsRemoved) {
      if (kDebugMode) {
        if (Platform.isAndroid) {
          return 'ca-app-pub-3940256099942544/1033173712';
        } else if (Platform.isIOS) {
          return 'ca-app-pub-3940256099942544/4411468910';
        }
      }

      if (Platform.isAndroid) {
        return 'ca-app-pub-9894760850635221/5907470901';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-9894760850635221/6348084916';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      return "no ad interstitialAd";
    }
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9894760850635221/7336102646';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9894760850635221/9272000845';
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
