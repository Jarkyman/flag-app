import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flag_app/models/training_continent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const locales = {
    'us': Locale('en', 'US'),
    'de': Locale('de', 'DE'),
    'dk': Locale('da', 'DK'),
    'se': Locale('sv', 'SE'),
    'no': Locale('nb', 'NO'),
    'es': Locale('es', 'ES'),
    'fr': Locale('fr', 'FR'),
    'pt': Locale('pt', 'PT'),
    'br': Locale('pt', 'BR'),
  };

  for (final localeEntry in locales.entries) {
    test('every ${localeEntry.key} continent maps to at least six countries',
        () {
      final json = jsonDecode(
        File('assets/json/${localeEntry.key}/continents.json')
            .readAsStringSync(),
      ) as List<dynamic>;
      final countries = jsonDecode(
        File('assets/json/${localeEntry.key}/countries.json')
            .readAsStringSync(),
      ) as List<dynamic>;
      final countryNames = countries
          .map((country) => country['country_name'])
          .whereType<String>()
          .toSet();

      for (final continent in TrainingContinent.values.skip(1)) {
        final assetName = continent.assetNameFor(localeEntry.value);
        final countryCount = json
            .where((entry) => entry['Continent'] == assetName)
            .where((entry) => countryNames.contains(entry['Country']))
            .length;
        expect(
          countryCount,
          greaterThanOrEqualTo(6),
          reason: '${continent.id} did not match ${localeEntry.key}',
        );
      }
    });
  }

  test('all locales contain the continent picker translations', () {
    final localeJson = jsonDecode(
      File('assets/json/locale.json').readAsStringSync(),
    ) as List<dynamic>;
    final requiredKeys = {
      ...TrainingContinent.values.map((continent) => continent.translationKey),
      'Choose continent',
      'Filter by continent',
    };

    for (final locale in localeJson) {
      final texts = locale['texts'] as Map<String, dynamic>;
      expect(
        texts.keys,
        containsAll(requiredKeys),
        reason: locale['country_code'] as String,
      );
    }
  });
}
