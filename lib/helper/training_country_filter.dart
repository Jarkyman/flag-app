import 'dart:math';

import '../models/country_continent_model.dart';
import '../models/country_model.dart';

class TrainingCountryFilter {
  const TrainingCountryFilter._();

  static List<CountryModel> countriesForContinent({
    required List<CountryModel> countries,
    required List<CountryContinentModel> continentEntries,
    required String continentName,
  }) {
    final countryNames = continentEntries
        .where((entry) => entry.continent == continentName)
        .map((entry) => entry.country)
        .whereType<String>()
        .toSet();

    return countries
        .where((country) => countryNames.contains(country.countryName))
        .toList();
  }

  static List<CountryModel> buildOptions({
    required List<CountryModel> countries,
    required List<CountryContinentModel> continentEntries,
    required String continentName,
    required String selectedCountry,
    required int amount,
    Random? random,
  }) {
    final continentCountries = countriesForContinent(
      countries: countries,
      continentEntries: continentEntries,
      continentName: continentName,
    );
    CountryModel? correctCountry;
    for (final country in continentCountries) {
      if (country.countryName == selectedCountry) {
        correctCountry = country;
        break;
      }
    }
    if (correctCountry == null) return [];

    final distractors = continentCountries
        .where((country) => country.countryName != selectedCountry)
        .toList()
      ..shuffle(random);
    return <CountryModel>[
      correctCountry,
      ...distractors.take(amount - 1),
    ]..shuffle(random);
  }
}
