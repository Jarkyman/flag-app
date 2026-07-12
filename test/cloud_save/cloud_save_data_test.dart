import 'dart:convert';

import 'package:flag_app/cloud_save/models/cloud_save_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips every backed-up value', () {
    final source = CloudSaveData(
      savedAtUtc: DateTime.utc(2026, 7, 12, 10, 30),
      levels: {
        'Flags': [
          {
            'Country': 'Denmark',
            'Guessed': true,
            'Level': 1,
            'BombUsed': false,
            'AnswerLetters': <String>[],
            'AllLetters': <String>[],
          },
        ],
      },
      scores: const {'flag-score': 12},
      hints: 7,
      correctAnswers: const {'findFlag': 42},
    );

    final restored = CloudSaveData.decode(source.encode());

    expect(restored.schemaVersion, CloudSaveData.currentSchemaVersion);
    expect(restored.savedAtUtc, source.savedAtUtc);
    expect(restored.levels, source.levels);
    expect(restored.scores, source.scores);
    expect(restored.hints, 7);
    expect(restored.correctAnswers, source.correctAnswers);
  });

  test('rejects a save created by an unsupported schema version', () {
    final json = {
      'schemaVersion': CloudSaveData.currentSchemaVersion + 1,
      'savedAtUtc': DateTime.utc(2026, 7, 12).toIso8601String(),
      'levels': <String, dynamic>{},
      'scores': <String, dynamic>{},
      'hints': 0,
      'correctAnswers': <String, dynamic>{},
    };

    expect(
      () => CloudSaveData.decode(jsonEncode(json)),
      throwsFormatException,
    );
  });

  test('rejects negative counters before they can reach local storage', () {
    final json = {
      'schemaVersion': CloudSaveData.currentSchemaVersion,
      'savedAtUtc': DateTime.utc(2026, 7, 12).toIso8601String(),
      'levels': <String, dynamic>{},
      'scores': {'flag-score': -1},
      'hints': 0,
      'correctAnswers': <String, dynamic>{},
    };

    expect(
      () => CloudSaveData.decode(jsonEncode(json)),
      throwsFormatException,
    );
  });
}
