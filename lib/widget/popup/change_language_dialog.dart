import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

final List locale = [
  {'name': 'Brasileiro', 'locale': Locale('pt', 'BR')},
  {'name': 'Dansk', 'locale': Locale('da', 'DK')},
  {'name': 'Deutsch', 'locale': Locale('de', 'DE')},
  {'name': 'English', 'locale': Locale('en', 'US')},
  {'name': 'Español', 'locale': Locale('es', 'ES')},
  {'name': 'Français', 'locale': Locale('fr', 'FR')},
  {'name': 'Norsk', 'locale': Locale('nb', 'NO')},
  {'name': 'Português', 'locale': Locale('pt', 'PT')},
  {'name': 'Svenska', 'locale': Locale('sv', 'SE')},
];

updateLanguage(Locale locale) {
  Get.back();
  Get.find<SettingsController>().languageSettingsSave(locale.toString());
  Get.find<CountryContinentController>().readCountries(locale);
  Get.find<CountryController>().readCountries(Get.locale!);
  Get.find<LevelController>().readLevels();
}

void buildLanguageDialog() {
  Get.defaultDialog(
    title: 'Choose Your Language'.tr,
    middleText: "",
    backgroundColor: AppColors.lightGreen,
    content: Container(
      height: Dimensions.screenHeight / 2,
      width: Dimensions.width45 * 6,
      child: SingleChildScrollView(
        child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.width10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(locale[index]['name']),
                      CircleAvatar(
                        backgroundImage: AssetImage(
                            'assets/image/flags/${locale[index]['locale'].toString().split('_')[1].toLowerCase()}.png'),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  updateLanguage(locale[index]['locale']);
                  Get.find<LevelController>().readLevels(reset: true);
                },
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: AppColors.mainColor,
              );
            },
            itemCount: locale.length),
      ),
    ),
  );
}
