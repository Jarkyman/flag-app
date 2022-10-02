import 'dart:convert';
import 'dart:ui';

import 'package:flag_app/models/country_continent_model.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flag_app/repos/country_continent_repo.dart';
import 'package:get/get.dart';

class CountryContinentController extends GetxController implements GetxService {
  CountryContinentRepo continentRepo;

  CountryContinentController({required this.continentRepo});

  List<CountryContinentModel> _countries = [];
  List<CountryContinentModel> get getCountries => _countries;

  Future<void> readCountries(Locale locale) async {
    final list = json.decode(await continentRepo.readCountryContinent(locale))
        as List<dynamic>;
    _countries = [];
    _countries = list.map((e) => CountryContinentModel.fromJson(e)).toList();
    print(_countries.length);
    update();
  }

  String getContinentNameByCountryModel(CountryModel country) {
    for (var element in _countries) {
      if (element.country == country.countryName) {
        return element.continent!;
      }
    }
    return '';
  }
}
