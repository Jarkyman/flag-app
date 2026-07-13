class GuessPuzzleState {
  final List<List<String>> answerLetters;
  final List<String> allLetters;

  const GuessPuzzleState({
    required this.answerLetters,
    required this.allLetters,
  });
}

class GuessPuzzlePosition {
  final int wordIndex;
  final int letterIndex;

  const GuessPuzzlePosition({
    required this.wordIndex,
    required this.letterIndex,
  });

  @override
  bool operator ==(Object other) {
    return other is GuessPuzzlePosition &&
        other.wordIndex == wordIndex &&
        other.letterIndex == letterIndex;
  }

  @override
  int get hashCode => Object.hash(wordIndex, letterIndex);

  @override
  String toString() => '($wordIndex, $letterIndex)';
}

class CorrectLetterHintResult extends GuessPuzzleState {
  final bool applied;
  final GuessPuzzlePosition? position;

  const CorrectLetterHintResult({
    required super.answerLetters,
    required super.allLetters,
    required this.applied,
    required this.position,
  });
}

class GuessPuzzleLogic {
  static const String lineBreak = '\u21b2';

  static List<List<String>> buildCorrectLetters(
    String answer, {
    int tilesPerRow = 9,
  }) {
    final words = answer.toUpperCase().split(' ');
    final lettersList = <List<String>>[];

    for (final word in words) {
      final wordSplit = word.split('');
      if (wordSplit.length > tilesPerRow) {
        var temp = <String>[];
        var maxLength = tilesPerRow - 2;
        if (wordSplit.contains('-') &&
            wordSplit.indexOf('-') + 1 <= tilesPerRow) {
          maxLength = wordSplit.indexOf('-') + 1;
        }

        for (int index = 0; index < wordSplit.length; index++) {
          if (temp.length == maxLength || temp.contains('-')) {
            if (!temp.contains('-')) temp.add(lineBreak);
            lettersList.add(temp);
            temp = [wordSplit[index]];
            if (temp.length >= tilesPerRow) maxLength += 2;
          } else {
            temp.add(wordSplit[index]);
          }
        }

        if (temp.isNotEmpty) {
          if (temp.length <= 2 && lettersList.isNotEmpty) {
            lettersList.last.remove(lineBreak);
            lettersList.last.addAll(temp);
          } else {
            lettersList.add(temp);
          }
        }
      } else {
        lettersList.add(wordSplit);
      }
    }

    if (lettersList.length > 1) {
      for (int index = 0; index < lettersList.length - 1; index++) {
        if (lettersList[index].length + lettersList[index + 1].length <=
            tilesPerRow - 1) {
          lettersList[index].add('/');
          lettersList[index].addAll(lettersList[index + 1]);
          lettersList.removeAt(index + 1);
        }
      }
    }

    return lettersList;
  }

  static List<List<String>> buildEmptyAnswer(
    String answer, {
    int tilesPerRow = 9,
  }) {
    final result = _copyGrid(
      buildCorrectLetters(answer, tilesPerRow: tilesPerRow),
    );

    for (final word in result) {
      for (int index = 0; index < word.length; index++) {
        if (!isSeparator(word[index])) word[index] = '';
      }
    }

    return result;
  }

  static List<List<String>> fitAnswerToLayout({
    required List<List<String>> correctLetters,
    required List<List<String>> answerLetters,
  }) {
    final savedLetters = answerLetters
        .expand((row) => row)
        .where((letter) => !isSeparator(letter))
        .toList();
    var savedIndex = 0;

    return correctLetters.map((row) {
      return row.map((correctLetter) {
        if (isSeparator(correctLetter)) return correctLetter;
        if (savedIndex >= savedLetters.length) return '';
        return savedLetters[savedIndex++];
      }).toList();
    }).toList();
  }

  static GuessPuzzleState applyBomb({
    required List<List<String>> correctLetters,
    required List<List<String>> answerLetters,
    required List<String> allLetters,
  }) {
    final answer = _copyGrid(answerLetters);
    final remainingCorrectLetters = correctLetters
        .expand((word) => word)
        .where((letter) => !isSeparator(letter))
        .toList();

    // Correctly placed letters are reserved before misplaced duplicates are
    // evaluated, so a surplus duplicate can never remove a correct letter.
    for (final position in letterPositions(correctLetters)) {
      final answerLetter = answer[position.wordIndex][position.letterIndex];
      final correctLetter =
          correctLetters[position.wordIndex][position.letterIndex];

      if (answerLetter == correctLetter) {
        _removeOne(remainingCorrectLetters, answerLetter);
      }
    }

    // A misplaced letter is kept only while the solution still needs one
    // occurrence. Additional duplicates and unrelated letters are removed.
    for (final position in letterPositions(correctLetters)) {
      final answerLetter = answer[position.wordIndex][position.letterIndex];
      final correctLetter =
          correctLetters[position.wordIndex][position.letterIndex];

      if (answerLetter.isEmpty || answerLetter == correctLetter) continue;

      final requiredIndex = remainingCorrectLetters.indexOf(answerLetter);
      if (requiredIndex >= 0) {
        remainingCorrectLetters.removeAt(requiredIndex);
      } else {
        answer[position.wordIndex][position.letterIndex] = '';
      }
    }

    final reducedLetters = List<String>.filled(allLetters.length, '');
    final usedIndexes = <int>{};

    for (final letter in remainingCorrectLetters) {
      var index = _availableIndex(allLetters, letter, usedIndexes);
      index = index >= 0 ? index : _availableIndex(allLetters, '', usedIndexes);
      index = index >= 0 ? index : _firstUnusedIndex(allLetters, usedIndexes);

      if (index < 0) continue;
      reducedLetters[index] = letter;
      usedIndexes.add(index);
    }

    return GuessPuzzleState(
      answerLetters: answer,
      allLetters: reducedLetters,
    );
  }

