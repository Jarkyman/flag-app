import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

void wrongGuessDialog(
    {required int score,
    required bool isTryAgainUsed,
    required VoidCallback onTapConfirm,
    required VoidCallback onTapCancel}) {
  Get.defaultDialog(
    title: 'Wrong country',
    middleText: 'You score is $score',
    backgroundColor: Colors.white,
    radius: 30,
    barrierDismissible: false,
    confirm: isTryAgainUsed
        ? Container()
        : GestureDetector(
            onTap: () {
              onTapConfirm();
              Get.find<SoundController>().clickSound();
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: Dimensions.width10,
                right: Dimensions.width10,
                bottom: Dimensions.height10,
              ),
              child: Container(
                height: Dimensions.height20 * 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(
                    width: 2,
                    color: AppColors.mainColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.ondemand_video),
                    SizedBox(
                      width: Dimensions.width5,
                    ),
                    const Text('Get one more try'),
                  ],
                ),
              ),
            ),
          ),
    cancel: GestureDetector(
      onTap: () {
        onTapCancel();
        Get.find<SoundController>().clickSound();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: Dimensions.width10,
          right: Dimensions.width10,
          bottom: Dimensions.height10,
        ),
        child: Container(
          height: Dimensions.height20 * 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              width: 2,
              color: AppColors.mainColor,
            ),
          ),
          child: const Center(
            child: Text('Try Again'),
          ),
        ),
      ),
    ),
  );
}
