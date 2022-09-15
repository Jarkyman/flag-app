import 'package:flutter/services.dart';

class CountryContinentRepo {
  CountryContinentRepo();

  Future<String> readCountryContinent() async {
    final String response =
        await rootBundle.loadString('assets/json/continents.json');
    return response;
  }
}
