import 'analytics_gateway.dart';

class NoopAnalyticsGateway implements AnalyticsGateway {
  const NoopAnalyticsGateway();

  @override
  Future<void> logEvent({
    required String name,
    required Map<String, Object> parameters,
  }) async {}

  @override
  Future<void> logScreenView(String screenName) async {}

  @override
  Future<void> resetAnalyticsData() async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setConsent({
    required bool analyticsStorageGranted,
  }) async {}

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {}
}
