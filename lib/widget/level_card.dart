import 'package:flutter/material.dart';

import '../helper/app_colors.dart';
import '../helper/app_constants.dart';
import '../helper/dimensions.dart';
import '../helper/image_decode_size.dart';

class LevelCard extends StatelessWidget {
  final bool guessed;
  final String image;
  final String option;
  final int number;

  const LevelCard({
    super.key,
    required this.guessed,
    required this.image,
    required this.option,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFFFE).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          color: (guessed ? AppColors.correctColor : AppColors.mainColor)
              .withValues(alpha: guessed ? 0.34 : 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainBlackColor.withValues(alpha: 0.07),
            blurRadius: Dimensions.radius15,
            offset: Offset(0, Dimensions.height10 * 0.5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(Dimensions.width10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radius10),
                child: _LevelImage(
                  guessed: guessed,
                  image: image,
                  isCountry: option == AppConstants.COUNTRIES,
                ),
              ),
            ),
          ),
          Positioned(
            left: Dimensions.width5,
            top: Dimensions.height10 / 2,
            child: Container(
              width: Dimensions.width20 * 1.5,
              height: Dimensions.height20 * 1.5,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFCFFFE).withValues(alpha: 0.92),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.mainColor.withValues(alpha: 0.16),
                ),
              ),
              child: Text(
                '$number',
                style: TextStyle(
                  color: AppColors.mainBlackColor,
                  fontSize: Dimensions.font16 * 0.75,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (guessed)
            Positioned(
              right: Dimensions.width5,
              top: Dimensions.height10 / 2,
              child: Container(
                width: Dimensions.width20 * 1.5,
                height: Dimensions.height20 * 1.5,
                decoration: const BoxDecoration(
                  color: AppColors.correctColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: Dimensions.iconSize16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelImage extends StatelessWidget {
  final bool guessed;
  final String image;
  final bool isCountry;

  const _LevelImage({
    required this.guessed,
    required this.image,
    required this.isCountry,
  });

  @override
  Widget build(BuildContext context) {
    final cacheWidth = imageDecodeWidth(
      logicalWidth: Dimensions.screenWidth / 3,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );

    if (isCountry) {
      return Image.asset(
        image,
        fit: BoxFit.contain,
        color: guessed ? AppColors.correctColor : AppColors.textColorGray,
        cacheWidth: cacheWidth,
      );
    }

    final imageWidget = Image.asset(
      image,
      fit: BoxFit.contain,
      cacheWidth: cacheWidth,
    );
    if (guessed) return imageWidget;

    return ColorFiltered(
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
      child: imageWidget,
    );
  }
}
