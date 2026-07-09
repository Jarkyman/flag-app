import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/dimensions.dart';
import '../help_widget.dart';
import 'app_dialog.dart';

void helpDialog(List<HelpWidget> helpWidgets) {
  showDialog(
    context: Get.context!,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (context) => AppDialog(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height20,
          Dimensions.width20,
          Dimensions.height25,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Dimensions.screenHeight * 0.62,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDialogHeader(
                title: 'Help'.tr,
                icon: Icons.lightbulb_outline_rounded,
              ),
              SizedBox(height: Dimensions.height20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: helpWidgets.length,
                  itemBuilder: (_, index) => helpWidgets[index],
                  separatorBuilder: (_, separatorIndex) =>
                      SizedBox(height: Dimensions.height10),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
