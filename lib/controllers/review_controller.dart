import 'dart:io';

import 'package:flag_app/helper/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rate_my_app/rate_my_app.dart';

class ReviewController {
  static const int minimumTrainingScore = 10;
  static const int minimumCompletedLevels = 10;

  static final RateMyApp rateMyApp = RateMyApp(
    minDays: 0,
    minLaunches: 1,
    remindDays: 7,
    remindLaunches: 5,
    googlePlayIdentifier: AppConstants.ANDROID_ID,
    appStoreIdentifier: AppConstants.IOS_ID,
  );

  static bool hasReachedReviewMilestone({
    required int trainingScore,
    required int completedLevels,
  }) {
    return trainingScore >= minimumTrainingScore ||
        completedLevels >= minimumCompletedLevels;
  }

  static void checkReviewPopup(
    BuildContext context, {
    int trainingScore = 0,
    int completedLevels = 0,
  }) {
    if (!hasReachedReviewMilestone(
      trainingScore: trainingScore,
      completedLevels: completedLevels,
    )) {
      return;
    }
    if (!rateMyApp.shouldOpenDialog) return;

    rateMyApp.showRateDialog(
      context,
      title: 'Rate Flags game'.tr,
      message: 'RateMsg'.tr,
      rateButton: 'RATE'.tr,
      noButton: 'NO THANKS'.tr,
      laterButton: 'MAYBE LATER'.tr,
      listener: (_) => true,
      ignoreNativeDialog: Platform.isAndroid,
      onDismissed: () =>
          rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
    );
  }
}
