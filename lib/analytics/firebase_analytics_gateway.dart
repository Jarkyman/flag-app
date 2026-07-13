import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_gateway.dart';

class FirebaseAnalyticsGateway implements AnalyticsGateway {
  final FirebaseAnalytics analytics;

  FirebaseAnalyticsGateway({FirebaseAnalytics? analytics})
      : analytics = analytics ?? FirebaseAnalytics.instance;

  @override
  Future<void> setConsent({required bool analyticsStorageGranted}) {
    return analytics.setConsent(
      analyticsStorageConsentGranted: analyticsStorageGranted,
      adStorageConsentGranted: false,
      adPersonalizationSignalsConsentGranted: false,
      adUserDataConsentGranted: false,
    );
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> resetAnalyticsData() => analytics.resetAnalyticsData();

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) {
    return analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> logEvent({
    required String name,
    required Map<String, Object> parameters,
  }) {
    return analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> logScreenView(String screenName) {
    return analytics.logScreenView(screenName: screenName);
  }
}
