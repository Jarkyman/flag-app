import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../controllers/settings_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

final List locale = [
  {'name': 'English', 'locale': Locale('en', 'US')},
  {'name': 'Dansk', 'locale': Locale('da', 'DK')},
  {'name': 'Svensk', 'locale': Locale('sv', 'SE')},
  {'name': 'Norsk', 'locale': Locale('nb', 'NO')},
  {'name': 'Español', 'locale': Locale('es', 'ES')},
];
updateLanguage(Locale locale) {
  Get.back();
  Get.find<SettingsController>().languageSettingsSave(locale.toString());
}

void buildLanguageDialog() {
  Get.defaultDialog(
    title: 'Choose Your Language'.tr,
    middleText: "",
    backgroundColor: AppColors.lightGreen,
    content: Flexible(
      child: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
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
    ),
  );
}
