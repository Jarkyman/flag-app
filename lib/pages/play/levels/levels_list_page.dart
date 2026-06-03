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

class LevelsListPage extends StatefulWidget {
  const LevelsListPage({super.key});

  @override
  State<LevelsListPage> createState() => _LevelsListPageState();
}

class _LevelsListPageState extends State<LevelsListPage> {
  bool isSnackOpen = false;
  late String argType;

  @override
  void initState() {
    super.initState();
    argType = Get.arguments[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppBarRow(),
              SizedBox(
                height: Dimensions.height20,
              ),
              Expanded(
                child: GetBuilder<LevelController>(
                  builder: (levelController) {
                    debugPrint('Type = $argType');
                    return ListView.builder(
                        itemCount:
                            levelController.getLevelAmount(argType),
                        itemBuilder: (context, index) {
                          String numOfDone = levelController
                              .getFinishedLevelsForLevel(
                                  index + 1, argType)
                              .toString();

                          String numTotal = levelController
                              .getAmountOfFieldsInLevels(
                                  index + 1, argType)
                              .toString();

                          int levelsCompleted = levelController
                              .getFinishedLevels(argType);

                          bool isLocked = levelController.isLevelUnlocked(
                              index, argType);
                          return GetBuilder<ShopController>(
                              builder: (shopController) {
                            bool levelsUnlock = shopController.isLevelsUnlocked;

                            bool locked = true;
                            if (levelsUnlock) {
                              locked = false;
                            } else if (!isLocked) {
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
                                        arguments: [
                                          argType,
                                          index + 1
                                        ]);
                                  } else {
                                    if (!isSnackOpen) {
                                      isSnackOpen = true;
                                      const Duration(seconds: 3).delay(() {
                                        isSnackOpen = false;
                                      });
                                      Get.snackbar(
                                        'Unlock more levels'.tr,
                                        '${'You need to finish'.tr} ${levelController.getLevelsToComplete(index) - levelsCompleted + 1} ${'more, to unlock level'.tr} ${index + 1} ${'more, to unlock level2'.tr}',
                                        backgroundColor: AppColors.wrongColor
                                            .withValues(alpha: 0.3),
                                      );
                                    }
                                  }
                                },
                                title: '${'Level'.tr} ${index + 1}',
                                numOfDone: numOfDone,
                                numTotal: numTotal,
                              ),
                            );
                          });
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
