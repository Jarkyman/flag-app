import 'package:flag_app/daily_challenge/models/daily_challenge_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily occurrence changes at 07:00 UTC', () {
    expect(
      DailyChallengeDay.fromInstant(
        DateTime.utc(2026, 7, 27, 6, 59),
      ).key,
      '2026-07-26',
    );
    expect(
      DailyChallengeDay.fromInstant(
        DateTime.utc(2026, 7, 27, 7),
      ).key,
      '2026-07-27',
    );
  });

  test('remaining time uses the shared leaderboard boundary', () {
    final day = DailyChallengeDay.fromKey('2026-07-27');

    expect(
      day.remainingAt(DateTime.utc(2026, 7, 28, 6, 30)),
      const Duration(minutes: 30),
    );
  });
}
