import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import 'app_dialog.dart';

void wrongGuessDialog({
  required int score,
  required bool isTryAgainUsed,
  required VoidCallback onTapConfirm,
  required VoidCallback onTapCancel,
  bool adLoaded = false,
}) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AppDialog(
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
              AppDialogHeader(
                title: 'Wrong country'.tr,
                icon: Icons.close_rounded,
                accentColor: AppColors.wrongColor,
                showCloseButton: false,
              ),
              SizedBox(height: Dimensions.height20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Column(
                  children: [
                    Text(
                      'You score is'.tr,
                      style: TextStyle(
                        color: AppColors.textColorGray,
                        fontSize: Dimensions.font16 * 0.9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 * 0.2),
                    Text(
                      '$score',
                      style: TextStyle(
                        color: AppColors.mainBlackColor,
                        fontSize: Dimensions.font26 * 1.3,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height20),
              if (!isTryAgainUsed) ...[
                AppDialogButton(
                  label: 'Continue'.tr,
                  icon: Icons.ondemand_video_rounded,
                  onPressed: adLoaded
                      ? () {
                          onTapConfirm();
                          Get.find<SoundController>().clickSound();
                        }
                      : null,
                ),
                SizedBox(height: Dimensions.height10),
              ],
              AppDialogButton(
                label: 'Start over'.tr,
                icon: Icons.refresh_rounded,
                primary: isTryAgainUsed,
                onPressed: () {
                  onTapCancel();
                  Get.find<SoundController>().clickSound();
                },
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.48),
  );
}
