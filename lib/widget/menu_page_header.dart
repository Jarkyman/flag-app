import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/hint_controller.dart';
import '../controllers/sound_controller.dart';
import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import '../helper/route_helper.dart';

class MenuPageHeader extends StatelessWidget {
  final String title;

  const MenuPageHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.height20 * 3.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width45 * 2),
            child: AutoSizeText(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mainBlackColor,
                fontSize: Dimensions.font26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            left: Dimensions.width10,
            child: MenuRoundButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: Get.back,
            ),
          ),
          Positioned(
            right: Dimensions.width10,
            child: const MenuHintBadge(),
          ),
        ],
      ),
    );
  }
}

class MenuRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MenuRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mainColor.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          Get.find<SoundController>().clickSound();
          onTap();
        },
        child: SizedBox(
          width: Dimensions.width20 * 2.2,
          height: Dimensions.height20 * 2.2,
          child: Icon(
            icon,
            color: AppColors.mainColor,
            size: Dimensions.iconSize24,
          ),
        ),
      ),
    );
  }
}

class MenuHintBadge extends StatelessWidget {
  const MenuHintBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HintController>(
      builder: (hintController) {
        final hints = hintController.getHints;
        return Material(
          color: AppColors.mainColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Dimensions.radius30),
          child: InkWell(
            borderRadius: BorderRadius.circular(Dimensions.radius30),
            onTap: () {
              Get.find<SoundController>().clickSound();
              Get.toNamed(RouteHelper.getShopPage());
            },
            child: Container(
              height: Dimensions.height20 * 2.2,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.mainColor,
                    size: Dimensions.iconSize24,
                  ),
                  SizedBox(width: Dimensions.width5),
                  Text(
                    hints > 9999 ? '9999+' : hints.toString(),
                    style: TextStyle(
                      color: AppColors.mainColor,
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
