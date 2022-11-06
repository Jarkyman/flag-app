import 'dart:io';

import 'package:flag_app/helper/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rate_my_app/rate_my_app.dart';

class ReviewController {
  static final RateMyApp rateMyApp = RateMyApp(
    minDays: 7,
    minLaunches: 15,
    remindDays: 7,
    remindLaunches: 10,
    googlePlayIdentifier: AppConstants.ANDROID_ID,
    appStoreIdentifier: AppConstants.IOS_ID,
  );

  static void checkReviewPopup(BuildContext context) {
    if (rateMyApp.shouldOpenDialog) {
      rateMyApp.showRateDialog(
        context,
        title: 'Rate Flags game'.tr,
        message: 'RateMsg'.tr,
        rateButton: 'RATE'.tr,
        noButton: 'NO THANKS'.tr,
        laterButton: 'MAYBE LATER'.tr,
        listener: (button) {
          // The button click listener (useful if you want to cancel the click event).
          switch (button) {
            case RateMyAppDialogButton.rate:
              print('Clicked on "Rate".');
              break;
            case RateMyAppDialogButton.later:
              print('Clicked on "Later".');
              break;
            case RateMyAppDialogButton.no:
              print('Clicked on "No".');
              break;
          }

          return true; // Return false if you want to cancel the click event.
        },
        ignoreNativeDialog: Platform.isAndroid,
        // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
        //dialogStyle: const DialogStyle(), // Custom dialog styles.
        onDismissed: () =>
            rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
        // actionsBuilder: (context) => [], // This one allows you to use your own buttons.
      );
    }
  }
}
