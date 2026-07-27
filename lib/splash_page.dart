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
import 'package:flag_app/helper/app_runtime.dart';
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
  static const _platformStartupTimeout = Duration(seconds: 10);

  late Animation<double> animation;
  late AnimationController controller;

  Future<void> _loadResource() async {
    final shopController = Get.find<ShopController>();
    final analyticsController = Get.find<AnalyticsController>();
    await Get.find<SettingsController>().languageSettingRead();
    await Future.wait([
      Get.find<CountryController>().readCountries(Get.locale!),
      Get.find<CountryContinentController>().readCountries(Get.locale!),
      Get.find<ScoreController>().readAllScores(),
      Get.find<HintController>().readHints(),
      Get.find<LevelController>().readLevels(),
      shopController.loadCachedShopSettings(),
    ]);
    Get.find<LevelController>().initUnlockedLevels();
    Get.find<SoundController>().init();
    unawaited(shopController.initializePurchases());
    unawaited(
      analyticsController.updateAppContext(
        language: Get.locale?.toString() ?? 'en_US',
        adsRemoved: shopController.isAdsRemoved,
      ),
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
    if (!AppRuntime.externalServicesEnabled) return;

    final gameServicesController = Get.find<GameServicesController>();
    final cloudSaveController = Get.find<CloudSaveController>();
    gameServicesController.setPostStartupAuthenticationSync(() async {
      await cloudSaveController.syncOnLaunch();
    });
    final startupSync = _runInitialCloudSync(
      gameServicesController,
      cloudSaveController,
    );
    try {
      await startupSync.timeout(_platformStartupTimeout);
    } on TimeoutException {
      // Do not cancel the native work. It owns the initial restore and will
      // finish in the background, while the user can continue into the app.
      debugPrint(
        'Platform startup exceeded 10 seconds; continuing with local levels '
        'while cloud sync finishes in the background.',
      );
      unawaited(startupSync);
    }
  }

  Future<void> _runInitialCloudSync(
    GameServicesController gameServicesController,
    CloudSaveController cloudSaveController,
  ) async {
    try {
      await gameServicesController.initialize();
      if (!gameServicesController.isSignedIn) {
        debugPrint(
          'Startup continues offline because game services are not connected.',
        );
        return;
      }
      await cloudSaveController.syncOnLaunch();
    } catch (error, stackTrace) {
      debugPrint('Initial Game Services/cloud sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      gameServicesController.markStartupRestoreFinished();
    }
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
                        'assets/image/flag_ball.webp',
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
