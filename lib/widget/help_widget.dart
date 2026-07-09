import 'package:flutter/material.dart';

import '../helper/app_colors.dart';
import '../helper/dimensions.dart';

class HelpWidget extends StatelessWidget {
  final Widget icon;
  final String description;

  const HelpWidget({
    super.key,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width15,
        vertical: Dimensions.height10,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          color: AppColors.mainColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: Dimensions.width20 * 2.1,
            height: Dimensions.height20 * 2.1,
            padding: EdgeInsets.all(Dimensions.width10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
            ),
            child: icon,
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: AppColors.mainBlackColor,
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
