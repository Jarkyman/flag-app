import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/helper/help_widgets.dart';
import 'package:flag_app/widget/buttons/settings_button.dart';
import 'package:flag_app/widget/popup/help_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/sound_controller.dart';
import '../controllers/ad_consent_controller.dart';
import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import '../widget/app_swipe_detector.dart';
import '../widget/background_image.dart';
import '../widget/buttons/credits_button.dart';
import '../widget/menu_page_header.dart';
import '../widget/popup/change_language_dialog.dart';
import '../widget/popup/cloud_save_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppSwipeDetector(
        onSwipeDown: () {
          Get.find<SoundController>().windSound();
          Get.back();
        },
        child: BackgroundImage(
          child: SafeArea(
            child: Column(
              children: [
                MenuPageHeader(
                  title: '_Settings'.tr,
                  leadingIcon: Icons.close_rounded,
                  leadingAccentColor: AppColors.coralColor,
                  showHintBadge: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      Dimensions.width20,
                      Dimensions.height15,
                      Dimensions.width20,
                      Dimensions.height20,
                    ),
                    child: Column(
                      children: [
                        SettingsButton(
                          title: 'Language'.tr,
                          onTap: () {
                            buildLanguageDialog();
                          },
                          leading: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width5,
                              vertical: Dimensions.height10,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radius10 / 2),
                              child: Image.asset(
                                'assets/image/flags/${Get.locale!.countryCode!.toLowerCase()}.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        GetBuilder<SoundController>(builder: (soundController) {
                          return SettingsButton(
                            title: 'Sound'.tr,
                            onTap: () {
                              soundController.soundSettingsSave(
                                  !soundController.getSoundOn);
                            },
                            leading: Icon(
                              soundController.getSoundOn
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: AppColors.mainColor,
                            ),
                            trailing: Switch(
                              value: soundController.getSoundOn,
                              onChanged: (value) {
                                soundController.soundSettingsSave(value);
                              },
                              activeThumbColor: AppColors.mainColor,
                              inactiveThumbColor: AppColors.mainColor,
                              inactiveTrackColor: AppColors.textColorGray,
                            ),
                          );
                        }),
                        SizedBox(height: Dimensions.height10),
                        SettingsButton(
                          title: 'Cloud save'.tr,
                          onTap: buildCloudSaveDialog,
                          leading: const Icon(
                            Icons.cloud_done_rounded,
                            color: AppColors.skyColor,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        GetBuilder<AdConsentController>(
                          builder: (adConsentController) {
                            if (!adConsentController.isPrivacyOptionsRequired) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                SettingsButton(
                                  title: 'Ad privacy choices'.tr,
                                  onTap: () async {
                                    final shown = await adConsentController
                                        .showPrivacyOptions();
                                    if (!shown &&
                                        adConsentController.lastError != null) {
                                      Get.snackbar(
                                        'Something went wrong'.tr,
                                        'Could not open ad privacy choices'.tr,
                                        snackPosition: SnackPosition.BOTTOM,
                                        margin: EdgeInsets.all(
                                          Dimensions.width15,
                                        ),
                                      );
                                    }
                                  },
                                  leading: const Icon(
                                    Icons.privacy_tip_rounded,
                                    color: AppColors.purpleColor,
                                  ),
                                  trailing: adConsentController.isLoading
                                      ? SizedBox(
                                          width: Dimensions.iconSize24,
                                          height: Dimensions.iconSize24,
                                          child:
                                              const CircularProgressIndicator(
                                            color: AppColors.purpleColor,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : null,
                                ),
                                SizedBox(height: Dimensions.height10),
                              ],
                            );
                          },
                        ),
                        SettingsButton(
                          title: 'Help'.tr,
                          onTap: () {
                            helpDialog(allHelpWidgets());
                          },
                          leading: const Icon(
                            Icons.question_mark_rounded,
                            color: AppColors.mainColor,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        SettingsButton(
                          title: 'Review app'.tr,
                          onTap: () {
                            LaunchReview.launch(
                                androidAppId: AppConstants.ANDROID_ID,
                                iOSAppId: AppConstants.IOS_ID);
                          },
                          leading: const Icon(
                            Icons.star_rounded,
                            color: AppColors.yellowColor,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10),
                        SettingsButton(
                          title: 'Share app'.tr,
                          onTap: () {
                            SharePlus.instance.share(ShareParams(
                                text:
                                    'Check out this app \nhttps://hartvigsolutions.com/#flags-game/download'));
                          },
                          leading: const Icon(
                            Icons.ios_share_rounded,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CreditsButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
