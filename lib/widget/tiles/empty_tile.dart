import 'package:flutter/material.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class EmptyTile extends StatelessWidget {
  final Color accentColor;
  final bool isAnswer;

  const EmptyTile({
    super.key,
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
            ? accentColor.withValues(alpha: 0.07)
            : AppColors.lightGreen.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(Dimensions.radius10 * 0.8),
        border: Border.all(
          width: Dimensions.width5 * 0.2,
          color: accentColor.withValues(alpha: isAnswer ? 0.28 : 0.12),
        ),
      ),
    );
  }
}
