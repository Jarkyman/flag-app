import 'package:flag_app/controllers/daily_challenge_controller.dart';
import 'package:flag_app/daily_challenge/daily_challenge_generator.dart';
import 'package:flag_app/daily_challenge/daily_challenge_reminder.dart';
import 'package:flag_app/daily_challenge/daily_challenge_repository.dart';
import 'package:flag_app/daily_challenge/models/daily_challenge_progress.dart';
import 'package:flag_app/models/country_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('completes ten questions and adds wrong-answer penalties', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var currentTime = DateTime.utc(2026, 7, 27, 12);
    int? submittedScore;
    String? submittedDay;
    final controller = DailyChallengeController(
      repository: DailyChallengeRepository(
        sharedPreferences: preferences,
      ),
      reminder: const _Reminder(),
      countriesProvider: _countries,
      submitScore: ({
        required int scoreMilliseconds,
        required String dayKey,
      }) async {
        submittedScore = scoreMilliseconds;
        submittedDay = dayKey;
      },
      now: () => currentTime,
      answerTransitionDuration: Duration.zero,
    );

    await controller.initialize();
    await controller.start();

    final firstQuestion = controller.currentQuestion!;
    final wrongOption = firstQuestion.options.firstWhere(
      (option) => option.countryCode != firstQuestion.country.countryCode,
    );
    await controller.answer(wrongOption);
    expect(controller.wrongAnswers, 1);

    for (var index = 0;
        index < DailyChallengeGenerator.questionCount;
        index++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      await controller.answer(controller.currentQuestion!.country);
    }

    expect(controller.status, DailyChallengeStatus.completed);
    expect(controller.progress.rawElapsedMilliseconds, 10000);
    expect(controller.completedScoreMilliseconds, 13000);
    expect(submittedScore, 13000);
    expect(submittedDay, '2026-07-27');
  });

  test('only counts the same wrong option once', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = DailyChallengeController(
      repository: DailyChallengeRepository(
        sharedPreferences: preferences,
      ),
      reminder: const _Reminder(),
      countriesProvider: _countries,
      submitScore: ({
        required int scoreMilliseconds,
        required String dayKey,
      }) async {},
      now: () => DateTime.utc(2026, 7, 27, 12),
      answerTransitionDuration: Duration.zero,
    );
    await controller.initialize();
    await controller.start();
    final question = controller.currentQuestion!;
    final wrongOption = question.options.firstWhere(
      (option) => option.countryCode != question.country.countryCode,
    );

    await controller.answer(wrongOption);
    await controller.answer(wrongOption);

    expect(controller.wrongAnswers, 1);
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

class _Reminder implements DailyChallengeReminder {
  const _Reminder();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> enable({
    required String title,
    required String body,
  }) async {
    return true;
  }

  @override
  Future<void> disable() async {}
}
