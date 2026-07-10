import 'dart:math';

import 'package:flag_app/helper/training_country_filter.dart';
import 'package:flag_app/models/country_continent_model.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final countries = [
    CountryModel(countryCode: 'A1', countryName: 'Africa 1'),
    CountryModel(countryCode: 'A2', countryName: 'Africa 2'),
    CountryModel(countryCode: 'A3', countryName: 'Africa 3'),
    CountryModel(countryCode: 'A4', countryName: 'Africa 4'),
    CountryModel(countryCode: 'E1', countryName: 'Europe 1'),
    CountryModel(countryCode: 'E2', countryName: 'Europe 2'),
  ];
  final continentEntries = [
    CountryContinentModel(continent: 'Africa', country: 'Africa 1'),
    CountryContinentModel(continent: 'Africa', country: 'Africa 2'),
    CountryContinentModel(continent: 'Africa', country: 'Africa 3'),
    CountryContinentModel(continent: 'Africa', country: 'Africa 4'),
    CountryContinentModel(continent: 'Europe', country: 'Europe 1'),
    CountryContinentModel(continent: 'Europe', country: 'Europe 2'),
  ];

  test('filters the question pool to one continent', () {
    final result = TrainingCountryFilter.countriesForContinent(
      countries: countries,
      continentEntries: continentEntries,
      continentName: 'Africa',
    );

    expect(result, hasLength(4));
    expect(result.map((country) => country.countryName),
        everyElement(startsWith('Africa')));
  });

  test('builds answer options only from the selected continent', () {
    final result = TrainingCountryFilter.buildOptions(
      countries: countries,
      continentEntries: continentEntries,
      continentName: 'Africa',
      selectedCountry: 'Africa 1',
      amount: 4,
      random: Random(7),
    );

    expect(result, hasLength(4));
    expect(result.where((country) => country.countryName == 'Africa 1'),
        hasLength(1));
    expect(result.map((country) => country.countryName),
        everyElement(startsWith('Africa')));
  });

  test('does not build options when the correct country is outside the filter',
      () {
    final result = TrainingCountryFilter.buildOptions(
      countries: countries,
      continentEntries: continentEntries,
      continentName: 'Africa',
      selectedCountry: 'Europe 1',
      amount: 4,
    );

    expect(result, isEmpty);
  });
}
