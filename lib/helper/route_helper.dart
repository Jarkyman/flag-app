import 'package:flag_app/pages/capital_page.dart';
import 'package:flag_app/pages/flag_page.dart';
import 'package:flag_app/pages/shop/shop_page.dart';
import 'package:get/get.dart';
import '../pages/flags_page.dart';
import '../pages/home/home_page.dart';
import '../splash_page.dart';

class RouteHelper {
  static const String splashPage = '/splash-page';
  static const String initial = '/';
  static const String shopPage = '/shop-page';
  static const String flagPage = '/flag-page';
  static const String flagsPage = '/flags-page';
  static const String capitalPage = '/capital-page';

  static String getSplashPage() => '$splashPage';
  static String getInitial() => '$initial';
  static String getShopPage() => '$shopPage';
  static String getFlagPage() => '$flagPage';
  static String getFlagsPage() => '$flagsPage';
  static String getCapitalPage() => '$capitalPage';

  static List<GetPage> routes = [
    GetPage(name: splashPage, page: () => SplashScreen()),
    GetPage(name: initial, page: () => HomePage()),
    GetPage(
        name: shopPage,
        page: () => ShopPage(),
        transition: Transition.downToUp),
    GetPage(name: flagPage, page: () => FlagPage()),
    GetPage(name: flagsPage, page: () => FlagsPage()),
    GetPage(name: capitalPage, page: () => CapitalPage()),
  ];
}
