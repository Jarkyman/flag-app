import 'dart:async';

import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/analytics_controller.dart';
import 'package:flag_app/controllers/cloud_save_controller.dart';
import 'package:flag_app/controllers/game_services_controller.dart';
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
import 'helper/app_constants.dart';
import 'helper/dimensions.dart';
import 'helper/image_decode_size.dart';
import 'helper/route_helper.dart';
import 'pages/home/home_page.dart';

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
    await Get.find<AnalyticsController>().updateAppContext(
      language: Get.locale?.toString() ?? 'en_US',
      adsRemoved: Get.find<ShopController>().isAdsRemoved,
    );
    ReviewController.rateMyApp.init();
    await _initializeCloudSync();
    if (controller.isCompleted) {
      _navigateToHome();
    } else {
      Timer(const Duration(seconds: 3), _navigateToHome);
    }
  }

  Future<void> _initializeCloudSync() async {
    final gameServicesController = Get.find<GameServicesController>();
    await gameServicesController.initialize();
    await Get.find<CloudSaveController>().syncOnLaunch();
  }

  void _navigateToHome() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        settings: RouteSettings(name: RouteHelper.getInitial()),
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    );
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
                    child: Hero(
                      tag: AppConstants.FLAG_BALL_HERO,
                      createRectTween: (begin, end) =>
                          MaterialRectCenterArcTween(begin: begin, end: end),
                      child: Image.asset(
                        'assets/image/flag_ball.png',
                        width: Dimensions.splashImg,
                        cacheWidth: imageDecodeWidth(
                          logicalWidth: Dimensions.splashImg,
                          devicePixelRatio:
                              MediaQuery.devicePixelRatioOf(context),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: Dimensions.height25,
                  right: Dimensions.width20 * 1.25,
                  child: const CircularProgressIndicator(
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
