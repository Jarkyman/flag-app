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
      final status = consentInfo.getConsentStatus();
      if (status == ConsentStatus.required) {
        final isAvailable = await consentInfo.isConsentFormAvailable();
        if (isAvailable) {
          ConsentForm.loadConsentForm(
                (ConsentForm form) {
              form.show(
                    (FormError? showError) {
                  if (showError != null) {
                    print('Fejl ved visning af formular: $showError');
                  } else {
                    print('Samtykkeformular vist én gang');
                  }
                },
              );
            },
                (FormError loadError) {
              print('Fejl ved indlæsning af formular: $loadError');
            },
          );
        }
      } else {
        print('Samtykkeformular ikke nødvendig (status: $status)');
      }
    },
        (FormError error) {
      print('Fejl ved consent update: $error');
    },
  );
}
