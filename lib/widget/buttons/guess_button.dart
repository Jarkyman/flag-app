import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GuessButton extends StatelessWidget {
  final String country;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final Color borderColor;

  const GuessButton({
    super.key,
    required this.country,
    required this.onTap,
    this.color = Colors.white,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: Dimensions.height20),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: Dimensions.width30),
          width: double.maxFinite,
          height: Dimensions.height20 * 2.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Dimensions.radius10),
            border: Border.all(
              width: 2,
              color: borderColor,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                spreadRadius: 2,
                offset: Offset(1, 5),
                color: AppColors.lightGreen,
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.height10),
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  country,
                  style: TextStyle(
                    fontSize: Dimensions.font26,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(target: color == AppColors.wrongColor ? 1 : 0)
        .shake(duration: 400.ms, hz: 4, offset: const Offset(5, 0))
        .animate(target: color == AppColors.correctColor ? 1 : 0)
        .scale(
            duration: 300.ms,
            curve: Curves.easeOutBack,
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05));
  }
}
