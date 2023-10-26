import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';

class GuessButton extends StatelessWidget {
  String country;
  VoidCallback onTap;
  Color color;
  Color textColor;
  Color borderColor;

  GuessButton({
    Key? key,
    required this.country,
    required this.onTap,
    this.color = Colors.white,
    required this.textColor,
    required this.borderColor,
  }) : super(key: key);

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
    );
  }
}
