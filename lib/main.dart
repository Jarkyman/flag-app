import 'package:flag_app/helper/locale_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'helper/dependencies.dart' as dep;
import 'helper/app_runtime.dart';
import 'helper/image_memory_manager.dart';
import 'helper/route_helper.dart';
import 'helper/screenshot_system_ui.dart';
import 'analytics/analytics_navigator_observer.dart';
import 'controllers/analytics_controller.dart';
import 'firebase_options.dart';

Future<void> main() {
  return bootstrapFlagsApp();
}

Future<void> bootstrapFlagsApp({
  AppRuntimeMode mode = AppRuntimeMode.production,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppRuntime.configure(mode);
  ImageMemoryManager.configureCache();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if (AppRuntime.isScreenshotMode) {
    await ScreenshotSystemUi.hideSystemBars();
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await dep.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocaleHandler(),
      locale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      title: 'Flags Game - Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      //home: FlagPage(),
      //home: TestPage(),
      initialRoute: RouteHelper.getSplashPage(),
      getPages: RouteHelper.routes,
      navigatorObservers: [
        AnalyticsNavigatorObserver(
          controller: Get.find<AnalyticsController>(),
        ),
      ],
    );
  }
}
