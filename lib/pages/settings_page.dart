import 'package:flag_app/widget/buttons/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:get/get.dart';
import '../controllers/sound_controller.dart';
import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import '../widget/background_image.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SwipeDetector(
          onSwipeDown: (value) {
            Get.find<SoundController>().windSound();
            Get.back();
          },
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(Dimensions.height10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        Get.find<SoundController>().clickSound();
                        Get.back();
                      },
                      child: Container(
                        width: Dimensions.width20 * 2,
                        height: Dimensions.height20 * 2,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius20 * 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      SettingsButton(
                        title: 'Sound',
                        onTap: () {},
                        onSwitch: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
