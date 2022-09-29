import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../controllers/hint_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../helper/route_helper.dart';
import '../hint_widget.dart';

class AppBarRow extends StatelessWidget {
  const AppBarRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width10,
          right: Dimensions.width10,
          top: Dimensions.height10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              width: Dimensions.width20 * 2,
              height: Dimensions.height20 * 2,
              decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(Dimensions.radius20 * 2),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.mainColor,
                ),
              ),
            ),
          ),
          GetBuilder<HintController>(builder: (hintController) {
            return HintWidget(
              onTap: () {
                Get.toNamed(RouteHelper.getShopPage());
              },
              icon: Icon(
                Icons.lightbulb_outline,
                color: AppColors.mainColor,
              ),
              num: hintController.getHints.toString(),
            );
          }),
        ],
      ),
    );
  }
}
