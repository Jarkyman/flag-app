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
  final bool disableOne;
  final bool disableTwo;
  final bool disableTree;

  const HintBar({
    Key? key,
    required this.tapHintOne,
    required this.iconOne,
    required this.hintPriceOne,
    this.disableOne = false,
    required this.tapHintTwo,
    required this.iconTwo,
    required this.hintPriceTwo,
    this.disableTwo = false,
    this.tapHintThree,
    this.iconThree,
    this.hintPriceThree,
    this.disableTree = false,
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
                    disable: disableOne,
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
                    disable: disableTwo,
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
                      disable: disableTree,
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
              icon: const Icon(
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
