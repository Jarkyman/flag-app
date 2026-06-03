import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

final List locale = [
  {'name': 'Brasileiro', 'locale': const Locale('pt', 'BR')},
  {'name': 'Dansk', 'locale': const Locale('da', 'DK')},
  {'name': 'Deutsch', 'locale': const Locale('de', 'DE')},
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Español', 'locale': const Locale('es', 'ES')},
  {'name': 'Français', 'locale': const Locale('fr', 'FR')},
  {'name': 'Norsk', 'locale': const Locale('nb', 'NO')},
  {'name': 'Português', 'locale': const Locale('pt', 'PT')},
  {'name': 'Svenska', 'locale': const Locale('sv', 'SE')},
];

void updateLanguage(Locale locale) {
  Get.back();
  Get.find<SettingsController>().languageSettingsSave(locale.toString());
  Get.find<CountryContinentController>().readCountries(locale);
  Get.find<CountryController>().readCountries(Get.locale!);
  Get.find<LevelController>().readLevels();
}

void buildLanguageDialog() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
      ),
      backgroundColor: AppColors.lightGreen,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Your Language'.tr,
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainBlackColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  color: AppColors.mainBlackColor,
                ),
              ],
            ),
            SizedBox(height: Dimensions.height10),
            SizedBox(
              height: Dimensions.screenHeight / 2.2,
              width: Dimensions.width45 * 6,
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.height10,
                        horizontal: Dimensions.width10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locale[index]['name'],
                            style: TextStyle(
                              fontSize: Dimensions.font16,
                              color: AppColors.mainBlackColor,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage(
                              'assets/image/flags/${locale[index]['locale'].toString().split('_')[1].toLowerCase()}.png',
                            ),
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
                  return const Divider(
                    color: AppColors.mainColor,
                    thickness: 1,
                  );
                },
                itemCount: locale.length,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
