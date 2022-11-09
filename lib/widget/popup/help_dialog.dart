import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/dimensions.dart';
import '../help_widget.dart';

void helpDialog(List<HelpWidget> helpWidgets) {
  Get.defaultDialog(
    title: 'Help'.tr,
    middleText: '',
    backgroundColor: Colors.white,
    radius: 30,
    titleStyle: const TextStyle(
      decoration: TextDecoration.underline,
    ),
    content: SizedBox(
      width: Dimensions.width45 * 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: helpWidgets,
      ),
    ),
  );
}
