import 'dart:ui';

import 'package:flag_app/repos/settings_repo.dart';
import 'package:get/get.dart';

import 'analytics_controller.dart';

class SettingsController extends GetxController implements GetxService {
  final SettingsRepo settingsRepo;
  Locale _locale = const Locale('en', 'US');
  bool _firstGuessHelp = false;
  bool _firstTrainHelp = false;

  bool get getFirstGuessHelp => _firstGuessHelp;
  bool get getFirstTrainHelp => _firstTrainHelp;

  SettingsController({required this.settingsRepo});

  Future<void> languageSettingRead() async {
    String localeString = await settingsRepo.languageSettingRead();
    List<String> localeList = localeString.toString().split('_');
    _locale = Locale(localeList[0], localeList[1]);
    Get.updateLocale(_locale);
    _firstGuessHelp = await settingsRepo.firstHelpGuessRead();
    _firstTrainHelp = await settingsRepo.firstHelpTrainRead();
  }

  Future<void> languageSettingsSave(String language) async {
    _locale = Locale(language.split('_')[0], language.split('_')[1]);
    settingsRepo.languageSettingsSave(language);
    Get.updateLocale(_locale);
    await Get.find<AnalyticsController>().updateLanguage(language);
  }

  Future<void> firstHelpGuessSave(bool first) async {
    _firstGuessHelp = first;
    settingsRepo.firstHelpGuessSave(first);
  }

  Future<void> firstHelpTrainSave(bool first) async {
    _firstTrainHelp = first;
    settingsRepo.firstHelpTrainSave(first);
  }
}
