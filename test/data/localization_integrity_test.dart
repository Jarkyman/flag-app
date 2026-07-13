import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final locales = _readLocales();
  final englishTexts = locales['en_US']!;

  test('all locales contain the same translation keys', () {
    expect(locales, hasLength(9));

    for (final locale in locales.entries) {
      final missingKeys = englishTexts.keys.toSet().difference(
            locale.value.keys.toSet(),
          );
      final extraKeys = locale.value.keys.toSet().difference(
            englishTexts.keys.toSet(),
          );

      expect(
        missingKeys,
        isEmpty,
        reason: '${locale.key} is missing: ${missingKeys.join(', ')}',
      );
      expect(
        extraKeys,
        isEmpty,
        reason: '${locale.key} has extra keys: ${extraKeys.join(', ')}',
      );
    }
  });

  test('every literal GetX translation key used by the app exists', () {
    final translationKeyPattern = RegExp(
      r'''[\'\"]([^\'\"]+)[\'\"]\.tr(?:Params)?\b''',
    );
    final usedKeys = <String>{};

    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      usedKeys.addAll(
        translationKeyPattern
            .allMatches(source)
            .map((match) => match.group(1)!),
      );
    }

    final missingKeys = usedKeys.difference(englishTexts.keys.toSet());
    expect(
      missingKeys,
      isEmpty,
      reason: 'Missing translation keys: ${missingKeys.join(', ')}',
    );
  });

  test('home game titles and settings are localized', () {
    const visibleKeys = {'Find flag', 'Match flags', '_Settings'};

    for (final locale in locales.entries.where(
      (entry) => entry.key != 'en_US',
    )) {
      for (final key in visibleKeys) {
        expect(
          locale.value[key],
          isNot(key),
          reason: '${locale.key} still shows the English key "$key"',
        );
      }
    }
  });

  test('level unlock translations preserve their placeholder', () {
    const placeholderKeys = {
      'You unlocked a new level',
      'Go to level',
    };

    for (final locale in locales.entries) {
      for (final key in placeholderKeys) {
        expect(
          locale.value[key],
          contains('@level'),
          reason: '${locale.key} must preserve @level in "$key"',
        );
      }
    }
  });
}

Map<String, Map<String, String>> _readLocales() {
  final data = jsonDecode(
    File('assets/json/locale.json').readAsStringSync(),
  ) as List<dynamic>;

  return {
    for (final locale in data.cast<Map<String, dynamic>>())
      locale['country_code'] as String:
          Map<String, String>.from(locale['texts'] as Map),
  };
}
