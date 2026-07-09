import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import 'app_dialog.dart';

void levelUnlockDialog(
    {required int level,
    required VoidCallback onTapConfirm,
    required VoidCallback onTapCancel}) {
  Get.dialog(
    AppDialog(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height20,
          Dimensions.width20,
          Dimensions.height25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppDialogHeader(
              title: 'Unlock level',
              icon: Icons.emoji_events_outlined,
              accentColor: AppColors.yellowColor,
              showCloseButton: false,
            ),
            SizedBox(height: Dimensions.height20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Dimensions.width20),
              decoration: BoxDecoration(
                color: AppColors.yellowColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radius20),
              ),
              child: Text(
                'You unlocked a new level: $level',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mainBlackColor,
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            AppDialogButton(
              label: 'Go to Level $level',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                onTapConfirm();
                Get.find<SoundController>().clickSound();
              },
            ),
            SizedBox(height: Dimensions.height10),
            AppDialogButton(
              label: 'Cancel',
              primary: false,
              onPressed: () {
                onTapCancel();
                Get.find<SoundController>().clickSound();
              },
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.48),
  );
}
