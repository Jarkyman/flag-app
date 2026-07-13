import 'package:flag_app/helper/level_progress_merge.dart';
import 'package:flag_app/models/level_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('merges a legacy shorter save and leaves appended levels untouched', () {
    final templates = [
      _level('Renamed country', 1),
      _level('Second country', 1),
      _level('New country', 10),
    ];
    final saved = [
      _level(
        'Old country name',
        1,
        guessed: true,
        bombUsed: true,
        allLetters: ['A'],
        answerLetters: [
          ['A'],
        ],
      ),
      _level(
        'Second country',
        1,
        guessed: true,
        allLetters: ['B'],
        answerLetters: [
          ['B'],
        ],
      ),
    ];

    final result = mergeSavedLevelProgress(
      templates: templates,
      savedLevels: saved,
    );

    expect(result, hasLength(3));
    expect(result[0].guessed, isTrue);
    expect(result[0].bombUsed, isTrue);
    expect(result[0].allLetters, isEmpty);
    expect(result[0].answerLetters, isEmpty);
    expect(result[1].guessed, isTrue);
    expect(result[1].allLetters, ['B']);
    expect(result[1].answerLetters, [
      ['B'],
    ]);
    expect(result[2].guessed, isFalse);
    expect(result[2].bombUsed, isFalse);
  });

  test('does not transfer progress from a duplicated country to another one',
      () {
    final result = mergeSavedLevelProgress(
      templates: [_level('Denmark', 3), _level('Tanzania', 7)],
      savedLevels: [
        _level('Denmark', 3, guessed: true),
        _level('Denmark', 7, guessed: true, bombUsed: true),
      ],
    );

    expect(result[0].guessed, isTrue);
    expect(result[1].guessed, isFalse);
    expect(result[1].bombUsed, isFalse);
  });

  test('strict merge rejects changed level ordering', () {
    expect(
      () => mergeSavedLevelProgress(
        templates: [_level('Country', 1)],
        savedLevels: [_level('Country', 2)],
        strictOrdering: true,
      ),
      throwsFormatException,
    );
  });
}

LevelModel _level(
  String country,
  int level, {
  bool guessed = false,
  bool bombUsed = false,
  List<String> allLetters = const [],
  List<List<String>> answerLetters = const [],
}) {
  return LevelModel.fromJson({
    'Country': country,
    'Level': level,
    'Guessed': guessed,
    'BombUsed': bombUsed,
    'AllLetters': allLetters,
    'AnswerLetters': [
      for (var index = 0; index < answerLetters.length; index++) ...[
        ...answerLetters[index],
        '#',
      ],
    ],
  });
}
