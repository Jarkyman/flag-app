import 'package:flag_app/helper/guess_puzzle_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Puzzle layout', () {
    test('creates a line break for a long answer', () {
      final correct = GuessPuzzleLogic.buildCorrectLetters('LIECHTENSTEIN');

      expect(
        correct.expand((row) => row),
        contains(GuessPuzzleLogic.lineBreak),
      );
      _expectSolutionLetters(correct, 'LIECHTENSTEIN');
    });

    test('preserves a hyphen as a non-playable separator', () {
      final correct = GuessPuzzleLogic.buildCorrectLetters('GUINEA-BISSAU');
      final empty = GuessPuzzleLogic.buildEmptyAnswer('GUINEA-BISSAU');

      expect(correct.expand((row) => row), contains('-'));
      expect(empty.expand((row) => row), contains('-'));
      _expectSolutionLetters(correct, 'GUINEA-BISSAU');
    });

    test('shows a line-break tile after a long hyphenated segment', () {
      final correct =
          GuessPuzzleLogic.buildCorrectLetters('BOSNIEN-HERCEGOVINA');
      final empty = GuessPuzzleLogic.buildEmptyAnswer('BOSNIEN-HERCEGOVINA');

      expect(correct, [
        'BOSNIEN-'.split(''),
        [...'HERCEGOV'.split(''), GuessPuzzleLogic.lineBreak],
        'INA'.split(''),
      ]);
      expect(empty[1].last, GuessPuzzleLogic.lineBreak);
      _expectSolutionLetters(correct, 'BOSNIEN-HERCEGOVINA');
    });

    test('moves a saved answer into a layout with a new line-break tile', () {
      final correct =
          GuessPuzzleLogic.buildCorrectLetters('BOSNIEN-HERCEGOVINA');
      final oldAnswer = [
        ['B', 'O', '', '', '', '', '', '-'],
        ['H', 'E', '', '', '', '', '', 'V'],
        ['I', '', 'A'],
      ];

      final fitted = GuessPuzzleLogic.fitAnswerToLayout(
        correctLetters: correct,
        answerLetters: oldAnswer,
      );

      expect(fitted, [
        ['B', 'O', '', '', '', '', '', '-'],
        ['H', 'E', '', '', '', '', '', 'V', GuessPuzzleLogic.lineBreak],
        ['I', '', 'A'],
      ]);
    });

    test('preserves a separator between short words', () {
      final correct = GuessPuzzleLogic.buildCorrectLetters('LA PAZ');
      final empty = GuessPuzzleLogic.buildEmptyAnswer('LA PAZ');

      expect(correct.expand((row) => row), contains('/'));
      expect(empty.expand((row) => row), contains('/'));
      _expectSolutionLetters(correct, 'LA PAZ');
    });
  });

  group('Bomb regression cases', () {
    test('FINLFFS keeps the correct F and returns A, N and D', () {
      final fixture = _fixture('FINLAND', 18, _Selection.none);
      final positions = GuessPuzzleLogic.letterPositions(fixture.correct);
      const entered = ['F', 'I', 'N', 'L', 'F', 'F', 'S'];
      _addSurplusLetters(
        fixture.pool,
        _solutionLetters(fixture.correct),
        letter: 'F',
        amount: 2,
      );

      for (int index = 0; index < entered.length; index++) {
        _placeLetter(
          fixture.answer,
          fixture.pool,
          positions[index],
          entered[index],
        );
      }

      final result = GuessPuzzleLogic.applyBomb(
        correctLetters: fixture.correct,
        answerLetters: fixture.answer,
        allLetters: fixture.pool,
      );

      expect(_answerText(result.answerLetters), 'FINL');
      expect(_frequency(_poolLetters(result.allLetters)), {
        'A': 1,
        'N': 1,
        'D': 1,
      });
      _expectBombInvariants(fixture.correct, fixture.answer, result, 18);
    });

    test('repairs the old saved FINLAND state without index -1', () {
      final correct = GuessPuzzleLogic.buildCorrectLetters('FINLAND');
      final answer = GuessPuzzleLogic.buildEmptyAnswer('FINLAND');
      final positions = GuessPuzzleLogic.letterPositions(correct);
      answer[positions[1].wordIndex][positions[1].letterIndex] = 'I';
      answer[positions[2].wordIndex][positions[2].letterIndex] = 'N';
      answer[positions[3].wordIndex][positions[3].letterIndex] = 'L';
      final corruptedPool = List<String>.filled(18, '');
      corruptedPool[1] = 'N';
      corruptedPool[6] = 'A';
      corruptedPool[14] = 'D';

      final result = GuessPuzzleLogic.applyBomb(
        correctLetters: correct,
        answerLetters: answer,
        allLetters: corruptedPool,
      );

      expect(_frequency(_poolLetters(result.allLetters)), {
        'F': 1,
        'A': 1,
        'N': 1,
        'D': 1,
      });
      _expectBombInvariants(correct, answer, result, 18);
    });

    test('keeps valid duplicate letters only up to required multiplicity', () {
      final fixture = _fixture('BANANA', 18, _Selection.duplicateHeavy);

      final result = GuessPuzzleLogic.applyBomb(
        correctLetters: fixture.correct,
        answerLetters: fixture.answer,
        allLetters: fixture.pool,
      );

      _expectBombInvariants(fixture.correct, fixture.answer, result, 18);
      expect(
        _frequency(_lettersInState(fixture.correct, result))['B'],
        1,
      );
      expect(
        _frequency(_lettersInState(fixture.correct, result))['A'],
        3,
      );
      expect(
        _frequency(_lettersInState(fixture.correct, result))['N'],
        2,
      );
    });
  });

  group('Correct-letter hint', () {
    test('fills the first empty position and consumes that pool letter', () {
      final fixture = _fixture('FINLAND', 18, _Selection.none);

      final result = GuessPuzzleLogic.applyCorrectLetterHint(
        correctLetters: fixture.correct,
        answerLetters: fixture.answer,
        allLetters: fixture.pool,
      );

      expect(result.applied, isTrue);
      expect(result.position,
          const GuessPuzzlePosition(wordIndex: 0, letterIndex: 0));
      expect(_answerText(result.answerLetters), 'F');
      _expectStateMultiset(fixture.correct, result, allowDecoys: true);
    });

    test('replaces an invalid selected letter and returns it to the pool', () {
      final fixture = _fixture('FINLAND', 18, _Selection.invalidOnly);
      final firstPosition =
          GuessPuzzleLogic.letterPositions(fixture.correct).first;
      final displaced =
          fixture.answer[firstPosition.wordIndex][firstPosition.letterIndex];

      final result = GuessPuzzleLogic.applyCorrectLetterHint(
        correctLetters: fixture.correct,
        answerLetters: fixture.answer,
        allLetters: fixture.pool,
      );

      expect(result.applied, isTrue);
      expect(
        result.answerLetters[firstPosition.wordIndex]
            [firstPosition.letterIndex],
        'F',
      );
      expect(result.allLetters, contains(displaced));
      _expectStateMultiset(fixture.correct, result, allowDecoys: true);
    });

    test('moves a required letter from a wrong answer position', () {
      final fixture = _fixture('FINLAND', 18, _Selection.none);
      final positions = GuessPuzzleLogic.letterPositions(fixture.correct);
      _placeLetter(
        fixture.answer,
        fixture.pool,
        positions[4],
        'F',
      );
      for (int index = 0; index < fixture.pool.length; index++) {
        if (fixture.pool[index] == 'F') fixture.pool[index] = 'Q';
      }

      final result = GuessPuzzleLogic.applyCorrectLetterHint(
        correctLetters: fixture.correct,
        answerLetters: fixture.answer,
        allLetters: fixture.pool,
      );

      expect(result.applied, isTrue);
      expect(result.answerLetters[0][0], 'F');
      expect(
        result.answerLetters[positions[4].wordIndex][positions[4].letterIndex],
        isEmpty,
      );
      _expectStateMultiset(fixture.correct, result, allowDecoys: true);
    });

    test('does not steal a correctly placed duplicate', () {
      final correct = GuessPuzzleLogic.buildCorrectLetters('BANANA');
      final answer = GuessPuzzleLogic.buildEmptyAnswer('BANANA');
      final positions = GuessPuzzleLogic.letterPositions(correct);
      answer[positions[0].wordIndex][positions[0].letterIndex] = 'B';
      answer[positions[3].wordIndex][positions[3].letterIndex] = 'A';
      answer[positions[5].wordIndex][positions[5].letterIndex] = 'A';
      final pool = List<String>.filled(18, '');
      pool[0] = 'N';
      pool[1] = 'N';

      final result = GuessPuzzleLogic.applyCorrectLetterHint(
        correctLetters: correct,
        answerLetters: answer,
        allLetters: pool,
      );

      expect(result.applied, isFalse);
      expect(result.answerLetters, equals(answer));
      expect(result.allLetters, equals(pool));
    });

    test('repeated hints can complete line-break and hyphen answers', () {
      for (final answerText in ['LIECHTENSTEIN', 'GUINEA-BISSAU']) {
        final fixture = _fixture(answerText, 18, _Selection.none);
        GuessPuzzleState state = GuessPuzzleState(
          answerLetters: fixture.answer,
          allLetters: fixture.pool,
        );

        for (int index = 0;
            index < GuessPuzzleLogic.letterPositions(fixture.correct).length;
            index++) {
          final result = GuessPuzzleLogic.applyCorrectLetterHint(
            correctLetters: fixture.correct,
            answerLetters: state.answerLetters,
            allLetters: state.allLetters,
          );
          expect(result.applied, isTrue, reason: answerText);
          state = result;
        }

        expect(state.answerLetters, equals(fixture.correct));
      }
    });

    test('a hint still works after the bomb has reduced the pool', () {
      final fixture = _fixture('FINLAND', 18, _Selection.mixed);
      final bomb = GuessPuzzleLogic.applyBomb(
        correctLetters: fixture.correct,
        answerLetters: fixture.answer,
        allLetters: fixture.pool,
      );

      final hint = GuessPuzzleLogic.applyCorrectLetterHint(
        correctLetters: fixture.correct,
        answerLetters: bomb.answerLetters,
        allLetters: bomb.allLetters,
      );

      expect(hint.applied, isTrue);
      _expectStateMultiset(fixture.correct, hint);
    });
  });

  group('Exhaustive bomb and correct-letter-hint matrix', () {
    const puzzleCases = [
      _PuzzleCase('duplicates', 'BANANA'),
      _PuzzleCase('standard regression word', 'FINLAND'),
      _PuzzleCase('next line', 'LIECHTENSTEIN'),
      _PuzzleCase('hyphen', 'GUINEA-BISSAU'),
      _PuzzleCase(
        'hyphen and next line',
        'BOSNIEN-HERCEGOVINA',
        poolSizes: [27, 36],
      ),
    ];

    for (final puzzle in puzzleCases) {
      for (final poolSize in puzzle.poolSizes) {
        for (final selection in _Selection.values) {
          for (final hintSetup in _HintSetup.values) {
            test(
              '${puzzle.name}, $poolSize letters, '
              '${selection.name}, ${hintSetup.name}',
              () {
                final fixture = _fixture(
                  puzzle.answer,
                  poolSize,
                  selection,
                );
                final stateWithHints = _applyHintSetup(
                  fixture.correct,
                  GuessPuzzleState(
                    answerLetters: fixture.answer,
                    allLetters: fixture.pool,
                  ),
                  hintSetup,
                );
                final protectedPositions = _correctlyPlacedPositions(
                  fixture.correct,
                  stateWithHints.answerLetters,
                );

                final result = GuessPuzzleLogic.applyBomb(
                  correctLetters: fixture.correct,
                  answerLetters: stateWithHints.answerLetters,
                  allLetters: stateWithHints.allLetters,
                );

                _expectBombInvariants(
                  fixture.correct,
                  stateWithHints.answerLetters,
                  result,
                  poolSize,
                );
                for (final position in protectedPositions) {
                  expect(
                    result.answerLetters[position.wordIndex]
                        [position.letterIndex],
                    fixture.correct[position.wordIndex][position.letterIndex],
                  );
                }

                final secondBomb = GuessPuzzleLogic.applyBomb(
                  correctLetters: fixture.correct,
                  answerLetters: result.answerLetters,
                  allLetters: result.allLetters,
                );
                expect(secondBomb.answerLetters, equals(result.answerLetters));
                expect(secondBomb.allLetters, equals(result.allLetters));
              },
            );
          }
        }
      }
    }
  });
}

