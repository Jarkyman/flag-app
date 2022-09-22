import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/widget/level_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/hint_controller.dart';
import '../../../helper/app_colors.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/route_helper.dart';
import '../../../widget/hint_widget.dart';

class LevelsListPage extends StatelessWidget {
  const LevelsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: Dimensions.width10, right: Dimensions.width10),
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
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius20 * 2),
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
            ),
            SizedBox(
              height: Dimensions.height20,
            ),
            Expanded(
              child: GetBuilder<LevelController>(
                builder: (levelController) {
                  print('Type =' + Get.arguments[0]);
                  return ListView.builder(
                      itemCount: levelController.getLevelAmount(
                          levelController.getList(Get.arguments[0])!),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                              horizontal: Dimensions.width10),
                          child: LevelButton(
                            onTap: () {
                              Get.toNamed(RouteHelper.getLevelPage(),
                                  arguments: [
                                    //levelController.getLevelList(index + 1, Get.arguments[0]),
                                    Get.arguments[0],
                                    index + 1
                                  ]);
                            },
                            title: 'Level ${index + 1}',
                            numOfDone: levelController
                                .getFinishedLevels(index + 1,
                                    levelController.getList(Get.arguments[0])!)
                                .toString(),
                            numTotal: levelController
                                .getUnFinishedLevels(index + 1,
                                    levelController.getList(Get.arguments[0])!)
                                .toString(),
                          ),
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
