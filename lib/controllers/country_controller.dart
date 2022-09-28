import 'dart:convert';

import 'package:flag_app/controllers/country_continent_controller.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flag_app/repos/country_repo.dart';
import 'package:get/get.dart';

class CountryController extends GetxController implements GetxService {
  CountryRepo countryRepo;

  CountryController({required this.countryRepo});

  List<CountryModel> _countries = [];
  List<CountryModel> get getCountries => _countries;

  Future<void> readCountries() async {
    final list =
        json.decode(await countryRepo.readCountries()) as List<dynamic>;
    _countries = [];
    _countries = list.map((e) => CountryModel.fromJson(e)).toList();
    Get.find<CountryContinentController>()
        .readCountries()
        .then((value) => removeUnUsed());
    update();
  }

  void removeUnUsed() {
    List<CountryModel> result = [];
    Get.find<CountryContinentController>().getCountries.forEach((continent) {
      _countries.forEach((country) {
        if (country.countryName == continent.country) {
          result.add(country);
        }
      });
    });

    print(result.length);
    _countries = result;
  }

  String getCountryCode(String country) {
    String countryCode = 'error';
    _countries.forEach((element) {
      if (country == element.countryName) {
        countryCode = element.countryCode!;
      }
    });
    return countryCode;
  }

  CountryModel getACountry() {
    if (_countries.isEmpty) {
      readCountries();
    }
    List<CountryModel> all = _countries;
    all.shuffle();
    CountryModel result = all[1];
    return result;
  }

  List<CountryModel> generateCountries(String selectedCountry, int amount) {
    if (_countries.isEmpty) {
      readCountries();
    }

    List<CountryModel> all = _countries;
    List<CountryModel> result = [];
    int count = amount - 2;

    all.shuffle();

    _countries.forEach((country) {
      if (country.countryName == selectedCountry) {
        result.add(country);
      }
    });

    for (int i = 0; i <= count; i++) {
      if (all[i].countryName == selectedCountry) {
        count++;
      } else {
        result.add(all[i]);
      }
    }
    result.shuffle();
    update();

    return result;
  }
}
