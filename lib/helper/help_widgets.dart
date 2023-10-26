import 'package:flag_app/widget/help_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';
import 'dimensions.dart';

List<HelpWidget> allHelpWidgets() {
  return [
    HelpWidget(
        icon: const Icon(
          Icons.check,
          color: AppColors.mainColor,
        ),
        description: 'Get the correct answer'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/fifty_fifty.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Remove half of the answers'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/bomb.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24,
        ),
        description: 'Remove all the wrong letters'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/a.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24,
        ),
        description: 'Get a correct Letter'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/shake.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Shake your phone to mix the letters'.tr),
  ];
}

List<HelpWidget> trainingHelpWidgets() {
  return [
    HelpWidget(
        icon: const Icon(
          Icons.check,
          color: AppColors.mainColor,
        ),
        description: 'Get the correct answer'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/fifty_fifty.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Remove half of the answers'.tr),
  ];
}

List<HelpWidget> guessHelpWidgets() {
  return [
    HelpWidget(
        icon: const Icon(
          Icons.check,
          color: AppColors.mainColor,
        ),
        description: 'Get the correct answer'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/bomb.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24,
        ),
        description: 'Remove all the wrong letters'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/a.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24,
        ),
        description: 'Get a correct Letter'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/shake.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Shake your phone to mix the letters'.tr),
    HelpWidget(
        icon: ImageIcon(
          const AssetImage('assets/icon/swipe.png'),
          color: AppColors.mainColor,
          size: Dimensions.iconSize24 * 1.4,
        ),
        description: 'Swipe between pages'.tr),
  ];
}
