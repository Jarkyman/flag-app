import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../ads/ad_consent_gateway.dart';

class AdConsentController extends GetxController implements GetxService {
  final AdConsentGateway gateway;

  AdConsentController({required this.gateway});

  AdPrivacyOptionsRequirement _privacyOptionsRequirement =
      AdPrivacyOptionsRequirement.unknown;
  AdPrivacyOptionsRequirement get privacyOptionsRequirement =>
      _privacyOptionsRequirement;
  bool get isPrivacyOptionsRequired =>
      _privacyOptionsRequirement == AdPrivacyOptionsRequirement.required;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> initialize({
    bool isForTest = false,
    String? testDeviceId,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    _lastError = null;
    update();
    try {
      await gateway.gatherConsent(
        isForTest: isForTest,
        testDeviceId: testDeviceId,
      );
    } catch (error) {
      _lastError = error.toString();
      debugPrint('Could not gather ad consent: $error');
    } finally {
      await _refreshRequirement();
      _isLoading = false;
      update();
    }
  }

  Future<bool> showPrivacyOptions() async {
    if (!isPrivacyOptionsRequired || _isLoading) return false;
    _isLoading = true;
    _lastError = null;
    update();
    try {
      await gateway.showPrivacyOptions();
      return true;
    } catch (error) {
      _lastError = error.toString();
      debugPrint('Could not show ad privacy options: $error');
      return false;
    } finally {
      await _refreshRequirement();
      _isLoading = false;
      update();
    }
  }

  Future<void> _refreshRequirement() async {
    try {
      _privacyOptionsRequirement = await gateway.getPrivacyOptionsRequirement();
    } catch (error) {
      _privacyOptionsRequirement = AdPrivacyOptionsRequirement.unknown;
      _lastError ??= error.toString();
      debugPrint('Could not read ad privacy-options requirement: $error');
    }
  }
}
