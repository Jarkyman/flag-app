import 'dart:ui';

import 'package:flutter/services.dart';

class CountryContinentRepo {
  CountryContinentRepo();

  Future<String> readCountryContinent(Locale locale) async {
    String lang = locale.toString().split('_')[1].toLowerCase();
    final String response =
        await rootBundle.loadString('assets/json/$lang/continents.json');
    return response;
  }
}
