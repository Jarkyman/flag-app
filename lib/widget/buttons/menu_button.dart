import 'package:flag_app/controllers/sound_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subText;
  final String price;
  final bool active;
  final bool disable;
  final bool loading;

  const MenuButton({
    Key? key,
    required this.onTap,
    required this.title,
    this.subText = '',
    this.price = '',
    this.active = true,
    this.loading = false,
    this.disable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        Get.find<SoundController>().clickSound();
      },
      child: Container(
        width: Dimensions.screenWidth / 1.4,
        height: Dimensions.height20 * 4,
        decoration: BoxDecoration(
          color: disable
              ? AppColors.textColorGray.withOpacity(0.3)
              : AppColors.correctColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            width: 2,
            color: active ? AppColors.mainColor : AppColors.textColorGray,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (price != '' || price == '#') Expanded(child: Container()),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Dimensions.font20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (price != '' || price == '#') Expanded(child: Container()),
                  if (price != '' && price != '#')
                    Padding(
                      padding: EdgeInsets.only(right: Dimensions.width10),
                      child: Text(
                        price,
                        style: TextStyle(
                          fontSize: Dimensions.font20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (price == '#' && !loading)
                    Padding(
                        padding: EdgeInsets.only(right: Dimensions.width10),
                        child: Icon(Icons.not_interested_outlined)),
                ],
              ),
            ),
            if (loading)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.width10),
                  child: CircularProgressIndicator(
                    color: AppColors.mainColor,
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            Positioned(
              right: 4,
              top: 4,
              child: Text(
                subText,
                style: TextStyle(
                  color: AppColors.textColorGray,
                  fontSize: Dimensions.font16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
