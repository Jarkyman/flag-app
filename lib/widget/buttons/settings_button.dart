import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class SettingsButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget child;

  const SettingsButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        Get.find<SoundController>().clickSound();
      },
      child: Container(
        width: Dimensions.width30 * 10,
        height: Dimensions.height20 * 4,
        decoration: BoxDecoration(
          color: AppColors.correctColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            width: 2,
            color: AppColors.mainColor,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
