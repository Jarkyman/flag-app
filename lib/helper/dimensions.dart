import 'package:get/get.dart';

class Dimensions {
  static double screenHeight = Get.context!.height; // 844 iPhone 12
  static double screenWidth = Get.context!.width; // 390 iPhone 12

  //Dynamic height, padding and margin
  static double height10 = screenHeight / 84.4;
  static double height15 = screenHeight / 56.27;
  static double height20 = screenHeight / 42.2;
  static double height25 = screenHeight / 33.76;
  static double height30 = screenHeight / 28.13;
  static double height45 = screenHeight / 18.76;

  //Dynamic width, padding and margin
  static double width5 = screenHeight / 168.8;
  static double width10 = screenHeight / 84.4;
  static double width15 = screenHeight / 56.27;
  static double width20 = screenHeight / 42.2;
  static double width30 = screenHeight / 28.13;
  static double width45 = screenHeight / 18.76;

  //Font and icons
  static double font16 = screenHeight / 52.75;
  static double font20 = screenHeight / 42.2;
  static double font26 = screenHeight / 32.46;
  static double iconSize16 = screenHeight / 52.75;
  static double iconSize24 = screenHeight / 35.17;

  //Radius
  static double radius10 = screenHeight / 84.4;
  static double radius15 = screenHeight / 56.27;
  static double radius20 = screenHeight / 42.2;
  static double radius30 = screenHeight / 28.13;

  //Dynamic pageView
  static double pageView = screenHeight / 2.64;
  static double pageViewContainer = screenHeight / 3.84;
  static double pageViewTextContainer = screenHeight / 7.03;

  //List view size
  static double listViewImgSize = screenWidth / 3.25;
  static double listViewTextContSize = screenWidth / 3.9;

  //popular food
  static double popularFoodImgSize = screenHeight / 2.41;
  static double bottomHeightBar = screenHeight / 7.03;

  //Splash Screen
  static double splashImg = screenHeight / 3.38;
}
