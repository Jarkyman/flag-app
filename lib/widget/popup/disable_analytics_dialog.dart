import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import 'app_dialog.dart';

Future<bool> showDisableAnalyticsDialog() async {
  final shouldDisable = await Get.dialog<bool>(
    AppDialog(
      accentColor: AppColors.purpleColor,
      accentEndColor: AppColors.coralColor,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogHeader(
              title: 'Turn off anonymous analytics?'.tr,
              icon: Icons.visibility_off_rounded,
              accentColor: AppColors.purpleColor,
              showCloseButton: false,
            ),
            SizedBox(height: Dimensions.height20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Dimensions.width15),
              decoration: BoxDecoration(
                color: AppColors.purpleColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                border: Border.all(
                  color: AppColors.purpleColor.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                'Analytics disable description'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mainBlackColor,
                  fontSize: Dimensions.font16 * 0.88,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            AppDialogButton(
              label: 'Keep analytics on'.tr,
              icon: Icons.favorite_rounded,
              accentColor: AppColors.purpleColor,
              onPressed: () => Get.back<bool>(result: false),
            ),
            SizedBox(height: Dimensions.height10),
            AppDialogButton(
              label: 'Turn off analytics'.tr,
              icon: Icons.visibility_off_rounded,
              primary: false,
              accentColor: AppColors.coralColor,
              onPressed: () => Get.back<bool>(result: true),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.48),
  );

  return shouldDisable ?? false;
}
