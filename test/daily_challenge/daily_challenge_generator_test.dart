import 'package:flag_app/daily_challenge/daily_challenge_generator.dart';
import 'package:flag_app/daily_challenge/models/daily_challenge_day.dart';
import 'package:flag_app/daily_challenge/models/daily_challenge_question.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = DailyChallengeGenerator();
  final day = DailyChallengeDay.fromKey('2026-07-27');

  test('generates ten unique and balanced questions', () {
    final questions = generator.generate(
      countries: _countries(),
      day: day,
    );

    expect(questions, hasLength(DailyChallengeGenerator.questionCount));
    expect(
      questions.map((question) => question.country.countryCode).toSet(),
      hasLength(DailyChallengeGenerator.questionCount),
    );
    expect(
      questions
          .where(
            (question) => question.type == DailyChallengeQuestionType.flag,
          )
          .length,
      4,
    );
    expect(
      questions
          .where(
            (question) =>
                question.type == DailyChallengeQuestionType.countryShape,
          )
          .length,
      3,
    );
    expect(
      questions
          .where(
            (question) =>
                question.type == DailyChallengeQuestionType.coatOfArms,
          )
          .length,
      3,
    );
    for (final question in questions) {
      expect(question.options, hasLength(4));
      expect(
        question.options.map((option) => option.countryCode).toSet(),
        hasLength(4),
      );
      expect(question.options, contains(question.country));
    }
  });

  test('uses country codes so every locale gets the same challenge', () {
    final english = generator.generate(countries: _countries(), day: day);
    final localizedCountries = _countries().reversed.map((country) {
      return CountryModel(
        countryCode: country.countryCode,
        countryName: 'Localized ${country.countryCode}',
      );
    }).toList();
    final localized = generator.generate(
      countries: localizedCountries,
      day: day,
    );

    expect(
      localized.map((question) => question.country.countryCode),
      english.map((question) => question.country.countryCode),
    );
    expect(
      localized.map(
        (question) =>
            question.options.map((option) => option.countryCode).toList(),
      ),
      english.map(
        (question) =>
            question.options.map((option) => option.countryCode).toList(),
      ),
    );
  });

  test('changes the challenge on the next day', () {
    final first = generator.generate(countries: _countries(), day: day);
    final next = generator.generate(
      countries: _countries(),
      day: DailyChallengeDay.fromKey('2026-07-28'),
    );

    expect(
      next.map((question) => question.country.countryCode).toList(),
      isNot(
        equals(
          first.map((question) => question.country.countryCode).toList(),
        ),
      ),
    );
  });
}

List<CountryModel> _countries() {
  return List.generate(30, (index) {
    return CountryModel(
      countryCode: 'C${index.toString().padLeft(2, '0')}',
      countryName: 'Country $index',
    );
  });
}
