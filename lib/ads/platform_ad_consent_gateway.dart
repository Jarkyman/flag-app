import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent_gateway.dart';

class PlatformAdConsentGateway implements AdConsentGateway {
  @override
  Future<void> gatherConsent({
    bool isForTest = false,
    String? testDeviceId,
  }) {
    final completer = Completer<void>();
    final debugSettings = isForTest
        ? ConsentDebugSettings(
            debugGeography: DebugGeography.debugGeographyEea,
            testIdentifiers: testDeviceId != null && testDeviceId.isNotEmpty
                ? [testDeviceId]
                : null,
          )
        : null;
    final parameters = ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      consentDebugSettings: debugSettings,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      parameters,
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError == null) {
            completer.complete();
          } else {
            completer.completeError(_AdConsentException(formError));
          }
        });
      },
      (formError) => completer.completeError(_AdConsentException(formError)),
    );
    return completer.future;
  }

  @override
  Future<AdPrivacyOptionsRequirement> getPrivacyOptionsRequirement() async {
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return switch (status) {
      PrivacyOptionsRequirementStatus.required =>
        AdPrivacyOptionsRequirement.required,
      PrivacyOptionsRequirementStatus.notRequired =>
        AdPrivacyOptionsRequirement.notRequired,
      PrivacyOptionsRequirementStatus.unknown =>
        AdPrivacyOptionsRequirement.unknown,
    };
  }

  @override
  Future<void> showPrivacyOptions() {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError == null) {
        completer.complete();
      } else {
        completer.completeError(_AdConsentException(formError));
      }
    });
    return completer.future;
  }
}

class _AdConsentException implements Exception {
  final FormError error;

  const _AdConsentException(this.error);

  @override
  String toString() => 'Ad consent error ${error.errorCode}: ${error.message}';
}
