import 'dart:async';

import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/controllers/review_controller.dart';
import 'package:flag_app/controllers/score_controller.dart';
import 'package:flag_app/controllers/settings_controller.dart';
import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/controllers/sound_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'controllers/country_continent_controller.dart';
import 'helper/dimensions.dart';
import 'helper/route_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  Future<void> _loadResource() async {
    print('loading countries');
    await Get.find<CountryController>().readCountries(Get.locale!);
    print('loaded countries');
    print('loading continents');
    await Get.find<CountryContinentController>().readCountries(Get.locale!);
    print('loaded continents');
    print('loading score');
    await Get.find<ScoreController>().readAllScores();
    print('loaded score');
    print('loading hints');
    await Get.find<HintController>().readHints();
    print('loaded hints');
    print('loading levels');
    await Get.find<LevelController>().readLevels();
    Get.find<LevelController>().initUnlockedLevels();
    print('loaded countries');
    print('loading sound');
    await Get.find<SoundController>().init();
    print('loaded sound');
    print('loaded settings');
    await Get.find<SettingsController>().languageSettingRead();
    print('loaded settings');
    print('loading shop');
    await Get.find<ShopController>().loadShopSettings();
    print('loaded shop');
    print('loading review');
    ReviewController.rateMyApp.init().then((_) {
      for (var condition in ReviewController.rateMyApp.conditions) {
        if (condition is DebuggableCondition) {
          print(condition.valuesAsString);
        }
      }
    });
    print('loaded review');
    print(
        'Unlocked levels flag = ${Get.find<LevelController>().getUnlockedFlagLevels}');
    print(
        'Unlocked levels flag = ${Get.find<LevelController>().getUnlockedCountryLevels}');
    print(
        'Unlocked levels flag = ${Get.find<LevelController>().getUnlockedCOCLevels}');
    if (controller.isCompleted) {
      Get.offNamed(RouteHelper.getInitial());
    } else {
      Timer(Duration(seconds: 3), () => Get.offNamed(RouteHelper.getInitial()));
      //Timer(Duration(seconds: 3), () => Get.off(TestPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    //TODO: ADD timer to match end of load
    _loadResource();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..forward();
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                ScaleTransition(
                  scale: animation,
                  child: Center(
                    child: Image.asset(
                      'assets/image/flag_ball.png',
                      width: Dimensions.splashImg,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  right: 25,
                  child: CircularProgressIndicator(
                    color: AppColors.mainColor,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
