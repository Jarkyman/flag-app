abstract class AnalyticsGateway {
  Future<void> setConsent({required bool analyticsStorageGranted});

  Future<void> setCollectionEnabled(bool enabled);

  Future<void> resetAnalyticsData();

  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  Future<void> logEvent({
    required String name,
    required Map<String, Object> parameters,
  });

  Future<void> logScreenView(String screenName);
}
