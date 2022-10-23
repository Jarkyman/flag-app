import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sound_controller.dart';
import '../helper/app_colors.dart';
import '../helper/dimensions.dart';

class HintWidget extends StatelessWidget {
  final Widget icon;
  final String num;
  final VoidCallback onTap;
  final bool disable;

  const HintWidget({
    Key? key,
    required this.icon,
    required this.onTap,
    required this.num,
    this.disable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!disable) {
          onTap();
          Get.find<SoundController>().clickSound();
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: Dimensions.width10,
          right: Dimensions.width10,
        ),
        height: Dimensions.height20 * 2,
        decoration: BoxDecoration(
          color: !disable
              ? AppColors.mainColor.withOpacity(0.2)
              : AppColors.textColorGray.withOpacity(0.2),
          borderRadius: BorderRadius.circular(Dimensions.radius20 * 2),
        ),
        child: Row(
          children: [
            Center(
              child: icon,
            ),
            SizedBox(
              width: Dimensions.width5,
            ),
            Text(
              int.parse(num) > 9999 ? '9999+' : num,
              style: TextStyle(
                color: AppColors.mainColor,
                fontSize: Dimensions.font16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
