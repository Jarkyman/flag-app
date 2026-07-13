import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/level_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/app_constants.dart';
import '../../helper/dimensions.dart';
import '../../helper/route_helper.dart';
import '../../widget/buttons/menu_button.dart';
import '../../widget/menu_background.dart';
import '../../widget/menu_page_header.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuBackground(
        child: SafeArea(
          child: Column(
            children: [
              MenuPageHeader(title: 'Play'.tr),
              Expanded(
                child: GetBuilder<LevelController>(
                  builder: (levelController) => SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      Dimensions.width20,
                      Dimensions.height30,
                      Dimensions.width20,
                      Dimensions.height30,
                    ),
                    child: Column(
                      children: [
                        MenuButton(
                          onTap: () => Get.toNamed(
                            RouteHelper.getLevelsListPage(),
                            arguments: [AppConstants.FLAGS],
                          ),
                          title: 'Flags'.tr,
                          icon: Icons.flag_rounded,
                          accentColor: AppColors.coralColor,
                          subText:
                              '${levelController.getFinishedLevelsTotal(AppConstants.FLAGS)}/${levelController.getAmountOfLevelsTotal(AppConstants.FLAGS)}',
                        ),
                        SizedBox(height: Dimensions.height15),
                        MenuButton(
                          onTap: () => Get.toNamed(
                            RouteHelper.getLevelsListPage(),
                            arguments: [AppConstants.COUNTRIES],
                          ),
                          title: 'Countries'.tr,
                          icon: Icons.public_rounded,
                          accentColor: AppColors.skyColor,
                          subText:
                              '${levelController.getFinishedLevelsTotal(AppConstants.COUNTRIES)}/${levelController.getAmountOfLevelsTotal(AppConstants.COUNTRIES)}',
                        ),
                        SizedBox(height: Dimensions.height15),
                        MenuButton(
                          onTap: () => Get.toNamed(
                            RouteHelper.getLevelsListPage(),
                            arguments: [AppConstants.COC],
                          ),
                          title: 'Coat of arms'.tr,
                          icon: Icons.shield_outlined,
                          accentColor: AppColors.purpleColor,
                          subText:
                              '${levelController.getFinishedLevelsTotal(AppConstants.COC)}/${levelController.getAmountOfLevelsTotal(AppConstants.COC)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
