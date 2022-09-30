import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/pages/capital_page.dart';
import 'package:flag_app/pages/countries_page.dart';
import 'package:flag_app/pages/flag_page.dart';
import 'package:flag_app/pages/play/levels/guess_page.dart';
import 'package:flag_app/pages/play/levels/levels_list_page.dart';
import 'package:flag_app/pages/settings_page.dart';
import 'package:flag_app/pages/shop/shop_page.dart';
import 'package:get/get.dart';
import '../pages/flags_page.dart';
import '../pages/home/home_page.dart';
import '../pages/play/levels/level_page.dart';
import '../pages/play/play_page.dart';
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

  static String getSplashPage() => '$splashPage';
  static String getInitial() => '$initial';
  static String getShopPage() => '$shopPage';
  static String getSettingsPage() => '$settingsPage';
  static String getPlayPage() => '$playPage';
  static String getLevelsListPage() => '$levelsListPage';
  static String getLevelPage() => '$levelPage';
  static String getGuessPage() => '$guessPage';
  static String getFlagPage() => '$flagPage';
  static String getFlagsPage() => '$flagsPage';
  static String getCapitalPage() => '$capitalPage';
  static String getCountriesPage() => '$countriesPage';

  static List<GetPage> routes = [
    GetPage(name: splashPage, page: () => SplashScreen()),
    GetPage(name: initial, page: () => HomePage()),
    GetPage(
        name: shopPage,
        page: () => ShopPage(),
        transition: Transition.downToUp),
    GetPage(
        name: settingsPage,
        page: () => SettingsPage(),
        transition: Transition.downToUp),
    GetPage(
        name: playPage,
        page: () {
          return PlayPage();
        }),
    GetPage(name: levelsListPage, page: () => LevelsListPage()),
    GetPage(name: levelPage, page: () => LevelPage()),
    GetPage(name: guessPage, page: () => GuessPage()),
    GetPage(name: flagPage, page: () => FlagPage()),
    GetPage(name: flagsPage, page: () => FlagsPage()),
    GetPage(name: capitalPage, page: () => CapitalPage()),
    GetPage(name: countriesPage, page: () => CountriesPage()),
  ];
}
