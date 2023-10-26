import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/helper/help_widgets.dart';
import 'package:flag_app/widget/buttons/settings_button.dart';
import 'package:flag_app/widget/popup/help_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:share_plus/share_plus.dart';

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
                const CustomCloseButton(),
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
                        title: 'Help'.tr,
                        onTap: () {
                          helpDialog(allHelpWidgets());
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: Dimensions.width10),
                          child: const IconWidget(
                            icon: Icons.question_mark_outlined,
                          ),
                        ),
                      ),
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
                          child: const IconWidget(
                            icon: Icons.star,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      SettingsButton(
                        title: 'Share app'.tr,
                        onTap: () {
                          Share.share(
                              'Check out this app \nhttp://flagsgame.epizy.com/app');
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: Dimensions.width10),
                          child: const IconWidget(
                            icon: Icons.share,
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

class IconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconWidget({Key? key, required this.icon, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: Dimensions.iconSize16 * 2,
      color: Colors.white,
      shadows: const [
        Shadow(blurRadius: 6, color: Colors.black),
        Shadow(blurRadius: 6, color: Colors.black),
        Shadow(blurRadius: 6, color: Colors.black),
        Shadow(blurRadius: 6, color: Colors.black),
        Shadow(blurRadius: 6, color: Colors.black),
      ],
    );
  }
}
