import 'dart:ui';

import 'package:flag_app/controllers/country_controller.dart';
import 'package:flag_app/repos/settings_repo.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController implements GetxService {
  final SettingsRepo settingsRepo;
  Locale _locale = const Locale('en', 'US');

  SettingsController({required this.settingsRepo});

  Future<void> languageSettingRead() async {
    String localeString = await settingsRepo.languageSettingRead();
    List<String> localeList = localeString.toString().split('_');
    _locale = Locale(localeList[0], localeList[1]);
    Get.updateLocale(_locale);
    Get.find<CountryController>().readCountries(_locale);
  }

  Future<void> languageSettingsSave(String language) async {
    _locale = Locale(language.split('_')[0], language.split('_')[1]);
    settingsRepo.languageSettingsSave(language);
    Get.updateLocale(_locale);
  }
}