class _PuzzleCase {
  final String name;
  final String answer;
  final List<int> poolSizes;

  const _PuzzleCase(
    this.name,
    this.answer, {
    this.poolSizes = const [18, 27, 36],
  });
}

enum _Selection {
  none,
  invalidOnly,
  validCorrect,
  validMisplaced,
  mixed,
  duplicateHeavy,
}

enum _HintSetup {
  none,
  first,
  firstAndSecond,
  thirdOnly,
}

class _Fixture {
  final List<List<String>> correct;
  final List<List<String>> answer;
  final List<String> pool;

  const _Fixture({
    required this.correct,
    required this.answer,
    required this.pool,
  });
}

_Fixture _fixture(String answerText, int poolSize, _Selection selection) {
  final correct = GuessPuzzleLogic.buildCorrectLetters(answerText);
  final answer = _emptyFromCorrect(correct);
  final duplicateExtras = switch (selection) {
    _Selection.duplicateHeavy => 3,
    _Selection.mixed => 1,
    _ => 0,
  };
  final pool = _buildPool(correct, poolSize, duplicateExtras);
  final positions = GuessPuzzleLogic.letterPositions(correct);
  final solution = _solutionLetters(correct);

  switch (selection) {
    case _Selection.none:
      break;
    case _Selection.invalidOnly:
      for (final position in positions.take(3)) {
        final invalid = pool.firstWhere(
          (letter) => letter.isNotEmpty && !solution.contains(letter),
        );
        _placeLetter(answer, pool, position, invalid);
      }
    case _Selection.validCorrect:
      final indexes = {0, positions.length ~/ 2, positions.length - 1};
      for (final index in indexes) {
        final position = positions[index];
        _placeLetter(
          answer,
          pool,
          position,
          correct[position.wordIndex][position.letterIndex],
        );
      }
    case _Selection.validMisplaced:
      for (final position in positions.take(4)) {
        final expected = correct[position.wordIndex][position.letterIndex];
        final valid = pool.firstWhere(
          (letter) =>
              letter.isNotEmpty &&
              solution.contains(letter) &&
              letter != expected,
        );
        _placeLetter(answer, pool, position, valid);
      }
    case _Selection.mixed:
      final first = positions[0];
      _placeLetter(
        answer,
        pool,
        first,
        correct[first.wordIndex][first.letterIndex],
      );

      final invalid = pool.firstWhere(
        (letter) => letter.isNotEmpty && !solution.contains(letter),
      );
      _placeLetter(answer, pool, positions[1], invalid);

      final expected =
          correct[positions[2].wordIndex][positions[2].letterIndex];
      final misplaced = pool.firstWhere(
        (letter) =>
            letter.isNotEmpty &&
            solution.contains(letter) &&
            letter != expected,
      );
      _placeLetter(answer, pool, positions[2], misplaced);

      final duplicate = solution.first;
      final duplicateTarget = positions.firstWhere(
        (position) =>
            answer[position.wordIndex][position.letterIndex].isEmpty &&
            correct[position.wordIndex][position.letterIndex] != duplicate,
      );
      _placeLetter(answer, pool, duplicateTarget, duplicate);
    case _Selection.duplicateHeavy:
      final duplicate = solution.first;
      final first = positions.first;
      _placeLetter(answer, pool, first, duplicate);
      for (final position in positions.skip(1).take(3)) {
        if (!pool.contains(duplicate)) break;
        _placeLetter(answer, pool, position, duplicate);
      }
  }

  return _Fixture(correct: correct, answer: answer, pool: pool);
}

