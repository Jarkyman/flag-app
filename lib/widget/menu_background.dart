import 'package:flutter/material.dart';

import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import 'background_image.dart';

class MenuBackground extends StatelessWidget {
  final Widget child;

  const MenuBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Stack(
        children: [
          Positioned(
            top: -Dimensions.height45,
            right: -Dimensions.width45,
            child: _MenuBubble(
              size: Dimensions.height45 * 3.4,
              color: AppColors.mainColor,
            ),
          ),
          Positioned(
            top: Dimensions.height45 * 4.2,
            left: -Dimensions.width45 * 1.6,
            child: _MenuBubble(
              size: Dimensions.height45 * 2.4,
              color: AppColors.yellowColor,
            ),
          ),
          Positioned(
            bottom: -Dimensions.height45,
            right: -Dimensions.width45 * 1.2,
            child: _MenuBubble(
              size: Dimensions.height45 * 3,
              color: AppColors.skyColor,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _MenuBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _MenuBubble({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}
