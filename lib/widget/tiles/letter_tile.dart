import 'package:flutter/material.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final Color accentColor;
  final bool isAnswer;

  const LetterTile({
    super.key,
    required this.letter,
    this.accentColor = AppColors.mainColor,
    this.isAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenWidth / 12,
      width: Dimensions.screenWidth / 12,
      decoration: BoxDecoration(
        color: isAnswer
            ? accentColor.withValues(alpha: 0.12)
            : const Color(0xFFFCFFFE),
        borderRadius: BorderRadius.circular(Dimensions.radius10 * 0.8),
        border: Border.all(
          width: Dimensions.width5 * 0.2,
          color: accentColor.withValues(alpha: isAnswer ? 0.55 : 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainBlackColor.withValues(alpha: 0.06),
            blurRadius: Dimensions.radius10 * 0.6,
            offset: Offset(0, Dimensions.height10 * 0.25),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: AppColors.mainBlackColor,
            fontSize: Dimensions.font16 * 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
