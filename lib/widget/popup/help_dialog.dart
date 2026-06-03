import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helper/app_colors.dart';

import '../../helper/dimensions.dart';
import '../help_widget.dart';

void helpDialog(List<HelpWidget> helpWidgets) {
  showDialog(
    context: Get.context!,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
      ),
      backgroundColor: AppColors.lightGreen,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: SizedBox(
          width: Dimensions.width45 * 6,
          height: Get.height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Help'.tr,
                    style: TextStyle(
                      fontSize: Dimensions.font20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainBlackColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    color: AppColors.mainBlackColor,
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height10),
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
    ),
  );
}
