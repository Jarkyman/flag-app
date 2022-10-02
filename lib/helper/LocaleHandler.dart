import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/i18n_model.dart';

class LocaleHandler extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {};

  static Future<void> initLanguages() async {
    final _keys = await readJson();
    Get.clearTranslations();
    Get.addTranslations(_keys);
  }

  static Future<Map<String, Map<String, String>>> readJson() async {
    final res = await rootBundle.loadString('assets/json/locale.json');
    List<dynamic> data = jsonDecode(res);
    final listData = data.map((j) => I18nModel.fromJson(j)).toList();
    final keys = Map<String, Map<String, String>>();
    listData.forEach((value) {
      final String translationKey = value.code!;
      keys.addAll({translationKey: value.texts!});
    });
    return keys;
  }
}
