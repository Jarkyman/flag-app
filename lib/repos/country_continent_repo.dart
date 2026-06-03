import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

class CountryContinentRepo {
  CountryContinentRepo();

  Future<String> readCountryContinent(Locale locale) async {
    String lang = locale.toString().split('_')[1].toLowerCase();
    debugPrint('load continent: $locale');
    try {
      final String response =
          await rootBundle.loadString('assets/json/$lang/continents.json');
      return response;
    } catch (e) {
      final String response =
          await rootBundle.loadString('assets/json/en/continents.json');
      return response;
    }
  }
}
