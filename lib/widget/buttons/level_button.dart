import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class LevelButton extends StatelessWidget {
  final VoidCallback onTap;
  final int levelNumber;
  final int numOfDone;
  final int numTotal;
  final bool isLocked;
  final Color accentColor;

  const LevelButton({
    super.key,
    required this.onTap,
    required this.levelNumber,
    required this.numOfDone,
    required this.numTotal,
    this.isLocked = false,
    this.accentColor = AppColors.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = numTotal == 0 ? 0.0 : numOfDone / numTotal;
    final isComplete = numTotal > 0 && numOfDone == numTotal;
    final stateColor = isLocked
        ? AppColors.textColorGray
        : isComplete
            ? AppColors.correctColor
            : accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        onTap: () {
          onTap();
          if (isLocked) {
            Get.find<SoundController>().disabledSound();
          } else {
            Get.find<SoundController>().clickSound();
          }
        },
        child: Ink(
          height: Dimensions.height20 * 4.2,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFFFE).withValues(
              alpha: isLocked ? 0.72 : 0.95,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            border: Border.all(color: stateColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainBlackColor.withValues(alpha: 0.05),
                blurRadius: Dimensions.radius15,
                offset: Offset(0, Dimensions.height10 * 0.5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: Dimensions.width20 * 2.5,
                height: Dimensions.height20 * 2.5,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: isLocked
                    ? Icon(
                        Icons.lock_outline_rounded,
                        color: stateColor,
                        size: Dimensions.iconSize24,
                      )
                    : Text(
                        '$levelNumber',
                        style: TextStyle(
                          color: stateColor,
                          fontSize: Dimensions.font20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'Level'.tr} $levelNumber',
                      style: TextStyle(
                        color: isLocked
                            ? AppColors.textColorGray
                            : AppColors.mainBlackColor,
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 * 0.6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: Dimensions.height10 * 0.6,
                              backgroundColor:
                                  stateColor.withValues(alpha: 0.12),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(stateColor),
                            ),
                          ),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          '$numOfDone/$numTotal',
                          style: TextStyle(
                            color: stateColor,
                            fontSize: Dimensions.font16 * 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Icon(
                isComplete
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: stateColor,
                size: Dimensions.iconSize24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
