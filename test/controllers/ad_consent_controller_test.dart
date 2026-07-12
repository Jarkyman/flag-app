import 'package:flag_app/ads/ad_consent_gateway.dart';
import 'package:flag_app/controllers/ad_consent_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shows the settings entry only when UMP requires it', () async {
    final gateway = _FakeAdConsentGateway(
      requirement: AdPrivacyOptionsRequirement.required,
    );
    final controller = AdConsentController(gateway: gateway);

    await controller.initialize();

    expect(gateway.gatherCalls, 1);
    expect(controller.isPrivacyOptionsRequired, isTrue);
    expect(controller.lastError, isNull);
  });

  test('keeps the settings entry hidden when UMP does not require it',
      () async {
    final controller = AdConsentController(
      gateway: _FakeAdConsentGateway(
        requirement: AdPrivacyOptionsRequirement.notRequired,
      ),
    );

    await controller.initialize();

    expect(controller.isPrivacyOptionsRequired, isFalse);
  });

  test('opens privacy options and refreshes whether the entry is still needed',
      () async {
    final gateway = _FakeAdConsentGateway(
      requirement: AdPrivacyOptionsRequirement.required,
      requirementAfterForm: AdPrivacyOptionsRequirement.notRequired,
    );
    final controller = AdConsentController(gateway: gateway);
    await controller.initialize();

    expect(await controller.showPrivacyOptions(), isTrue);
    expect(gateway.showCalls, 1);
    expect(controller.isPrivacyOptionsRequired, isFalse);
  });

  test('records consent errors while still refreshing the requirement',
      () async {
    final controller = AdConsentController(
      gateway: _FakeAdConsentGateway(
        requirement: AdPrivacyOptionsRequirement.required,
        gatherError: StateError('offline'),
      ),
    );

    await controller.initialize();

    expect(controller.lastError, contains('offline'));
    expect(controller.isPrivacyOptionsRequired, isTrue);
  });
}

class _FakeAdConsentGateway implements AdConsentGateway {
  AdPrivacyOptionsRequirement requirement;
  final AdPrivacyOptionsRequirement? requirementAfterForm;
  final Object? gatherError;

  _FakeAdConsentGateway({
    required this.requirement,
    this.requirementAfterForm,
    this.gatherError,
  });

  int gatherCalls = 0;
  int showCalls = 0;

  @override
  Future<void> gatherConsent({
    bool isForTest = false,
    String? testDeviceId,
  }) async {
    gatherCalls++;
    if (gatherError != null) throw gatherError!;
  }

  @override
  Future<AdPrivacyOptionsRequirement> getPrivacyOptionsRequirement() async {
    return requirement;
  }

  @override
  Future<void> showPrivacyOptions() async {
    showCalls++;
    requirement = requirementAfterForm ?? requirement;
  }
}
