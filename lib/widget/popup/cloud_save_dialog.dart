import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cloud_save_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import 'app_dialog.dart';

Future<void> buildCloudSaveDialog() {
  return Get.dialog<void>(
    GetBuilder<CloudSaveController>(
      builder: (controller) {
        return AppDialog(
          accentColor: AppColors.skyColor,
          accentEndColor: AppColors.purpleColor,
          child: Padding(
            padding: EdgeInsets.all(Dimensions.width20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDialogHeader(
                  title: 'Cloud save'.tr,
                  icon: Icons.cloud_done_rounded,
                  accentColor: AppColors.skyColor,
                ),
                SizedBox(height: Dimensions.height20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Dimensions.width15),
                  decoration: BoxDecoration(
                    color: AppColors.skyColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    border: Border.all(
                      color: AppColors.skyColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_sync_rounded,
                        color: AppColors.skyColor,
                        size: Dimensions.iconSize24 * 1.45,
                      ),
                      SizedBox(height: Dimensions.height10),
                      Text(
                        'Cloud save description'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.mainBlackColor,
                          fontSize: Dimensions.font16 * 0.88,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10),
                      Text(
                        _lastSaveText(controller.lastCloudSaveAt),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textColorGray,
                          fontSize: Dimensions.font16 * 0.75,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                if (controller.isBusy)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height20,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: Dimensions.iconSize24,
                          height: Dimensions.iconSize24,
                          child: const CircularProgressIndicator(
                            color: AppColors.skyColor,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        Text(
                          switch (controller.status) {
                            CloudSaveStatus.syncing => 'Syncing progress'.tr,
                            CloudSaveStatus.saving => 'Saving progress'.tr,
                            CloudSaveStatus.restoring =>
                              'Restoring progress'.tr,
                            CloudSaveStatus.idle => '',
                          },
                          style: TextStyle(
                            color: AppColors.textColorGray,
                            fontSize: Dimensions.font16 * 0.88,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  AppDialogButton(
                    label: 'Restore backup'.tr,
                    icon: Icons.cloud_download_rounded,
                    primary: false,
                    accentColor: AppColors.skyColor,
                    onPressed: () => _confirmRestore(controller),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
    barrierDismissible: false,
  );
}

Future<void> _confirmRestore(CloudSaveController controller) {
  return Get.dialog<void>(
    AppDialog(
      accentColor: AppColors.coralColor,
      accentEndColor: AppColors.yellowColor,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogHeader(
              title: 'Restore backup?'.tr,
              icon: Icons.warning_amber_rounded,
              accentColor: AppColors.coralColor,
            ),
            SizedBox(height: Dimensions.height15),
            Text(
              'Restore warning'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mainBlackColor,
                fontSize: Dimensions.font16 * 0.88,
                height: 1.35,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            AppDialogButton(
              label: 'Restore'.tr,
              icon: Icons.restore_rounded,
              accentColor: AppColors.coralColor,
              onPressed: () async {
                Get.back<void>();
                final result = await controller.restoreFromCloud();
                if (result == CloudSaveResult.success) {
                  Get.back<void>();
                }
                _showResult(result);
              },
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

String _lastSaveText(DateTime? dateTime) {
  if (dateTime == null) return 'No cloud backup yet'.tr;
  final local = dateTime.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${'Last backup'.tr}: $year-$month-$day $hour:$minute';
}

void _showResult(CloudSaveResult result) {
  final (title, message) = switch (result) {
    CloudSaveResult.success => (
        'Progress restored'.tr,
        'Cloud restore success'.tr
      ),
    CloudSaveResult.notFound => (
        'No backup found'.tr,
        'No cloud backup found'.tr
      ),
    CloudSaveResult.notSignedIn => (
        'Not connected'.tr,
        'Cloud sign in required'.tr
      ),
    CloudSaveResult.unsupported => (
        'Cloud save unavailable'.tr,
        'Cloud platform unavailable'.tr
      ),
    CloudSaveResult.invalidBackup => (
        'Backup incompatible'.tr,
        'Cloud backup incompatible'.tr
      ),
    CloudSaveResult.failed => (
        'Something went wrong'.tr,
        'Cloud operation failed'.tr
      ),
  };
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: EdgeInsets.all(Dimensions.width15),
  );
}
