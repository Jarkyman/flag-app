import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/dimensions.dart';
import '../help_widget.dart';

void helpDialog(List<HelpWidget> helpWidgets) {
  showDialog(
    context: Get.context!,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: SizedBox(
        width: Dimensions.width45 * 6,
        height: Get.height * 0.5,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ),
            Center(
              child: Text(
                'Help'.tr,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: Dimensions.font16 * 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: helpWidgets,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
