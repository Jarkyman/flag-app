import 'package:flag_app/controllers/hint_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/dimensions.dart';
import 'package:flag_app/widget/background_image.dart';
import 'package:flag_app/widget/hint_widget.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_dialog/gdpr_dialog.dart';
import 'package:get/get.dart';

import '../../controllers/sound_controller.dart';
import '../../helper/route_helper.dart';
import '../../widget/buttons/menu_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = 'none';

  @override
  void initState() {
    //GdprDialog.instance.resetDecision(); //For test only
    GdprDialog.instance
        .showDialog(isForTest: false, testDeviceId: '')
        .then((onValue) {
      setState(() {
        status = 'dialog result == $onValue';
        print('RESULT = $status');
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Dimensions.width10,
                    right: Dimensions.width10,
                    top: Dimensions.height10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.find<SoundController>().clickSound();
                        Get.toNamed(RouteHelper.getSettingsPage());
                      },
                      child: Container(
                        width: Dimensions.width20 * 2,
                        height: Dimensions.height20 * 2,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius20 * 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.settings_outlined,
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
                        icon: const Icon(
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
                        Get.toNamed(RouteHelper.getPlayPage());
                      },
                      title: 'Play'.tr,
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        Get.toNamed(RouteHelper.getFlagPage());
                      },
                      title: 'Find flag'.tr,
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        Get.toNamed(RouteHelper.getFlagsPage());
                      },
                      title: 'Match flags'.tr,
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        Get.toNamed(RouteHelper.getCountriesPage());
                      },
                      title: 'Which country'.tr,
                    ),
                    /*SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        Get.toNamed(RouteHelper.getCapitalPage());
                      },
                      title: 'Capitals',
                    ),*/
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    MenuButton(
                      onTap: () {
                        Get.toNamed(RouteHelper.getShopPage());
                      },
                      title: 'Shop'.tr,
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
