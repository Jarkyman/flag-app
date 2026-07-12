import 'package:get/get.dart';

import '../controllers/ad_consent_controller.dart';

Future<void> showConsentForm({
  bool isForTest = false,
  String? testDeviceId,
}) {
  return Get.find<AdConsentController>().initialize(
    isForTest: isForTest,
    testDeviceId: testDeviceId,
  );
}
