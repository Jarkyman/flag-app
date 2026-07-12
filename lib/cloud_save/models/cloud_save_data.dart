import 'dart:convert';

class CloudSaveData {
  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime savedAtUtc;
  final Map<String, List<Map<String, dynamic>>> levels;
  final Map<String, int> scores;
  final int hints;
  final Map<String, int> correctAnswers;

  const CloudSaveData({
    this.schemaVersion = currentSchemaVersion,
    required this.savedAtUtc,
    required this.levels,
    required this.scores,
    required this.hints,
    required this.correctAnswers,
  });

  factory CloudSaveData.decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cloud save must be a JSON object.');
    }
    return CloudSaveData.fromJson(decoded);
  }

  factory CloudSaveData.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != currentSchemaVersion) {
      throw FormatException(
        'Unsupported cloud-save schema version: $schemaVersion.',
      );
    }

    final savedAt = json['savedAtUtc'];
    final rawLevels = json['levels'];
    final rawScores = json['scores'];
    final rawHints = json['hints'];
    final rawCorrectAnswers = json['correctAnswers'];
    if (savedAt is! String ||
        rawLevels is! Map ||
        rawScores is! Map ||
        rawHints is! int ||
        rawCorrectAnswers is! Map) {
      throw const FormatException('Cloud save has an invalid shape.');
    }

    final parsedDate = DateTime.tryParse(savedAt);
    if (parsedDate == null) {
      throw const FormatException('Cloud save has an invalid timestamp.');
    }

    return CloudSaveData(
      schemaVersion: schemaVersion as int,
      savedAtUtc: parsedDate.toUtc(),
      levels: rawLevels.map<String, List<Map<String, dynamic>>>((key, value) {
        if (key is! String || value is! List) {
          throw const FormatException('Cloud save has invalid level data.');
        }
        return MapEntry(
          key,
          value.map<Map<String, dynamic>>((item) {
            if (item is! Map) {
              throw const FormatException(
                'Cloud save has an invalid level entry.',
              );
            }
            return Map<String, dynamic>.from(item);
          }).toList(growable: false),
        );
      }),
      scores: _readIntMap(rawScores, 'score'),
      hints: rawHints,
      correctAnswers: _readIntMap(rawCorrectAnswers, 'correct-answer'),
    );
  }

  String encode() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'savedAtUtc': savedAtUtc.toUtc().toIso8601String(),
      'levels': levels,
      'scores': scores,
      'hints': hints,
      'correctAnswers': correctAnswers,
    };
  }

  static Map<String, int> _readIntMap(Map rawMap, String name) {
    return rawMap.map<String, int>((key, value) {
      if (key is! String || value is! int || value < 0) {
        throw FormatException('Cloud save has invalid $name data.');
      }
      return MapEntry(key, value);
    });
  }
}
