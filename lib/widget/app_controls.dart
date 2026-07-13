import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/hint_controller.dart';
import '../controllers/sound_controller.dart';
import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import '../helper/route_helper.dart';

class AppControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;
  final String? semanticLabel;
  final bool playSound;
  final double? size;

  const AppControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.accentColor = AppColors.mainColor,
    this.semanticLabel,
    this.playSound = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? Dimensions.height20 * 2.2;
    final control = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (playSound && Get.isRegistered<SoundController>()) {
            Get.find<SoundController>().clickSound();
          }
          onTap();
        },
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        child: Ink(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFCFFFE),
                accentColor.withValues(alpha: 0.13),
              ],
            ),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: Dimensions.width5 * 0.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainBlackColor.withValues(alpha: 0.06),
                blurRadius: Dimensions.radius10,
                offset: Offset(0, Dimensions.height10 * 0.3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: Dimensions.iconSize24,
          ),
        ),
      ),
    );

    if (semanticLabel == null) return control;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(message: semanticLabel!, child: control),
    );
  }
}

class AppHintBadge extends StatelessWidget {
  final bool interactive;

  const AppHintBadge({
    super.key,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HintController>(
      builder: (hintController) {
        final hints = hintController.getHints;
        final label = hints > 999 ? '999+' : hints.toString();

        return Semantics(
          button: interactive,
          label: 'Hints: $hints',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: interactive
                  ? () {
                      if (Get.isRegistered<SoundController>()) {
                        Get.find<SoundController>().clickSound();
                      }
                      Get.toNamed(RouteHelper.getShopPage());
                    }
                  : null,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Ink(
                height: Dimensions.height20 * 2.2,
                padding: EdgeInsets.fromLTRB(
                  Dimensions.width5,
                  Dimensions.height10 * 0.35,
                  Dimensions.width10,
                  Dimensions.height10 * 0.35,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFFFE).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(
                    color: AppColors.yellowColor.withValues(alpha: 0.3),
                    width: Dimensions.width5 * 0.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainBlackColor.withValues(alpha: 0.055),
                      blurRadius: Dimensions.radius10,
                      offset: Offset(0, Dimensions.height10 * 0.3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: Dimensions.width20 * 1.55,
                      height: Dimensions.height20 * 1.55,
                      decoration: BoxDecoration(
                        color: AppColors.yellowColor.withValues(alpha: 0.16),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius10),
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        color: AppColors.goldColor,
                        size: Dimensions.iconSize16,
                      ),
                    ),
                    SizedBox(width: Dimensions.width5),
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.mainBlackColor,
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
