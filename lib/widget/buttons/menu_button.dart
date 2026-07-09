import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  final Color accentColor;
  final String subText;

  const MenuButton({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
    this.accentColor = AppColors.mainColor,
    this.subText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        onTap: () {
          Get.find<SoundController>().clickSound();
          onTap();
        },
        child: Ink(
          height: Dimensions.height20 * 3.7,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFFFE).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            border: Border.all(color: accentColor.withValues(alpha: 0.18)),
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
                width: Dimensions.width20 * 2.4,
                height: Dimensions.height20 * 2.4,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: Dimensions.iconSize24,
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: AutoSizeText(
                  title,
                  maxLines: 2,
                  minFontSize: Dimensions.font16,
                  stepGranularity: Dimensions.font16 / 16,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
              if (subText.isNotEmpty) ...[
                SizedBox(width: Dimensions.width10),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height10 / 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                  ),
                  child: Text(
                    subText,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: Dimensions.font16 * 0.85,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              SizedBox(width: Dimensions.width5),
              Icon(
                Icons.chevron_right_rounded,
                color: accentColor,
                size: Dimensions.iconSize24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
