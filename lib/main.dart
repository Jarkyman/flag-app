import 'package:flag_app/helper/locale_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'helper/dependencies.dart' as dep;
import 'helper/image_memory_manager.dart';
import 'helper/route_helper.dart';
import 'analytics/analytics_navigator_observer.dart';
import 'controllers/analytics_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ImageMemoryManager.configureCache();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dep.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
