import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/dimensions.dart';
import '../help_widget.dart';

void helpDialog(List<HelpWidget> helpWidgets) {
  Get.defaultDialog(
    title: '',
    titlePadding: const EdgeInsets.only(top: 0),
    backgroundColor: Colors.white,
    radius: 30,
    titleStyle: const TextStyle(
      decoration: TextDecoration.underline,
    ),
    content: Stack(
      children: [
        Positioned(
          top: -16,
          right: -16,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Get.back();
            },
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
        SizedBox(
          width: Dimensions.width45 * 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Help'.tr,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: Dimensions.font16 * 2,
                  ),
                ),
              ),
              Column(
                children: helpWidgets,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
