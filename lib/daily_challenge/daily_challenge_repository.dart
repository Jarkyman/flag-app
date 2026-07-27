import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/daily_challenge_day.dart';
import 'models/daily_challenge_progress.dart';

class DailyChallengeRepository {
  static const String _progressKey = 'daily-challenge-progress-v1';
  static const String _reminderEnabledKey = 'daily-challenge-reminder-enabled';

  final SharedPreferences sharedPreferences;

  const DailyChallengeRepository({
    required this.sharedPreferences,
  });

  DailyChallengeProgress readProgress(DailyChallengeDay day) {
    final value = sharedPreferences.getString(_progressKey);
    if (value == null) return DailyChallengeProgress.ready(day.key);

    try {
      final progress = DailyChallengeProgress.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
      return progress.dayKey == day.key
          ? progress
          : DailyChallengeProgress.ready(day.key);
    } on FormatException {
      return DailyChallengeProgress.ready(day.key);
    } on TypeError {
      return DailyChallengeProgress.ready(day.key);
    } on StateError {
      return DailyChallengeProgress.ready(day.key);
    }
  }

  Future<void> saveProgress(DailyChallengeProgress progress) async {
    await sharedPreferences.setString(
      _progressKey,
      jsonEncode(progress.toJson()),
    );
  }

  bool get reminderEnabled =>
      sharedPreferences.getBool(_reminderEnabledKey) ?? false;

  Future<void> saveReminderEnabled(bool enabled) async {
    await sharedPreferences.setBool(_reminderEnabledKey, enabled);
  }
}
