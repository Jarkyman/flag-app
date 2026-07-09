import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/level_controller.dart';
import '../../../controllers/shop_controller.dart';
import '../../../helper/app_colors.dart';
import '../../../helper/app_constants.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/route_helper.dart';
import '../../../widget/buttons/level_button.dart';
import '../../../widget/menu_background.dart';
import '../../../widget/menu_page_header.dart';

class LevelsListPage extends StatefulWidget {
  const LevelsListPage({super.key});

  @override
  State<LevelsListPage> createState() => _LevelsListPageState();
}

class _LevelsListPageState extends State<LevelsListPage> {
  bool isSnackOpen = false;
  late String argType;

  Color get categoryColor {
    if (argType == AppConstants.FLAGS) return AppColors.coralColor;
    if (argType == AppConstants.COUNTRIES) return AppColors.skyColor;
    return AppColors.purpleColor;
  }

  IconData get categoryIcon {
    if (argType == AppConstants.FLAGS) return Icons.flag_rounded;
    if (argType == AppConstants.COUNTRIES) return Icons.public_rounded;
    return Icons.shield_outlined;
  }

  @override
  void initState() {
    super.initState();
    argType = Get.arguments[0];
  }

  void showLockedMessage({
    required LevelController levelController,
    required int index,
    required int levelsCompleted,
  }) {
    if (isSnackOpen) return;
    isSnackOpen = true;
    const Duration(seconds: 3).delay(() => isSnackOpen = false);

    final remaining =
        levelController.getLevelsToComplete(index) - levelsCompleted + 1;
    Get.snackbar(
      'Unlock more levels'.tr,
      '${'You need to finish'.tr} $remaining ${'more, to unlock level'.tr} ${index + 1} ${'more, to unlock level2'.tr}',
      backgroundColor: const Color(0xFFFCFFFE).withValues(alpha: 0.96),
      colorText: AppColors.mainBlackColor,
      icon: Icon(Icons.lock_outline_rounded, color: categoryColor),
      margin: EdgeInsets.all(Dimensions.width15),
      borderRadius: Dimensions.radius15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              MenuPageHeader(title: argType.tr),
              GetBuilder<LevelController>(
                builder: (levelController) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height10,
                    Dimensions.width20,
                    Dimensions.height10,
                  ),
                  child: _CategoryProgress(
                    icon: categoryIcon,
                    color: categoryColor,
                    done: levelController.getFinishedLevelsTotal(argType),
                    total: levelController.getAmountOfLevelsTotal(argType),
                  ),
                ),
              ),
              Expanded(
                child: GetBuilder<LevelController>(
                  builder: (levelController) {
                    return GetBuilder<ShopController>(
                      builder: (shopController) {
                        final levelsCompleted =
                            levelController.getFinishedLevels(argType);
                        final levelAmount =
                            levelController.getLevelAmount(argType);

                        return ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            Dimensions.width20,
                            Dimensions.height10,
                            Dimensions.width20,
                            Dimensions.height30,
                          ),
                          itemCount: levelAmount,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: Dimensions.height10),
                          itemBuilder: (context, index) {
                            final levelNumber = index + 1;
                            final numOfDone =
                                levelController.getFinishedLevelsForLevel(
                              levelNumber,
                              argType,
                            );
                            final numTotal =
                                levelController.getAmountOfFieldsInLevels(
                              levelNumber,
                              argType,
                            );
                            final requiresUnlock =
                                levelController.isLevelUnlocked(index, argType);
                            final locked = !shopController.isLevelsUnlocked &&
                                requiresUnlock;

                            return LevelButton(
                              levelNumber: levelNumber,
                              numOfDone: numOfDone,
                              numTotal: numTotal,
                              isLocked: locked,
                              accentColor: categoryColor,
                              onTap: () {
                                if (!locked) {
                                  Get.toNamed(
                                    RouteHelper.getLevelPage(),
                                    arguments: [argType, levelNumber],
                                  );
                                } else {
                                  showLockedMessage(
                                    levelController: levelController,
                                    index: index,
                                    levelsCompleted: levelsCompleted,
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    );
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

class _CategoryProgress extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int done;
  final int total;

  const _CategoryProgress({
    required this.icon,
    required this.color,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFFFE).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: Dimensions.width20 * 2.2,
            height: Dimensions.height20 * 2.2,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
            ),
            child: Icon(icon, color: color, size: Dimensions.iconSize24),
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radius10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: Dimensions.height10 * 0.8,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          SizedBox(width: Dimensions.width15),
          Text(
            '$done/$total',
            style: TextStyle(
              color: color,
              fontSize: Dimensions.font16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
