import '../../models/country_model.dart';

enum DailyChallengeQuestionType {
  flag,
  countryShape,
  coatOfArms;

  String get translationKey => switch (this) {
        DailyChallengeQuestionType.flag => 'Flag',
        DailyChallengeQuestionType.countryShape => 'Country map',
        DailyChallengeQuestionType.coatOfArms => 'Coat of arms',
      };

  String assetPath(String countryCode) {
    final code = countryCode.toLowerCase();
    return switch (this) {
      DailyChallengeQuestionType.flag => 'assets/image/flags/$code.webp',
      DailyChallengeQuestionType.countryShape =>
        'assets/image/countries/$code-full.webp',
      DailyChallengeQuestionType.coatOfArms =>
        'assets/image/coat of arms/$code.webp',
    };
  }
}

class DailyChallengeQuestion {
  final DailyChallengeQuestionType type;
  final CountryModel country;
  final List<CountryModel> options;

  const DailyChallengeQuestion({
    required this.type,
    required this.country,
    required this.options,
  });
}