GuessPuzzleState _applyHintSetup(
  List<List<String>> correct,
  GuessPuzzleState source,
  _HintSetup setup,
) {
  var answer = source.answerLetters.map(List<String>.from).toList();
  var pool = List<String>.from(source.allLetters);
  final positions = GuessPuzzleLogic.letterPositions(correct);

  CorrectLetterHintResult applyHint() {
    final result = GuessPuzzleLogic.applyCorrectLetterHint(
      correctLetters: correct,
      answerLetters: answer,
      allLetters: pool,
    );
    expect(result.applied, isTrue, reason: 'Hint setup ${setup.name}');
    answer = result.answerLetters;
    pool = result.allLetters;
    return result;
  }

  switch (setup) {
    case _HintSetup.none:
      break;
    case _HintSetup.first:
      _clearPosition(answer, pool, positions[0]);
      final result = applyHint();
      expect(result.position, positions[0]);
    case _HintSetup.firstAndSecond:
      _clearPosition(answer, pool, positions[0]);
      _clearPosition(answer, pool, positions[1]);
      expect(applyHint().position, positions[0]);
      expect(applyHint().position, positions[1]);
    case _HintSetup.thirdOnly:
      _clearPosition(answer, pool, positions[0]);
      _clearPosition(answer, pool, positions[1]);
      _clearPosition(answer, pool, positions[2]);
      _ensureCorrectManually(correct, answer, pool, positions[0]);
      _ensureCorrectManually(correct, answer, pool, positions[1]);
      expect(applyHint().position, positions[2]);
  }

  return GuessPuzzleState(answerLetters: answer, allLetters: pool);
}

