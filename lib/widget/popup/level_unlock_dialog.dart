import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

void levelUnlockDialog(
    {required int level,
    required VoidCallback onTapConfirm,
    required VoidCallback onTapCancel}) {
  Get.defaultDialog(
    title: 'Unlock level',
    middleText: 'You unlocked a new level: $level',
    backgroundColor: Colors.white,
    radius: 30,
    barrierDismissible: false,
    confirm: GestureDetector(
      onTap: onTapCancel,
      child: Padding(
        padding: EdgeInsets.only(
          left: Dimensions.width10,
          right: Dimensions.width10,
          bottom: Dimensions.height10,
        ),
        child: Container(
          height: Dimensions.height20 * 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              width: 2,
              color: AppColors.mainColor,
            ),
          ),
          child: Center(child: Text('Cancel')),
        ),
      ),
    ),
    cancel: GestureDetector(
      onTap: onTapConfirm,
      child: Padding(
        padding: EdgeInsets.only(
          left: Dimensions.width10,
          right: Dimensions.width10,
          bottom: Dimensions.height10,
        ),
        child: Container(
          height: Dimensions.height20 * 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              width: 2,
              color: AppColors.mainColor,
            ),
          ),
          child: Center(
            child: Text('Go to Level $level'),
          ),
        ),
      ),
    ),
  );
}
