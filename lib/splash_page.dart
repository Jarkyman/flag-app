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
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/country_continent_controller.dart';
import 'helper/dimensions.dart';
import 'helper/route_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  Future<void> _loadResource() async {
    await Get.find<SettingsController>().languageSettingRead();
    await Future.wait([
      Get.find<CountryController>().readCountries(Get.locale!),
      Get.find<CountryContinentController>().readCountries(Get.locale!),
      Get.find<ScoreController>().readAllScores(),
      Get.find<HintController>().readHints(),
      Get.find<LevelController>().readLevels(),
      Get.find<ShopController>().loadShopSettings(),
    ]);
    Get.find<LevelController>().initUnlockedLevels();
    Get.find<SoundController>().init();
    ReviewController.rateMyApp.init();
    if (controller.isCompleted) {
      Get.offNamed(RouteHelper.getInitial());
    } else {
      Timer(const Duration(seconds: 3),
          () => Get.offNamed(RouteHelper.getInitial()));
    }
  }

  @override
  void initState() {
    super.initState();
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
                const Positioned(
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
