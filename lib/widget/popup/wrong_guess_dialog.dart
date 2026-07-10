import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import 'app_dialog.dart';

void wrongGuessDialog({
  required int score,
  required bool isNewRecord,
  required bool isTryAgainUsed,
  required VoidCallback onTapConfirm,
  required VoidCallback onTapCancel,
  bool adLoaded = false,
}) {
  final accentColor = isNewRecord ? AppColors.goldColor : AppColors.mainColor;

  Get.dialog(
    PopScope(
      canPop: false,
      child: Stack(
        children: [
          AppDialog(
            accentColor: accentColor,
            accentEndColor:
                isNewRecord ? AppColors.yellowColor : AppColors.correctColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                Dimensions.height20,
                Dimensions.width20,
                Dimensions.height25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppDialogHeader(
                    title: isNewRecord ? 'New record!'.tr : 'Wrong country'.tr,
                    titleColor: isNewRecord
                        ? AppColors.goldColor
                        : AppColors.mainBlackColor,
                    showCloseButton: false,
                    centerTitle: true,
                  ),
                  SizedBox(height: Dimensions.height20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height20,
                    ),
                    decoration: BoxDecoration(
                      color: isNewRecord
                          ? AppColors.yellowColor.withValues(alpha: 0.15)
                          : AppColors.lightGreen.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      border: isNewRecord
                          ? Border.all(
                              color: AppColors.goldColor.withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        if (isNewRecord) ...[
                          Icon(
                            Icons.emoji_events_rounded,
                            color: AppColors.goldColor,
                            size: Dimensions.iconSize24 * 1.35,
                          ),
                          SizedBox(height: Dimensions.height10 * 0.4),
                        ],
                        Text(
                          'You score is'.tr,
                          style: TextStyle(
                            color: AppColors.textColorGray,
                            fontSize: Dimensions.font16 * 0.9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10 * 0.2),
                        Text(
                          '$score',
                          style: TextStyle(
                            color: AppColors.mainBlackColor,
                            fontSize: Dimensions.font26 * 1.3,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  if (!isTryAgainUsed) ...[
                    AppDialogButton(
                      label: 'Continue'.tr,
                      icon: Icons.ondemand_video_rounded,
                      accentColor: accentColor,
                      primaryForegroundColor:
                          isNewRecord ? AppColors.mainBlackColor : null,
                      onPressed: adLoaded
                          ? () {
                              onTapConfirm();
                              Get.find<SoundController>().clickSound();
                            }
                          : null,
                    ),
                    SizedBox(height: Dimensions.height10),
                  ],
                  AppDialogButton(
                    label: 'Start over'.tr,
                    icon: Icons.refresh_rounded,
                    primary: isTryAgainUsed,
                    accentColor: accentColor,
                    primaryForegroundColor:
                        isNewRecord ? AppColors.mainBlackColor : null,
                    onPressed: () {
                      onTapCancel();
                      Get.find<SoundController>().clickSound();
                    },
                  ),
                ],
              ),
            ),
          ),
          if (isNewRecord)
            Positioned(
              top: Dimensions.screenHeight * 0.14,
              left: Dimensions.screenWidth / 2,
              child: const IgnorePointer(child: _RecordConfetti()),
            ),
        ],
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.48),
  );
}

class _RecordConfetti extends StatefulWidget {
  const _RecordConfetti();

  @override
  State<_RecordConfetti> createState() => _RecordConfettiState();
}

class _RecordConfettiState extends State<_RecordConfetti> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(milliseconds: 1800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return const SizedBox.shrink();
    }

    return ConfettiWidget(
      confettiController: _controller,
      blastDirectionality: BlastDirectionality.explosive,
      emissionFrequency: 0.045,
      numberOfParticles: 18,
      minBlastForce: 8,
      maxBlastForce: 18,
      gravity: 0.18,
      colors: const [
        AppColors.yellowColor,
        AppColors.goldColor,
        AppColors.coralColor,
        AppColors.purpleColor,
        AppColors.skyColor,
      ],
      minimumSize: Size(
        Dimensions.width5,
        Dimensions.height10 * 0.45,
      ),
      maximumSize: Size(
        Dimensions.width10,
        Dimensions.height10 * 0.9,
      ),
    );
  }
}
