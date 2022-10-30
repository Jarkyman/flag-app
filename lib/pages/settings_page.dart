import 'package:flag_app/controllers/review_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/widget/buttons/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:launch_review/launch_review.dart';

import '../controllers/sound_controller.dart';
import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import '../widget/background_image.dart';
import '../widget/buttons/credits_button.dart';
import '../widget/buttons/custom_close_button.dart';
import '../widget/popup/change_language_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SwipeDetector(
        onSwipeDown: (value) {
          Get.find<SoundController>().windSound();
          Get.back();
        },
        child: BackgroundImage(
          child: SafeArea(
            child: Column(
              children: [
                CustomCloseButton(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      SettingsButton(
                        title: 'Language'.tr,
                        onTap: () {
                          buildLanguageDialog();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: Dimensions.width10),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/image/flags/${Get.locale.toString().split("_")[1].toLowerCase()}.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      GetBuilder<SoundController>(builder: (soundController) {
                        return SettingsButton(
                          title: 'Sound'.tr,
                          onTap: () {
                            soundController
                                .soundSettingsSave(!soundController.getSoundOn);
                          },
                          child: Switch(
                            value: soundController.getSoundOn,
                            onChanged: (value) {
                              soundController.soundSettingsSave(value);
                            },
                            activeColor: AppColors.mainColor,
                            inactiveThumbColor: AppColors.mainColor,
                            inactiveTrackColor: AppColors.textColorGray,
                          ),
                        );
                      }),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      SettingsButton(
                        title: 'Review app'.tr,
                        onTap: () {
                          LaunchReview.launch(
                              androidAppId: AppConstants.ANDROID_ID,
                              iOSAppId: AppConstants.IOS_ID);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: Dimensions.width10),
                          child: Icon(
                            Icons.star,
                            size: 32,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 6, color: Colors.black),
                              Shadow(blurRadius: 6, color: Colors.black),
                              Shadow(blurRadius: 6, color: Colors.black),
                              Shadow(blurRadius: 6, color: Colors.black),
                              Shadow(blurRadius: 6, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container()),
                CreditsButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
