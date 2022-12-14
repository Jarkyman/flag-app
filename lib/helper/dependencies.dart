import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/controllers/settings_controller.dart';
import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/controllers/sound_controller.dart';
import 'package:flag_app/repos/country_continent_repo.dart';
import 'package:flag_app/repos/country_repo.dart';
import 'package:flag_app/repos/hint_repo.dart';
import 'package:flag_app/repos/level_repo.dart';
import 'package:flag_app/repos/score_repo.dart';
import 'package:flag_app/repos/settings_repo.dart';
import 'package:flag_app/repos/shop_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_handler.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  await MobileAds.instance.initialize().then((initializationStatus) {
    initializationStatus.adapterStatuses.forEach((key, value) {
      debugPrint('Adapter status for $key: ${value.description}');
    });
  });
  await LocaleHandler.initLanguages();

  //Repo
  Get.lazyPut(() => CountryRepo());
  Get.lazyPut(() => CountryContinentRepo());
  Get.lazyPut(() => ScoreRepo(sharedPreferences: sharedPreferences));
  Get.lazyPut(() => HintRepo(sharedPreferences: sharedPreferences));
  Get.lazyPut(() => LevelRepo(sharedPreferences: sharedPreferences));
  Get.lazyPut(() => SettingsRepo(sharedPreferences: sharedPreferences));
  Get.lazyPut(() => ShopRepo(sharedPreferences: sharedPreferences));

  //Controller
  Get.lazyPut(() => CountryController(countryRepo: Get.find()));
  Get.lazyPut(() => CountryContinentController(continentRepo: Get.find()));
  Get.lazyPut(() => ScoreController(scoreRepo: Get.find()));
  Get.lazyPut(() => HintController(hintRepo: Get.find()));
  Get.lazyPut(() => LevelController(levelRepo: Get.find()));
  Get.lazyPut(() => SoundController(settingsRepo: Get.find()));
  Get.lazyPut(() => SettingsController(settingsRepo: Get.find()));
  Get.lazyPut(() => ShopController(shopRepo: Get.find()));
}
