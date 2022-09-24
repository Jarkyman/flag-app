import 'package:flag_app/controllers/level_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/hint_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/app_constants.dart';
import '../../helper/dimensions.dart';
import '../../helper/route_helper.dart';
import '../../widget/hint_widget.dart';
import '../../widget/menu_button.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({Key? key}) : super(key: key);

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
                    title: 'Flags',
                  ),
                  SizedBox(
                    height: Dimensions.height20,
                  ),
                  MenuButton(
                    onTap: () {
                      Get.toNamed(RouteHelper.getLevelsListPage(),
                          arguments: [AppConstants.COUNTRIES]);
                    },
                    title: 'Countries',
                  ),
                  SizedBox(
                    height: Dimensions.height20,
                  ),
                  MenuButton(
                    onTap: () {
                      //Get.toNamed(RouteHelper.getLevelsListPage(), arguments: [AppConstants.CAPITALS]);
                    },
                    title: 'Capitals',
                  ),
                  SizedBox(
                    height: Dimensions.height20,
                  ),
                  MenuButton(
                    onTap: () {
                      //Get.toNamed(RouteHelper.getLevelsListPage(), arguments: [AppConstants.COAT_OF_ARMS]);
                    },
                    title: 'Coat of arms',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
