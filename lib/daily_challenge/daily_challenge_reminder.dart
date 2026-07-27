abstract class DailyChallengeReminder {
  Future<void> initialize();

  Future<bool> enable({
    required String title,
    required String body,
  });

  Future<void> disable();
}

class NoopDailyChallengeReminder implements DailyChallengeReminder {
  const NoopDailyChallengeReminder();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> enable({
    required String title,
    required String body,
  }) async {
    return false;
  }

  @override
  Future<void> disable() async {}
}
