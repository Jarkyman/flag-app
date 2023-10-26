import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/app_constants.dart';
import '../../helper/dimensions.dart';
import '../../helper/route_helper.dart';
import '../../widget/Top bar/app_bar_row.dart';
import '../../widget/buttons/menu_button.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            children: [
              const AppBarRow(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        Get.toNamed(RouteHelper.getLevelsListPage(),
                            arguments: [AppConstants.FLAGS]);
                      },
                      title: 'Flags'.tr,
                      subText:
                          '${Get.find<LevelController>().getFinishedLevelsTotal(AppConstants.FLAGS)}/${Get.find<LevelController>().getAmountOfLevelsTotal(AppConstants.FLAGS)}',
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        Get.toNamed(RouteHelper.getLevelsListPage(),
                            arguments: [AppConstants.COUNTRIES]);
                      },
                      title: 'Countries'.tr,
                      subText:
                          '${Get.find<LevelController>().getFinishedLevelsTotal(AppConstants.COUNTRIES)}/${Get.find<LevelController>().getAmountOfLevelsTotal(AppConstants.COUNTRIES)}',
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        Get.toNamed(RouteHelper.getLevelsListPage(),
                            arguments: [AppConstants.COC]);
                      },
                      title: 'Coat of arms'.tr,
                      subText:
                          '${Get.find<LevelController>().getFinishedLevelsTotal(AppConstants.COC)}/${Get.find<LevelController>().getAmountOfLevelsTotal(AppConstants.COC)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
