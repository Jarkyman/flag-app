import 'package:flutter/services.dart';

class CountryRepo {
  CountryRepo();

  Future<String> readCountries() async {
    final String response =
        await rootBundle.loadString('assets/json/countries.json');
    return response;
  }
}
