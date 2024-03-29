import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/hint_controller.dart';
import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../hint_widget.dart';

class AppBarRowExit extends StatelessWidget {
  const AppBarRowExit({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width10,
          right: Dimensions.width10,
          top: Dimensions.height10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
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
          GetBuilder<HintController>(builder: (hintController) {
            return HintWidget(
              onTap: () {},
              icon: const Icon(
                Icons.lightbulb_outline,
                color: AppColors.mainColor,
              ),
              num: hintController.getHints.toString(),
            );
          }),
        ],
      ),
    );
  }
}
