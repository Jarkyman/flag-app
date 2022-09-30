import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;

  const MenuButton({
    Key? key,
    required this.onTap,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Dimensions.width30 * 10,
        height: Dimensions.height20 * 4,
        decoration: BoxDecoration(
          color: AppColors.correctColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            width: 2,
            color: AppColors.mainColor,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
