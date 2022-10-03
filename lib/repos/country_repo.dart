import 'dart:ui';

import 'package:flutter/services.dart';

class CountryRepo {
  CountryRepo();

  Future<String> readCountries(Locale locale) async {
    String lang = locale.toString().split('_')[1].toLowerCase();
    print('load countries: $locale');
    final String response =
        await rootBundle.loadString('assets/json/$lang/countries.json');
    return response;
  }
}
