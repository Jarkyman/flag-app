import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final bool guessed;
  final String image;
  final String option;

  const LevelCard(
      {Key? key,
      required this.guessed,
      required this.image,
      required this.option})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCountry = option == AppConstants.COUNTRIES;
    return Container(
      decoration: !isCountry
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              image: guessed
                  ? DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: AssetImage(image),
                    )
                  : DecorationImage(
                      alignment: Alignment.center,
                      fit: BoxFit.fitHeight,
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      image: AssetImage(image),
                    ),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
            ),
      child: isCountry
          ? guessed
              ? Image.asset(
                  image,
                  fit: BoxFit.cover,
                  color: AppColors.correctColor,
                )
              : Image.asset(
                  image,
                  fit: BoxFit.cover,
                  color: AppColors.textColorGray,
                  //colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
                )
          : Container(),
    );
  }
}
