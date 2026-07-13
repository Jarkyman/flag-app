import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const locales = ['us', 'dk', 'de', 'es', 'fr', 'br', 'pt', 'no', 'se'];
  const levelFiles = [
    'flagsLevels.json',
    'countriesLevels.json',
    'coatofarmsLevels.json',
  ];
  const newCountryCodes = ['PS', 'TW', 'XK'];

  test('all locales contain the same 197 playable countries', () {
    List<String>? referenceCodes;

    for (final locale in locales) {
      final countries = _jsonList('assets/json/$locale/countries.json');
      final countryByName = {
        for (final country in countries)
          country['country_name'] as String: country,
      };
      expect(countryByName, hasLength(countries.length), reason: locale);
      final continents = _jsonList('assets/json/$locale/continents.json');
      final playableCodes = continents
          .map(
            (entry) =>
                countryByName[entry['Country']]!['country_code'] as String,
          )
          .toList(growable: false);

      expect(playableCodes, hasLength(197), reason: locale);
      expect(playableCodes.toSet(), hasLength(197), reason: locale);
      expect(playableCodes.sublist(194), newCountryCodes, reason: locale);
      referenceCodes ??= playableCodes;
      expect(playableCodes, referenceCodes, reason: locale);
      for (final entry in continents) {
        final countryName = entry['Country'] as String;
        for (final unsupportedCharacter in [
          '&',
          '(',
          ')',
          '.',
          ':',
          "'",
          '’',
        ]) {
          expect(
            countryName,
            isNot(contains(unsupportedCharacter)),
            reason: '$locale/$countryName must stay compatible with word tiles',
          );
        }
      }

      for (final filename in levelFiles) {
        final levels = _jsonList('assets/json/$locale/$filename');
        final levelCodes = levels
            .map(
              (entry) =>
                  countryByName[entry['Country']]!['country_code'] as String,
            )
            .toList(growable: false);
        expect(levelCodes, hasLength(197), reason: '$locale/$filename');
        expect(levelCodes.toSet(), hasLength(197), reason: '$locale/$filename');
        expect(levelCodes.sublist(194), newCountryCodes,
            reason: '$locale/$filename');
        expect(
          levels.sublist(194).map((entry) => entry['Level']),
          everyElement(10),
          reason: '$locale/$filename',
        );
      }
    }
  });

  test('every playable country has all three required image variants', () {
    final countries = _jsonList('assets/json/us/countries.json');
    final countryByName = {
      for (final country in countries)
        country['country_name'] as String: country,
    };
    final continents = _jsonList('assets/json/us/continents.json');

    for (final entry in continents) {
      final code = (countryByName[entry['Country']]!['country_code'] as String)
          .toLowerCase();
      expect(File('assets/image/flags/$code.png').existsSync(), isTrue,
          reason: '$code flag');
      expect(
        File('assets/image/countries/$code-full.png').existsSync(),
        isTrue,
        reason: '$code country locator',
      );
      expect(
        File('assets/image/coat of arms/$code.png').existsSync(),
        isTrue,
        reason: '$code coat of arms',
      );
    }
  });

  test('currencies, corrected capitals and continents stay consistent', () {
    const currencyCorrections = {
      'AE': 'AED',
      'BB': 'BBD',
      'BG': 'EUR',
      'BN': 'BND',
      'BY': 'BYN',
      'CU': 'CUP',
      'HR': 'EUR',
      'LT': 'EUR',
      'MR': 'MRU',
      'NE': 'XOF',
      'SL': 'SLE',
      'ST': 'STN',
      'SV': 'USD',
      'TL': 'USD',
      'UY': 'UYU',
      'VE': 'VES',
      'ZW': 'ZWG',
      'PS': 'ILS',
      'TW': 'TWD',
      'XK': 'EUR',
    };
    const capitalCorrections = {
      'BI': 'Gitega',
      'GQ': 'Ciudad de la Paz',
      'MM': 'Nay Pyi Taw',
      'LK': 'Sri Jayawardenepura Kotte',
      'UA': 'Kyiv',
      'XK': 'Pristina',
    };
    const englishContinents = {
      'AM': 'Asia',
      'CY': 'Asia',
      'GE': 'Asia',
      'RU': 'Europe',
      'PS': 'Asia',
      'TW': 'Asia',
      'XK': 'Europe',
    };
    Map<String, String>? referenceCurrencies;

    for (final locale in locales) {
      final countries = _jsonList('assets/json/$locale/countries.json');
      final byCode = {
        for (final country in countries)
          country['country_code'] as String: country,
      };
      final codeByName = {
        for (final country in countries)
          country['country_name'] as String: country['country_code'] as String,
      };
      final playableCodes = _jsonList('assets/json/$locale/continents.json')
          .map((entry) => codeByName[entry['Country']]!)
          .toSet();
      final currencies = {
        for (final code in playableCodes)
          code: byCode[code]!['currency_code'] as String,
      };
      referenceCurrencies ??= currencies;

      for (final entry in currencyCorrections.entries) {
        expect(currencies[entry.key], entry.value,
            reason: '$locale/${entry.key}');
        expect(byCode[entry.key]!['currency_name'], isNotEmpty,
            reason: '$locale/${entry.key}');
      }
      for (final entry in referenceCurrencies.entries) {
        expect(currencies[entry.key], entry.value,
            reason: '$locale/${entry.key}');
      }
      for (final entry in capitalCorrections.entries) {
        expect(byCode[entry.key]!['capital'], contains(entry.value),
            reason: '$locale/${entry.key}');
      }
      expect(byCode['BO']!['capital'], contains('Sucre'), reason: locale);
      expect(byCode['BO']!['capital'], contains('La Paz'), reason: locale);
      expect(byCode['BR']!['capital'], 'Brasília', reason: locale);
      expect(byCode['PS']!['capital'], isNot('-'), reason: locale);
      expect(byCode['ZA']!['capital'], contains('/'), reason: locale);
    }

    final countries = _jsonList('assets/json/us/countries.json');
    final codeByName = {
      for (final country in countries)
        country['country_name'] as String: country['country_code'] as String,
    };
    final continents = {
      for (final entry in _jsonList('assets/json/us/continents.json'))
        codeByName[entry['Country']]!: entry['Continent'] as String,
    };
    for (final entry in englishContinents.entries) {
      expect(continents[entry.key], entry.value, reason: entry.key);
    }
  });

  test('known outdated country translations use their reviewed CLDR names', () {
    const expectedNames = {
      'dk': {'NL': 'Nederlandene', 'BY': 'Belarus'},
      'fr': {'CZ': 'Tchéquie'},
      'br': {'IR': 'Irã', 'VN': 'Vietnã'},
      'no': {'DO': 'Den dominikanske republikk'},
      'se': {'BY': 'Belarus'},
    };

    for (final localeEntry in expectedNames.entries) {
      final countries = _jsonList(
        'assets/json/${localeEntry.key}/countries.json',
      );
      final byCode = {
        for (final country in countries)
          country['country_code'] as String: country['country_name'] as String,
      };
      for (final countryEntry in localeEntry.value.entries) {
        expect(
          byCode[countryEntry.key],
          countryEntry.value,
          reason: '${localeEntry.key}/${countryEntry.key}',
        );
      }
    }
  });

  test('Danish Belarus terminology stays consistent', () {
    final countries = _jsonList('assets/json/dk/countries.json');
    final belarus = countries.singleWhere(
      (country) => country['country_code'] == 'BY',
    );

    expect(belarus['country_name'], 'Belarus');
    expect(belarus['country_demonym'], 'belarusere');
    expect(belarus['currency_name'], 'belarusisk rubel');
    expect(belarus['lang_name'], 'belarusisk');
  });
}

List<Map<String, dynamic>> _jsonList(String path) {
  final value = jsonDecode(File(path).readAsStringSync()) as List<dynamic>;
  return value.cast<Map<String, dynamic>>();
}
