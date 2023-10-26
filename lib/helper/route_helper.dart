import 'package:flag_app/pages/play/levels/guess_page.dart';
import 'package:flag_app/pages/play/levels/levels_list_page.dart';
import 'package:flag_app/pages/settings_page.dart';
import 'package:flag_app/pages/shop/shop_page.dart';
import 'package:flag_app/pages/training/capital_page.dart';
import 'package:flag_app/pages/training/countries_page.dart';
import 'package:get/get.dart';

import '../pages/home/home_page.dart';
import '../pages/play/levels/level_page.dart';
import '../pages/play/play_page.dart';
import '../pages/training/flag_page.dart';
import '../pages/training/flags_page.dart';
import '../splash_page.dart';

class RouteHelper {
  static const String splashPage = '/splash-page';
  static const String initial = '/';
  static const String shopPage = '/shop-page';
  static const String settingsPage = '/settings-page';
  static const String playPage = '/play-page';
  static const String levelsListPage = '/levels_handeler-list-page';
  static const String levelPage = '/level-page';
  static const String guessPage = '/guess-page';
  static const String flagPage = '/flag-page';
  static const String flagsPage = '/flags-page';
  static const String capitalPage = '/capital-page';
  static const String countriesPage = '/countries-page';

  static String getSplashPage() => splashPage;

  static String getInitial() => initial;

  static String getShopPage() => shopPage;

  static String getSettingsPage() => settingsPage;

  static String getPlayPage() => playPage;

  static String getLevelsListPage() => levelsListPage;

  static String getLevelPage() => levelPage;

  static String getGuessPage() => guessPage;

  static String getFlagPage() => flagPage;

  static String getFlagsPage() => flagsPage;

  static String getCapitalPage() => capitalPage;

  static String getCountriesPage() => countriesPage;

  static List<GetPage> routes = [
    GetPage(name: splashPage, page: () => const SplashScreen()),
    GetPage(name: initial, page: () => const HomePage()),
    GetPage(
        name: shopPage,
        page: () => const ShopPage(),
        transition: Transition.downToUp),
    GetPage(
        name: settingsPage,
        page: () => const SettingsPage(),
        transition: Transition.downToUp),
    GetPage(
        name: playPage,
        page: () {
          return const PlayPage();
        }),
    GetPage(name: levelsListPage, page: () => const LevelsListPage()),
    GetPage(name: levelPage, page: () => const LevelPage()),
    GetPage(name: guessPage, page: () => const GuessPage()),
    GetPage(name: flagPage, page: () => const FlagPage()),
    GetPage(name: flagsPage, page: () => const FlagsPage()),
    GetPage(name: capitalPage, page: () => const CapitalPage()),
    GetPage(name: countriesPage, page: () => const CountriesPage()),
  ];
}
