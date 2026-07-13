import '../models/level_model.dart';

List<LevelModel> mergeSavedLevelProgress({
  required List<LevelModel> templates,
  required List<LevelModel> savedLevels,
  bool restorePuzzleLetters = true,
  bool strictOrdering = false,
}) {
  final result = templates
      .map(
        (template) => LevelModel.fromJson({
          'Country': template.country,
          'Level': template.level,
        }),
      )
      .toList(growable: false);
  final savedCountryCounts = <String, int>{};
  for (final saved in savedLevels) {
    final country = saved.country;
    if (country != null) {
      savedCountryCounts[country] = (savedCountryCounts[country] ?? 0) + 1;
    }
  }

  final overlap =
      savedLevels.length < result.length ? savedLevels.length : result.length;
  for (var index = 0; index < overlap; index++) {
    final saved = savedLevels[index];
    final current = result[index];
    if (saved.level != current.level) {
      if (strictOrdering) {
        throw const FormatException('Saved levels have invalid ordering.');
      }
      continue;
    }

    final countryWasDuplicated =
        saved.country != null && (savedCountryCounts[saved.country] ?? 0) > 1;
    final countryChanged = saved.country != current.country;
    if (countryWasDuplicated && countryChanged) {
      continue;
    }

    current.guessed = saved.guessed ?? false;
    current.bombUsed = saved.bombUsed ?? false;
    if (restorePuzzleLetters && !countryChanged) {
      current.allLetters = List<String>.of(saved.allLetters ?? const []);
      current.answerLetters = (saved.answerLetters ?? const <List<String>>[])
          .map(List<String>.of)
          .toList(growable: false);
    }
  }
  return result;
}
