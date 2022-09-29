import 'package:flutter/material.dart';

import '../helper/app_colors.dart';
import '../helper/dimensions.dart';

class LevelButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String numOfDone;
  final String numTotal;
  final bool isLocked;

  const LevelButton({
    Key? key,
    required this.onTap,
    required this.title,
    required this.numOfDone,
    required this.numTotal,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Dimensions.height20 * 4,
        decoration: BoxDecoration(
          color: AppColors.mainColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            width: 2,
            color: isLocked ? AppColors.textColorGray : AppColors.mainColor,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 4,
              top: 4,
              child: Text(
                '$numOfDone/$numTotal',
                style: TextStyle(
                    color: isLocked ? AppColors.textColorGray : Colors.black),
              ),
            ),
            isLocked
                ? Positioned(
                    left: 10,
                    top: 10,
                    child: Icon(
                      Icons.lock_outline,
                      size: Dimensions.iconSize24 * 1.4,
                      color: AppColors.textColorGray,
                    ),
                  )
                : Container(),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w500,
                  color: isLocked ? AppColors.textColorGray : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