  static CorrectLetterHintResult applyCorrectLetterHint({
    required List<List<String>> correctLetters,
    required List<List<String>> answerLetters,
    required List<String> allLetters,
  }) {
    final answer = _copyGrid(answerLetters);
    final pool = List<String>.from(allLetters);
    GuessPuzzlePosition? target;

    for (final position in letterPositions(correctLetters)) {
      if (answer[position.wordIndex][position.letterIndex] !=
          correctLetters[position.wordIndex][position.letterIndex]) {
        target = position;
        break;
      }
    }

    if (target == null) {
      return CorrectLetterHintResult(
        answerLetters: answer,
        allLetters: pool,
        applied: false,
        position: null,
      );
    }

    final requiredLetter = correctLetters[target.wordIndex][target.letterIndex];
    final poolIndex = pool.indexOf(requiredLetter);
    GuessPuzzlePosition? source;

    if (poolIndex < 0) {
      for (final position in letterPositions(correctLetters)) {
        if (position == target) continue;
        final letter = answer[position.wordIndex][position.letterIndex];
        final isCorrectlyPlaced =
            letter == correctLetters[position.wordIndex][position.letterIndex];
        if (letter == requiredLetter && !isCorrectlyPlaced) {
          source = position;
          break;
        }
      }
    }

    if (poolIndex < 0 && source == null) {
      return CorrectLetterHintResult(
        answerLetters: answer,
        allLetters: pool,
        applied: false,
        position: null,
      );
    }

    final displacedLetter = answer[target.wordIndex][target.letterIndex];
    if (displacedLetter.isNotEmpty) {
      final emptyPoolIndex = pool.indexOf('');
      if (emptyPoolIndex < 0) {
        return CorrectLetterHintResult(
          answerLetters: answer,
          allLetters: pool,
          applied: false,
          position: null,
        );
      }
      pool[emptyPoolIndex] = displacedLetter;
    }

    if (poolIndex >= 0) {
      pool[poolIndex] = '';
    } else {
      answer[source!.wordIndex][source.letterIndex] = '';
    }
    answer[target.wordIndex][target.letterIndex] = requiredLetter;

    return CorrectLetterHintResult(
      answerLetters: answer,
      allLetters: pool,
      applied: true,
      position: target,
    );
  }

  static List<GuessPuzzlePosition> letterPositions(
    List<List<String>> letters,
  ) {
    final positions = <GuessPuzzlePosition>[];
    for (int wordIndex = 0; wordIndex < letters.length; wordIndex++) {
      for (int letterIndex = 0;
          letterIndex < letters[wordIndex].length;
          letterIndex++) {
        if (!isSeparator(letters[wordIndex][letterIndex])) {
          positions.add(
            GuessPuzzlePosition(
              wordIndex: wordIndex,
              letterIndex: letterIndex,
            ),
          );
        }
      }
    }
    return positions;
  }

  static bool isSeparator(String letter) {
    return letter == '-' || letter == '/' || letter == lineBreak;
  }

  static List<List<String>> _copyGrid(List<List<String>> source) {
    return source.map(List<String>.from).toList();
  }

  static void _removeOne(List<String> letters, String letter) {
    final index = letters.indexOf(letter);
    if (index >= 0) letters.removeAt(index);
  }

  static int _availableIndex(
    List<String> letters,
    String letter,
    Set<int> usedIndexes,
  ) {
    for (int index = 0; index < letters.length; index++) {
      if (!usedIndexes.contains(index) && letters[index] == letter) {
        return index;
      }
    }
    return -1;
  }

  static int _firstUnusedIndex(
    List<String> letters,
    Set<int> usedIndexes,
  ) {
    for (int index = 0; index < letters.length; index++) {
      if (!usedIndexes.contains(index)) return index;
    }
    return -1;
  }
}
