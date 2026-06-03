import 'dart:convert';
import 'dart:ui';

import 'package:flag_app/controllers/country_continent_controller.dart';

import 'package:flag_app/models/country_model.dart';
import 'package:flag_app/repos/country_repo.dart';
import 'package:get/get.dart';

class CountryController extends GetxController implements GetxService {
  CountryRepo countryRepo;

  CountryController({required this.countryRepo});

  int _countryCount = 0;
  List<CountryModel> _countries = [];

  List<CountryModel> get getCountries => _countries;

  Future<void> readCountries(Locale locale) async {
    final list =
        json.decode(await countryRepo.readCountries(locale)) as List<dynamic>;
    _countries = [];
    _countries = list.map((e) => CountryModel.fromJson(e)).toList();
    Get.find<CountryContinentController>()
        .readCountries(locale)
        .then((value) => removeUnUsed());
    update();
    _countries.shuffle();
  }

  void removeUnUsed() {
    List<CountryModel> result = [];
    Get.find<CountryContinentController>().getCountries.forEach((continent) {
      for (var country in _countries) {
        if (country.countryName == continent.country) {
          result.add(country);
        }
      }
    });
    _countries = result;
  }

  List<CountryModel> getTestObj() {
    List<CountryModel> result = [];
    Get.find<CountryContinentController>().getCountries.forEach((continent) {
      for (var country in _countries) {
        if (country.countryName == continent.country) {
          result.add(country);
        }
      }
    });
    print('Test Obj ${result.length}');
    return result;
  }

  String getCountryCode(String country) {
    String countryCode = 'error';
    for (var element in _countries) {
      if (country.toLowerCase() == element.countryName!.toLowerCase()) {
        countryCode = element.countryCode!;
      }
    }
    return countryCode;
  }

  CountryModel getACountry() {
    if (_countries.isEmpty) {
      readCountries(Get.locale!);
    }
    if (_countryCount == 0) {
      _countries.shuffle();
    }
    CountryModel result = _countries[_countryCount];
    _countryCount++;
    if (_countryCount >= _countries.length) {
      _countryCount = 0;
    }
    return result;
  }

  void resetCount() {
    _countryCount = 0;
  }

  CountryModel getCountryByName(String countryName) {
    CountryModel? country;

    for (var element in _countries) {
      if (element.countryName == countryName) {
        country = element;
      }
    }
    return country!;
  }

  List<CountryModel> generateCountries(String selectedCountry, int amount) {
    if (_countries.isEmpty) {
      readCountries(Get.locale!);
    }

    List<CountryModel> result = [];
    String selectedContinent = "";

    // Find correct country
    CountryModel? correctCountry;
    for (var country in _countries) {
      if (country.countryName == selectedCountry) {
        correctCountry = country;
        result.add(country);
        break;
      }
    }

    if (correctCountry == null) return result;

    // Find continent for correct country
    final continentController = Get.find<CountryContinentController>();
    for (var continent in continentController.getCountries) {
      if (correctCountry.countryName == continent.country) {
        selectedContinent = continent.continent ?? "";
        break;
      }
    }

    // Pre-calculate continents map for O(1) lookups
    Map<String, String> countryToContinent = {
      for (var c in continentController.getCountries)
        if (c.country != null && c.continent != null) c.country!: c.continent!
    };

    List<CountryModel> sameContinentCountries = [];
    List<CountryModel> otherCountries = [];

    for (var country in _countries) {
      if (country.countryName == selectedCountry) continue;

      String? continent = countryToContinent[country.countryName];
      if (continent == selectedContinent && selectedContinent.isNotEmpty) {
        sameContinentCountries.add(country);
      } else {
        otherCountries.add(country);
      }
    }

    sameContinentCountries.shuffle();
    otherCountries.shuffle();

    int needed = amount - 1;
    if (sameContinentCountries.length >= needed) {
      result.addAll(sameContinentCountries.take(needed));
    } else {
      result.addAll(sameContinentCountries);
      int remaining = needed - sameContinentCountries.length;
      result.addAll(otherCountries.take(remaining));
    }

    result.shuffle();
    update();

    return result;
  }
}
