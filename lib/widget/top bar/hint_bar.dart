import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/hint_controller.dart';
import '../../controllers/sound_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../helper/route_helper.dart';
import '../hint_widget.dart';

class HintBar extends StatelessWidget {
  final VoidCallback tapHintOne;
  final VoidCallback tapHintTwo;
  final VoidCallback? tapHintThree;
  final Widget iconOne;
  final Widget iconTwo;
  final Widget? iconThree;
  final String hintPriceOne;
  final String hintPriceTwo;
  final String? hintPriceThree;

  const HintBar({
    Key? key,
    required this.tapHintOne,
    required this.tapHintTwo,
    this.tapHintThree,
    required this.iconOne,
    required this.iconTwo,
    this.iconThree,
    required this.hintPriceOne,
    required this.hintPriceTwo,
    this.hintPriceThree,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width10,
          right: Dimensions.width10,
          top: Dimensions.height10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GetBuilder<HintController>(builder: (hintController) {
                  return HintWidget(
                    onTap: () {
                      tapHintOne();
                    },
                    icon: iconOne,
                    num: hintPriceOne,
                  );
                }),
                SizedBox(
                  width: Dimensions.width10,
                ),
                GetBuilder<HintController>(builder: (hintController) {
                  return HintWidget(
                    onTap: () {
                      tapHintTwo();
                    },
                    icon: iconTwo,
                    num: hintPriceTwo,
                  );
                }),
                SizedBox(
                  width: Dimensions.width10,
                ),
                if (iconThree != null &&
                    tapHintThree != null &&
                    hintPriceThree != null)
                  GetBuilder<HintController>(builder: (hintController) {
                    return HintWidget(
                      onTap: () {
                        tapHintThree!();
                      },
                      icon: iconThree!,
                      num: hintPriceThree!,
                    );
                  }),
              ],
            ),
          ),
          GetBuilder<HintController>(builder: (hintController) {
            return HintWidget(
              onTap: () {
                Get.find<SoundController>().clickSound();
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
