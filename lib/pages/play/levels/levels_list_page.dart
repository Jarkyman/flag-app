import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/widget/Top%20bar/app_bar_row.dart';
import 'package:flag_app/widget/background_image.dart';
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
                          bool isLocked = levelsToComplete >= levelsCompleted;
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.height10,
                                horizontal: Dimensions.width10),
                            child: LevelButton(
                              isLocked: isLocked,
                              onTap: () {
                                if (!isLocked) {
                                  Get.toNamed(RouteHelper.getLevelPage(),
                                      arguments: [Get.arguments[0], index + 1]);
                                } else {
                                  Get.snackbar(
                                    'Unlock more levels',
                                    'You need to unlock ${levelsToComplete - levelsCompleted + 1} to unlock next level',
                                    backgroundColor:
                                        AppColors.wrongColor.withOpacity(0.3),
                                  );
                                }
                              },
                              title: 'Level ${index + 1}',
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