void _ensureCorrectManually(
  List<List<String>> correct,
  List<List<String>> answer,
  List<String> pool,
  GuessPuzzlePosition target,
) {
  final required = correct[target.wordIndex][target.letterIndex];
  if (answer[target.wordIndex][target.letterIndex] == required) return;
  _clearPosition(answer, pool, target);

  var poolIndex = pool.indexOf(required);
  if (poolIndex >= 0) {
    pool[poolIndex] = '';
    answer[target.wordIndex][target.letterIndex] = required;
    return;
  }

  for (final source in GuessPuzzleLogic.letterPositions(correct)) {
    final sourceLetter = answer[source.wordIndex][source.letterIndex];
    final correctlyPlaced =
        sourceLetter == correct[source.wordIndex][source.letterIndex];
    if (sourceLetter == required && !correctlyPlaced) {
      answer[source.wordIndex][source.letterIndex] = '';
      answer[target.wordIndex][target.letterIndex] = required;
      return;
    }
  }

  throw StateError('Could not place $required at $target');
}

List<String> _buildPool(
  List<List<String>> correct,
  int size,
  int duplicateExtras,
) {
  final solution = _solutionLetters(correct);
  if (solution.length + duplicateExtras > size) {
    throw ArgumentError('Pool $size is too small for the test solution');
  }

  final result = List<String>.from(solution);
  result.addAll(List<String>.filled(duplicateExtras, solution.first));
  const decoyCandidates = [
    'Q',
    'X',
    'Z',
    'S',
    'J',
    'W',
    'K',
    'V',
    'Y',
    'O',
    'C',
    'P',
    'T',
    'R',
    'M',
  ];
  var decoyIndex = 0;
  while (result.length < size) {
    final candidate = decoyCandidates[decoyIndex % decoyCandidates.length];
    decoyIndex++;
    if (!solution.contains(candidate)) result.add(candidate);
  }
  return result;
}

