import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> showConsentForm({bool isForTest = false, String? testDeviceId}) async {
  ConsentDebugSettings? debugSettings;
  if (isForTest) {
    debugSettings = ConsentDebugSettings(
      debugGeography: DebugGeography.debugGeographyEea,
      testIdentifiers: testDeviceId != null && testDeviceId.isNotEmpty
          ? [testDeviceId]
          : null,
    );
  }

  final params = ConsentRequestParameters(
    tagForUnderAgeOfConsent: false,
    consentDebugSettings: debugSettings,
  );

  final consentInfo = ConsentInformation.instance;

  consentInfo.requestConsentInfoUpdate(
    params,
        () async {
      // Tjek om vi overhovedet skal vise formularen
      final status = await consentInfo.getConsentStatus();
      if (status == ConsentStatus.required) {
        final isAvailable = await consentInfo.isConsentFormAvailable();
        if (isAvailable) {
          ConsentForm.loadConsentForm(
                (ConsentForm form) {
              form.show(
                    (FormError? showError) {
                  if (showError != null) {
                    debugPrint('Fejl ved visning af formular: $showError');
                  } else {
                    debugPrint('Samtykkeformular vist én gang');
                  }
                },
              );
            },
                (FormError loadError) {
              debugPrint('Fejl ved indlæsning af formular: $loadError');
            },
          );
        }
      } else {
        debugPrint('Samtykkeformular ikke nødvendig (status: $status)');
      }
    },
        (FormError error) {
      debugPrint('Fejl ved consent update: $error');
    },
  );
}
