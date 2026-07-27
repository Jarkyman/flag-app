import '../models/country_model.dart';
import 'models/daily_challenge_day.dart';
import 'models/daily_challenge_question.dart';

class DailyChallengeGenerator {
  static const int questionCount = 10;
  static const int optionCount = 4;

  const DailyChallengeGenerator();

  List<DailyChallengeQuestion> generate({
    required List<CountryModel> countries,
    required DailyChallengeDay day,
  }) {
    final eligibleCountries = countries
        .where(
          (country) =>
              country.countryCode?.isNotEmpty == true &&
              country.countryName?.isNotEmpty == true,
        )
        .toList(growable: false)
      ..sort(
        (first, second) => first.countryCode!.compareTo(second.countryCode!),
      );
    if (eligibleCountries.length < questionCount + optionCount - 1) {
      throw StateError('Not enough countries for a daily challenge');
    }

    final questionCountries = List<CountryModel>.of(eligibleCountries);
    _StableRandom(_stableSeed(day.key)).shuffle(questionCountries);

    final types = List<DailyChallengeQuestionType>.of(_questionTypes);
    _StableRandom(_stableSeed('${day.key}:types')).shuffle(types);

    return List.generate(questionCount, (index) {
      final country = questionCountries[index];
      final optionPool = eligibleCountries
          .where((candidate) => candidate.countryCode != country.countryCode)
          .toList(growable: false);
      final optionRandom = _StableRandom(
        _stableSeed('${day.key}:${country.countryCode}:options'),
      )..shuffle(optionPool);
      final options = <CountryModel>[
        country,
        ...optionPool.take(optionCount - 1),
      ];
      optionRandom.shuffle(options);

      return DailyChallengeQuestion(
        type: types[index],
        country: country,
        options: options,
      );
    }, growable: false);
  }

  static const List<DailyChallengeQuestionType> _questionTypes = [
    DailyChallengeQuestionType.flag,
    DailyChallengeQuestionType.flag,
    DailyChallengeQuestionType.flag,
    DailyChallengeQuestionType.flag,
    DailyChallengeQuestionType.countryShape,
    DailyChallengeQuestionType.countryShape,
    DailyChallengeQuestionType.countryShape,
    DailyChallengeQuestionType.coatOfArms,
    DailyChallengeQuestionType.coatOfArms,
    DailyChallengeQuestionType.coatOfArms,
  ];

  int _stableSeed(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}

class _StableRandom {
  int _state;

  _StableRandom(int seed) : _state = seed == 0 ? 0x6d2b79f5 : seed;

  int nextInt(int maximum) {
    if (maximum <= 0) {
      throw ArgumentError.value(maximum, 'maximum');
    }
    var value = _state;
    value ^= (value << 13) & 0xffffffff;
    value ^= value >> 17;
    value ^= (value << 5) & 0xffffffff;
    _state = value & 0xffffffff;
    return _state % maximum;
  }

  void shuffle<T>(List<T> values) {
    for (var index = values.length - 1; index > 0; index--) {
      final replacementIndex = nextInt(index + 1);
      final value = values[index];
      values[index] = values[replacementIndex];
      values[replacementIndex] = value;
    }
  }
}
