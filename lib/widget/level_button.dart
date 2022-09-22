import 'package:flutter/material.dart';

import '../helper/app_colors.dart';
import '../helper/dimensions.dart';

class LevelButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String numOfDone;
  final String numTotal;

  const LevelButton({
    Key? key,
    required this.onTap,
    required this.title,
    required this.numOfDone,
    required this.numTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Dimensions.width30 * 10,
        height: Dimensions.height20 * 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            width: 2,
            color: AppColors.mainColor,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 4,
              top: 4,
              child: Text('$numOfDone/$numTotal'),
            ),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
