import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class ShopButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String price;
  final bool loading;
  final bool disabled;
  final bool purchased;

  const ShopButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.price = '',
    this.loading = false,
    this.disabled = false,
    this.purchased = false,
  });

  bool get _isAvailable => !loading && !disabled && price != '#';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isAvailable
            ? () {
                onTap();
                Get.find<SoundController>().clickSound();
              }
            : null,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        child: Ink(
          height: Dimensions.height20 * 3.8,
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15,
            vertical: Dimensions.height10,
          ),
          decoration: BoxDecoration(
            color: purchased || disabled
                ? AppColors.lightGreen.withValues(alpha: 0.62)
                : const Color(0xFFFCFFFE).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(Dimensions.radius20),
            border: Border.all(
              color: purchased
                  ? AppColors.correctColor.withValues(alpha: 0.38)
                  : AppColors.mainColor.withValues(alpha: 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainBlackColor.withValues(alpha: 0.06),
                blurRadius: Dimensions.radius15,
                offset: Offset(0, Dimensions.height10 * 0.6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: Dimensions.width20 * 2.3,
                height: Dimensions.height20 * 2.3,
                decoration: BoxDecoration(
                  color:
                      (purchased ? AppColors.correctColor : AppColors.mainColor)
                          .withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Icon(
                  purchased ? Icons.check_rounded : icon,
                  color:
                      purchased ? AppColors.correctColor : AppColors.mainColor,
                  size: Dimensions.iconSize24,
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: disabled && !purchased
                        ? AppColors.textColorGray
                        : AppColors.mainBlackColor,
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width10),
              _ShopButtonTrailing(
                price: price,
                loading: loading,
                purchased: purchased,
                disabled: disabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopButtonTrailing extends StatelessWidget {
  final String price;
  final bool loading;
  final bool purchased;
  final bool disabled;

  const _ShopButtonTrailing({
    required this.price,
    required this.loading,
    required this.purchased,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        width: Dimensions.iconSize24,
        height: Dimensions.iconSize24,
        child: CircularProgressIndicator(
          color: AppColors.mainColor,
          strokeWidth: Dimensions.width5 / 2,
        ),
      );
    }

    if (purchased) {
      return Icon(
        Icons.check_circle_rounded,
        color: AppColors.correctColor,
        size: Dimensions.iconSize24,
      );
    }

    if (price == '#') {
      return Icon(
        Icons.cloud_off_outlined,
        color: AppColors.textColorGray,
        size: Dimensions.iconSize24,
      );
    }

    if (price.isNotEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width10,
          vertical: Dimensions.height10,
        ),
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(Dimensions.radius10),
        ),
        child: Text(
          price,
          style: TextStyle(
            color: Colors.white,
            fontSize: Dimensions.font16 * 0.9,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Icon(
      Icons.chevron_right_rounded,
      color: disabled ? AppColors.textColorGray : AppColors.mainColor,
    );
  }
}
