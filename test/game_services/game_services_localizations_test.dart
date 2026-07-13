import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const expectedLocales = {
    'da-DK',
    'de-DE',
    'en-US',
    'es-ES',
    'fr-FR',
    'nb-NO',
    'pt-BR',
    'pt-PT',
    'sv-SE',
  };

  final achievementCatalog = _readJson(
    'game_services/achievements/catalog.json',
  );
  final leaderboardCatalog = _readJson(
    'game_services/leaderboards/catalog.json',
  );
  final achievementKeys = (achievementCatalog['achievements'] as List)
      .map((entry) => (entry as Map<String, dynamic>)['key'] as String)
      .toSet();
  final leaderboardKeys = (leaderboardCatalog['leaderboards'] as List)
      .map((entry) => (entry as Map<String, dynamic>)['key'] as String)
      .toSet();

  final localizationFiles = Directory('game_services/localizations')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .where((file) => !file.path.endsWith('status.json'))
      .toList();

  test('all app languages have complete Game Services localizations', () {
    final locales = localizationFiles
        .map(_readJsonFile)
        .map((json) => json['locale'] as String)
        .toSet();

    expect(locales, expectedLocales);
  });

  for (final file in localizationFiles) {
    final localization = _readJsonFile(file);
    final locale = localization['locale'] as String;

    test('$locale has every achievement and leaderboard exactly once', () {
      final achievements = Map<String, dynamic>.from(
        localization['achievements'] as Map,
      );
      final leaderboards = Map<String, dynamic>.from(
        localization['leaderboards'] as Map,
      );

      expect(achievements.keys.toSet(), achievementKeys);
      expect(leaderboards.keys.toSet(), leaderboardKeys);
      expect(
        achievements.values
            .map((entry) => (entry as Map<String, dynamic>)['name'])
            .toSet(),
        hasLength(achievementKeys.length),
        reason: 'Achievement names must be unique within each locale.',
      );
    });

    test('$locale texts fit Google Play character limits', () {
      final achievements = Map<String, dynamic>.from(
        localization['achievements'] as Map,
      );
      final leaderboards = Map<String, dynamic>.from(
        localization['leaderboards'] as Map,
      );

      for (final entry in achievements.entries) {
        final text = Map<String, dynamic>.from(entry.value as Map);
        _expectText(text['name'], maxLength: 100, field: '${entry.key}.name');
        _expectText(
          text['description'],
          maxLength: 500,
          field: '${entry.key}.description',
        );
        _expectText(
          text['earnedDescription'],
          maxLength: 500,
          field: '${entry.key}.earnedDescription',
        );
      }

      for (final entry in leaderboards.entries) {
        final text = Map<String, dynamic>.from(entry.value as Map);
        _expectText(text['name'], maxLength: 100, field: '${entry.key}.name');
        _expectText(
          text['description'],
          maxLength: 500,
          field: '${entry.key}.description',
        );
      }
    });

    test('$locale keeps every numeric achievement requirement', () {
      final achievements = Map<String, dynamic>.from(
        localization['achievements'] as Map,
      );
      const requiredNumbers = {
        'achievement.streak_5_any': '5',
        'achievement.streak_10_any': '10',
        'achievement.find_flag_10_correct': '10',
        'achievement.match_flags_10_correct': '10',
        'achievement.which_country_10_correct': '10',
        'achievement.training_100_correct': '100',
        'achievement.africa_streak_10': '10',
        'achievement.asia_streak_10': '10',
        'achievement.europe_streak_10': '10',
        'achievement.north_america_streak_10': '10',
        'achievement.oceania_streak_10': '10',
        'achievement.south_america_streak_10': '10',
        'achievement.world_tour': '5',
        'achievement.solve_10_puzzles': '10',
        'achievement.complete_flag_levels': '197',
        'achievement.complete_country_levels': '197',
        'achievement.complete_coat_of_arms_levels': '197',
        'achievement.perfect_find_flag': '197',
        'achievement.perfect_match_flags': '197',
        'achievement.perfect_which_country': '197',
      };

      for (final requirement in requiredNumbers.entries) {
        final text = Map<String, dynamic>.from(
          achievements[requirement.key] as Map,
        );
        expect(
          text['description'],
          contains(requirement.value),
          reason: '${requirement.key} must mention ${requirement.value}.',
        );
      }
    });
  }
}

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> _readJsonFile(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

void _expectText(
  Object? value, {
  required int maxLength,
  required String field,
}) {
  expect(value, isA<String>(), reason: '$field must be a string.');
  final text = value! as String;
  expect(text.trim(), isNotEmpty, reason: '$field must not be empty.');
  expect(
    text.length,
    lessThanOrEqualTo(maxLength),
    reason: '$field exceeds $maxLength characters.',
  );
}
