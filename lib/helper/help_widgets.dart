import 'package:flag_app/widget/help_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';
import 'dimensions.dart';

List<HelpWidget> allHelpWidgets() {
  return [
    HelpWidget(
        icon: Icon(
          Icons.check,
          color: AppColors.mainColor,
        ),
        description: 'Get the correct answer'.tr),
    HelpWidget(
        icon: ImageIcon(
          AssetImage('assets/icon/fifty_fifty.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Remove half the answers'),
    HelpWidget(
        icon: ImageIcon(
          AssetImage('assets/icon/bomb.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24,
        ),
        description: 'Remove all the wrong letters'),
    HelpWidget(
        icon: ImageIcon(
          AssetImage('assets/icon/a.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24,
        ),
        description: 'Get a correct Letter'),
    HelpWidget(
        icon: ImageIcon(
          AssetImage('assets/icon/shake.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Shake your phone to mix the letters'),
  ];
}

List<HelpWidget> trainingHelpWidgets() {
  return [
    HelpWidget(
        icon: Icon(
          Icons.check,
          color: AppColors.mainColor,
        ),
        description: 'Get the correct answer'.tr),
    HelpWidget(
        icon: ImageIcon(
          AssetImage('assets/icon/fifty_fifty.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Remove half the answers'),
  ];
}

List<HelpWidget> guessHelpWidgets() {
  return [
    HelpWidget(
        icon: Icon(
          Icons.check,
          color: AppColors.mainColor,
        ),
        description: 'Get the correct answer'.tr),
    HelpWidget(
        icon: ImageIcon(
          AssetImage('assets/icon/bomb.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24,
        ),
        description: 'Remove all the wrong letters'),
    HelpWidget(
        icon: ImageIcon(
          AssetImage('assets/icon/a.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24,
        ),
        description: 'Get a correct Letter'),
    HelpWidget(
        icon: ImageIcon(
          AssetImage('assets/icon/shake.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Shake your phone to mix the letters'),
  ];
}
