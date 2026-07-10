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
    super.key,
    required this.icon,
    required this.onTap,
    required this.num,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    final parsedNumber = int.tryParse(num);
    final label = parsedNumber != null && parsedNumber > 9999 ? '9999+' : num;

    return AnimatedOpacity(
      opacity: disable ? 0.42 : 1,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disable
              ? null
              : () {
                  onTap();
                  if (Get.isRegistered<SoundController>()) {
                    Get.find<SoundController>().clickSound();
                  }
                },
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
            height: Dimensions.height20 * 2.2,
            decoration: BoxDecoration(
              color: const Color(0xFFFCFFFE).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(
                color: AppColors.mainColor.withValues(alpha: 0.18),
                width: Dimensions.width5 * 0.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mainBlackColor.withValues(alpha: 0.05),
                  blurRadius: Dimensions.radius10,
                  offset: Offset(0, Dimensions.height10 * 0.25),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                SizedBox(width: Dimensions.width5),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width5,
                    vertical: Dimensions.height10 * 0.15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yellowColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.mainBlackColor,
                      fontSize: Dimensions.font16 * 0.88,
                      fontWeight: FontWeight.w800,
                    ),
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
