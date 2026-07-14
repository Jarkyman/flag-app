import 'dart:convert';
import 'dart:ui';

import 'package:flag_app/controllers/country_continent_controller.dart';

import 'package:flag_app/models/country_model.dart';
import 'package:flag_app/repos/country_repo.dart';
import 'package:get/get.dart';

import '../helper/training_country_filter.dart';

class CountryController extends GetxController implements GetxService {
  CountryRepo countryRepo;

  CountryController({required this.countryRepo});

  List<CountryModel> _countries = [];
  final Map<String, List<CountryModel>> _countryPools = {};
  final Map<String, int> _countryCounts = {};

  List<CountryModel> get getCountries => _countries;

  Future<void> readCountries(Locale locale) async {
    final list =
        json.decode(await countryRepo.readCountries(locale)) as List<dynamic>;
    _countries = [];
    _clearCountryPools();
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
    _clearCountryPools();
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

  CountryModel getACountry({String? continent}) {
    if (_countries.isEmpty) {
      readCountries(Get.locale!);
    }

    final key = continent ?? '__all__';
    final pool = _countryPools.putIfAbsent(
      key,
      () {
        final countries = continent == null
            ? List<CountryModel>.of(_countries)
            : _countriesForContinent(continent);
        countries.shuffle();
        return countries;
      },
    );
    if (pool.isEmpty) {
      throw StateError('No countries found for continent: $continent');
    }

    var count = _countryCounts[key] ?? 0;
    if (count >= pool.length) {
      pool.shuffle();
      count = 0;
    }
    final result = pool[count];
    _countryCounts[key] = count + 1;
    return result;
  }

  void resetCount({String? continent}) {
    final key = continent ?? '__all__';
    _countryCounts[key] = 0;
    _countryPools[key]?.shuffle();
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

  List<CountryModel> generateCountries(
    String selectedCountry,
    int amount, {
    String? continent,
  }) {
    if (_countries.isEmpty) {
      readCountries(Get.locale!);
    }

    if (continent != null) {
      final result = TrainingCountryFilter.buildOptions(
        countries: _countries,
        continentEntries: Get.find<CountryContinentController>().getCountries,
        continentName: continent,
        selectedCountry: selectedCountry,
        amount: amount,
      );
      update();
      return result;
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

  List<CountryModel> _countriesForContinent(String continent) {
    return TrainingCountryFilter.countriesForContinent(
      countries: _countries,
      continentEntries: Get.find<CountryContinentController>().getCountries,
      continentName: continent,
    );
  }

  void _clearCountryPools() {
    _countryPools.clear();
    _countryCounts.clear();
  }
}
