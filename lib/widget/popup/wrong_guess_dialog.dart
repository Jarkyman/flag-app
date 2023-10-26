import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

void wrongGuessDialog({
  required int score,
  required bool isTryAgainUsed,
  required VoidCallback onTapConfirm,
  required VoidCallback onTapCancel,
  bool adLoaded = false,
}) {
  Get.defaultDialog(
    title: 'Wrong country'.tr,
    middleText: '${'You score is'.tr} $score',
    backgroundColor: Colors.white,
    radius: 30,
    barrierDismissible: false,
    onWillPop: () async => false,
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
                    color: adLoaded
                        ? AppColors.mainColor
                        : AppColors.textColorGray,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.ondemand_video),
                    SizedBox(
                      width: Dimensions.width10,
                    ),
                    Text(
                      'Continue'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            adLoaded ? Colors.black : AppColors.textColorGray,
                      ),
                    ),
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
          child: Center(
            child: Text('Start over'.tr),
          ),
        ),
      ),
    ),
  );
}
