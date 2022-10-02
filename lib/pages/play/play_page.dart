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
              AppBarRow(),
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
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        //Get.toNamed(RouteHelper.getLevelsListPage(), arguments: [AppConstants.COAT_OF_ARMS]);
                      },
                      title: 'Coat of arms'.tr,
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
