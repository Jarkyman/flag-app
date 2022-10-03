import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/controllers/shop_controller.dart';
import 'package:flag_app/widget/Top%20bar/app_bar_row.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/app_colors.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/route_helper.dart';
import '../../../widget/buttons/level_button.dart';

class LevelsListPage extends StatelessWidget {
  const LevelsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            children: [
              AppBarRow(),
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
                          String numOfDone = levelController
                              .getFinishedLevelsForLevel(index + 1,
                                  levelController.getList(Get.arguments[0])!)
                              .toString();
                          String numTotal = levelController
                              .getUnFinishedLevels(index + 1,
                                  levelController.getList(Get.arguments[0])!)
                              .toString();
                          int levelsToComplete = (index * 10) - 11;
                          int levelsCompleted = levelController
                              .getFinishedLevels(Get.arguments[0]);
                          bool isLocked = levelController.isLevelUnlocked(
                              index, Get.arguments[0]);
                          bool levelsUnlock =
                              Get.find<ShopController>().isLevelsUnlocked;
                          bool locked = true;
                          if (levelsUnlock) {
                            locked = false;
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.height10,
                                horizontal: Dimensions.width10),
                            child: LevelButton(
                              isLocked: locked,
                              onTap: () {
                                if (!isLocked || levelsUnlock) {
                                  Get.toNamed(RouteHelper.getLevelPage(),
                                      arguments: [Get.arguments[0], index + 1]);
                                } else {
                                  Get.snackbar(
                                    'Unlock more levels'.tr,
                                    'You need to finish'.tr +
                                        ' ${levelsToComplete - levelsCompleted + 1} ' +
                                        'more, to unlock level'.tr +
                                        ' ${index + 1} ' +
                                        'more, to unlock level2'.tr,
                                    backgroundColor:
                                        AppColors.wrongColor.withOpacity(0.3),
                                  );
                                }
                              },
                              title: 'Level'.tr + ' ${index + 1}',
                              numOfDone: numOfDone,
                              numTotal: numTotal,
                            ),
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
