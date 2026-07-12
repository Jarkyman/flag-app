enum AdPrivacyOptionsRequirement { unknown, notRequired, required }

abstract class AdConsentGateway {
  Future<void> gatherConsent({
    bool isForTest = false,
    String? testDeviceId,
  });

  Future<AdPrivacyOptionsRequirement> getPrivacyOptionsRequirement();

  Future<void> showPrivacyOptions();
}
