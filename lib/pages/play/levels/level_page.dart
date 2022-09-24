import 'package:flag_app/controllers/level_controller.dart';
import 'package:flag_app/helper/app_colors.dart';
import 'package:flag_app/helper/route_helper.dart';
import 'package:flag_app/models/level_model.dart';
import 'package:flag_app/widget/level_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/country_controller.dart';
import '../../../helper/dimensions.dart';

class LevelPage extends StatelessWidget {
  const LevelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${Get.arguments[1]}'),
        backgroundColor: AppColors.mainColor,
      ),
      body: Padding(
          padding: EdgeInsets.only(
            left: Dimensions.width10,
            right: Dimensions.width10,
            top: Dimensions.height30,
          ),
          child: GetBuilder<LevelController>(
            builder: (levelController) {
              print('Type = ' + Get.arguments[0].toString());
              print('Level = ' + Get.arguments[1].toString());
              List<LevelModel> levels = levelController.getLevelList(
                  Get.arguments[1], levelController.getList(Get.arguments[0])!);
              return GridView.count(
                childAspectRatio: 6 / 5,
                mainAxisSpacing: Dimensions.height20,
                crossAxisSpacing: Dimensions.height20,
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: 4,
                // Generate 100 widgets that display their index in the List.
                children: List.generate(levels.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(RouteHelper.getGuessPage(), arguments: [
                        //Get.arguments[0][index],
                        Get.arguments[0],
                        Get.arguments[1],
                        index
                      ]);
                    },
                    child: Hero(
                      tag:
                          '${Get.find<CountryController>().getCountryCode(levels[index].country!).toLowerCase()}',
                      child: LevelCard(
                        guessed: levels[index].guessed!,
                        image:
                            'assets/image/${Get.arguments[0].toString().toLowerCase()}/${Get.find<CountryController>().getCountryCode(levels[index].country!).toLowerCase()}.png',
                      ),
                    ),
                  );
                }),
              );
            },
          )),
    );
  }
}
