import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/i18n_model.dart';

class LocaleHandler extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {};

  static Future<void> initLanguages() async {
    final keys = await readJson();
    Get.clearTranslations();
    Get.addTranslations(keys);
  }

  static Future<Map<String, Map<String, String>>> readJson() async {
    final res = await rootBundle.loadString('assets/json/locale.json');
    List<dynamic> data = jsonDecode(res);
    final listData = data.map((j) => I18nModel.fromJson(j)).toList();
    final keys = <String, Map<String, String>>{};
    for (var value in listData) {
      final String translationKey = value.code!;
      keys.addAll({translationKey: value.texts!});
    }
    return keys;
  }
}