void _addSurplusLetters(
  List<String> pool,
  List<String> solution, {
  required String letter,
  required int amount,
}) {
  for (int count = 0; count < amount; count++) {
    final replaceIndex = pool.indexWhere(
      (candidate) =>
          candidate.isNotEmpty &&
          !solution.contains(candidate) &&
          candidate != 'S',
    );
    if (replaceIndex < 0) throw StateError('No decoy can be replaced');
    pool[replaceIndex] = letter;
  }
}

void _placeLetter(
  List<List<String>> answer,
  List<String> pool,
  GuessPuzzlePosition position,
  String letter,
) {
  final current = answer[position.wordIndex][position.letterIndex];
  if (current.isNotEmpty) {
    final emptyIndex = pool.indexOf('');
    if (emptyIndex < 0) throw StateError('No empty pool position');
    pool[emptyIndex] = current;
  }

  final poolIndex = pool.indexOf(letter);
  if (poolIndex < 0) throw StateError('$letter is not available in the pool');
  pool[poolIndex] = '';
  answer[position.wordIndex][position.letterIndex] = letter;
}

void _clearPosition(
  List<List<String>> answer,
  List<String> pool,
  GuessPuzzlePosition position,
) {
  final current = answer[position.wordIndex][position.letterIndex];
  if (current.isEmpty) return;
  final emptyIndex = pool.indexOf('');
  if (emptyIndex < 0) throw StateError('No empty pool position');
  pool[emptyIndex] = current;
  answer[position.wordIndex][position.letterIndex] = '';
}

void _expectBombInvariants(
  List<List<String>> correct,
  List<List<String>> answerBefore,
  GuessPuzzleState result,
  int poolSize,
) {
  expect(result.allLetters, hasLength(poolSize));
  _expectStateMultiset(correct, result);
  _expectSeparatorsPreserved(correct, result.answerLetters);

  final solution = _solutionLetters(correct);
  for (final position in GuessPuzzleLogic.letterPositions(correct)) {
    final letter =
        result.answerLetters[position.wordIndex][position.letterIndex];
    if (letter.isNotEmpty) expect(solution, contains(letter));

    final previous = answerBefore[position.wordIndex][position.letterIndex];
    final expected = correct[position.wordIndex][position.letterIndex];
    if (previous == expected) expect(letter, expected);
  }
  for (final letter in _poolLetters(result.allLetters)) {
    expect(solution, contains(letter));
  }

  _expectSolvable(correct, result);
}

