import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class SettingsButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget leading;
  final Widget? trailing;

  const SettingsButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          Get.find<SoundController>().clickSound();
        },
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        child: Ink(
          height: Dimensions.height20 * 3.6,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFFFE).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            border: Border.all(
              color: AppColors.mainColor.withValues(alpha: 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainBlackColor.withValues(alpha: 0.06),
                blurRadius: Dimensions.radius15,
                offset: Offset(0, Dimensions.height10 * 0.6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: Dimensions.width20 * 2.2,
                height: Dimensions.height20 * 2.2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                clipBehavior: Clip.antiAlias,
                child: leading,
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textColorGray,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
