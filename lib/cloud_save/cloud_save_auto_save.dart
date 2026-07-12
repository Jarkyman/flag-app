import 'package:get/get.dart';

import '../controllers/cloud_save_controller.dart';

void scheduleCloudAutoSave() {
  if (Get.isRegistered<CloudSaveController>()) {
    Get.find<CloudSaveController>().scheduleAutoSave();
  }
}
