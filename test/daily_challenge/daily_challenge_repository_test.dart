import 'package:flag_app/daily_challenge/daily_challenge_repository.dart';
import 'package:flag_app/daily_challenge/models/daily_challenge_day.dart';
import 'package:flag_app/daily_challenge/models/daily_challenge_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists the active attempt for the current day', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = DailyChallengeRepository(
      sharedPreferences: preferences,
    );
    final day = DailyChallengeDay.fromKey('2026-07-27');
    final progress = DailyChallengeProgress(
      dayKey: day.key,
      status: DailyChallengeStatus.active,
      startedAtUtc: DateTime.utc(2026, 7, 27, 12),
      currentQuestionIndex: 4,
      wrongAnswers: 2,
      currentWrongCountryCodes: const {'DK'},
    );

    await repository.saveProgress(progress);
    final restored = repository.readProgress(day);

    expect(restored.status, DailyChallengeStatus.active);
    expect(restored.currentQuestionIndex, 4);
    expect(restored.wrongAnswers, 2);
    expect(restored.currentWrongCountryCodes, {'DK'});
  });

  test('starts fresh when the daily occurrence changes', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = DailyChallengeRepository(
      sharedPreferences: preferences,
    );
    await repository.saveProgress(
      DailyChallengeProgress(
        dayKey: '2026-07-27',
        status: DailyChallengeStatus.completed,
        scoreMilliseconds: 42000,
      ),
    );

    final nextDay = repository.readProgress(
      DailyChallengeDay.fromKey('2026-07-28'),
    );

    expect(nextDay.status, DailyChallengeStatus.ready);
    expect(nextDay.dayKey, '2026-07-28');
  });
}
