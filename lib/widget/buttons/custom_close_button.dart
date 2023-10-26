import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              borderRadius: BorderRadius.circular(Dimensions.radius20 * 2),
            ),
            child: const Center(
              child: Icon(
                Icons.close,
                color: AppColors.mainColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