void _expectSolvable(
  List<List<String>> correct,
  GuessPuzzleState source,
) {
  final answer = source.answerLetters.map(List<String>.from).toList();
  final pool = List<String>.from(source.allLetters);

  for (final position in GuessPuzzleLogic.letterPositions(correct)) {
    final current = answer[position.wordIndex][position.letterIndex];
    final expected = correct[position.wordIndex][position.letterIndex];
    if (current.isNotEmpty && current != expected) {
      final emptyIndex = pool.indexOf('');
      expect(emptyIndex, greaterThanOrEqualTo(0));
      pool[emptyIndex] = current;
      answer[position.wordIndex][position.letterIndex] = '';
    }
  }

  for (final position in GuessPuzzleLogic.letterPositions(correct)) {
    if (answer[position.wordIndex][position.letterIndex].isNotEmpty) continue;
    final expected = correct[position.wordIndex][position.letterIndex];
    final poolIndex = pool.indexOf(expected);
    expect(poolIndex, greaterThanOrEqualTo(0), reason: 'Missing $expected');
    pool[poolIndex] = '';
    answer[position.wordIndex][position.letterIndex] = expected;
  }

  expect(answer, equals(correct));
}

void _expectStateMultiset(
  List<List<String>> correct,
  GuessPuzzleState state, {
  bool allowDecoys = false,
}) {
  final actual = _lettersInState(correct, state);
  final expected = _solutionLetters(correct);
  if (allowDecoys) {
    for (final letter in expected) {
      final actualCount = _frequency(actual)[letter] ?? 0;
      final expectedCount = _frequency(expected)[letter] ?? 0;
      expect(actualCount, greaterThanOrEqualTo(expectedCount));
    }
  } else {
    expect(_frequency(actual), equals(_frequency(expected)));
  }
}

void _expectSeparatorsPreserved(
  List<List<String>> correct,
  List<List<String>> answer,
) {
  for (int wordIndex = 0; wordIndex < correct.length; wordIndex++) {
    for (int letterIndex = 0;
        letterIndex < correct[wordIndex].length;
        letterIndex++) {
      final letter = correct[wordIndex][letterIndex];
      if (GuessPuzzleLogic.isSeparator(letter)) {
        expect(answer[wordIndex][letterIndex], letter);
      }
    }
  }
}

Set<GuessPuzzlePosition> _correctlyPlacedPositions(
  List<List<String>> correct,
  List<List<String>> answer,
) {
  return GuessPuzzleLogic.letterPositions(correct).where((position) {
    final letter = answer[position.wordIndex][position.letterIndex];
    return letter.isNotEmpty &&
        letter == correct[position.wordIndex][position.letterIndex];
  }).toSet();
}

List<List<String>> _emptyFromCorrect(List<List<String>> correct) {
  return correct.map((row) {
    return row
        .map((letter) => GuessPuzzleLogic.isSeparator(letter) ? letter : '')
        .toList();
  }).toList();
}

List<String> _solutionLetters(List<List<String>> correct) {
  return correct
      .expand((row) => row)
      .where((letter) => !GuessPuzzleLogic.isSeparator(letter))
      .toList();
}

List<String> _lettersInState(
  List<List<String>> correct,
  GuessPuzzleState state,
) {
  return [
    ...GuessPuzzleLogic.letterPositions(correct).map(
      (position) =>
          state.answerLetters[position.wordIndex][position.letterIndex],
    ),
    ...state.allLetters,
  ].where((letter) => letter.isNotEmpty).toList();
}

List<String> _poolLetters(List<String> pool) {
  return pool.where((letter) => letter.isNotEmpty).toList();
}

String _answerText(List<List<String>> answer) {
  return answer
      .expand((row) => row)
      .where((letter) =>
          letter.isNotEmpty && !GuessPuzzleLogic.isSeparator(letter))
      .join();
}

Map<String, int> _frequency(Iterable<String> letters) {
  final result = <String, int>{};
  for (final letter in letters) {
    result[letter] = (result[letter] ?? 0) + 1;
  }
  return result;
}

void _expectSolutionLetters(List<List<String>> correct, String answer) {
  final expected = answer.replaceAll(' ', '').replaceAll('-', '').toUpperCase();
  expect(_solutionLetters(correct).join(), expected);
}
