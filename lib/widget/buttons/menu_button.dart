import 'package:flag_app/controllers/sound_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String price;
  final bool active;
  final bool loading;

  const MenuButton({
    Key? key,
    required this.onTap,
    required this.title,
    this.price = '',
    this.active = true,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        Get.find<SoundController>().clickSound();
      },
      child: Container(
        width: Dimensions.width30 * 10,
        height: Dimensions.height20 * 4,
        decoration: BoxDecoration(
          color: AppColors.correctColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            width: 2,
            color: active ? AppColors.mainColor : AppColors.textColorGray,
          ),
        ),
        child: Center(
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
              if (loading && price == '#')
                Padding(
                  padding: EdgeInsets.only(right: Dimensions.width10),
                  child: CircularProgressIndicator(
                    color: AppColors.mainColor,
                    strokeWidth: 2.0,
                  ),
                ),
              if (price == '#' && !loading)
                Padding(
                    padding: EdgeInsets.only(right: Dimensions.width10),
                    child: Icon(Icons.not_interested_outlined)),
            ],
          ),
        ),
      ),
    );
  }
}
