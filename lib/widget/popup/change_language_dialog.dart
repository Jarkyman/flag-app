import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/controllers/level_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../helper/image_decode_size.dart';
import 'app_dialog.dart';

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
    AppDialog(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height20,
          Dimensions.width20,
          Dimensions.height25,
        ),
        child: Builder(
          builder: (context) {
            final maxListHeight = Dimensions.screenHeight * 0.55;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDialogHeader(
                  title: 'Choose Your Language'.tr,
                  icon: Icons.translate_rounded,
                ),
                SizedBox(height: Dimensions.height20),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxListHeight),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: locale.length,
                    itemBuilder: (context, index) {
                      final languageLocale = locale[index]['locale'] as Locale;
                      final isSelected = languageLocale == Get.locale;

                      return _LanguageTile(
                        name: locale[index]['name'] as String,
                        locale: languageLocale,
                        isSelected: isSelected,
                        onTap: () {
                          updateLanguage(languageLocale);
                          Get.find<LevelController>().readLevels(reset: true);
                        },
                      );
                    },
                    separatorBuilder: (_, separatorIndex) =>
                        SizedBox(height: Dimensions.height10),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
    barrierColor: Colors.black.withValues(alpha: 0.42),
  );
}

class _LanguageTile extends StatelessWidget {
  final String name;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.name,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final countryCode = locale.countryCode!.toLowerCase();

    return Material(
      color: isSelected
          ? AppColors.mainColor.withValues(alpha: 0.11)
          : AppColors.lightGreen.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        child: Container(
          constraints: BoxConstraints(minHeight: Dimensions.height20 * 3.1),
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width15,
            vertical: Dimensions.height10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(
              color: isSelected
                  ? AppColors.mainColor.withValues(alpha: 0.55)
                  : AppColors.mainColor.withValues(alpha: 0.1),
              width: Dimensions.width5 * (isSelected ? 0.3 : 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: Dimensions.width20 * 2.3,
                height: Dimensions.height30,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radius10 * 0.7),
                  border: Border.all(
                    color: AppColors.mainBlackColor.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: Dimensions.width5,
                      offset: Offset(0, Dimensions.height10 * 0.2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/image/flags/$countryCode.png',
                  fit: BoxFit.cover,
                  cacheWidth: imageDecodeWidth(
                    logicalWidth: Dimensions.width20 * 2.3,
                    devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: Dimensions.iconSize24,
                height: Dimensions.iconSize24,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.mainColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.mainColor
                        : AppColors.textColorGray.withValues(alpha: 0.45),
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: Dimensions.iconSize16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
