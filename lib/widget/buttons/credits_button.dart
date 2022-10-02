import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class CreditsButton extends StatelessWidget {
  const CreditsButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          Container(
              height: Dimensions.height30 * 10,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(Dimensions.radius30),
              ),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.width10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: Dimensions.height30,
                    ),
                    Text('Made by Jackie H. Jensen\n', textScaleFactor: 1),
                    Text('Sound Effect from Pixabay\n', textScaleFactor: 1),
                    Text('Countries are from Djiass mapicon\n',
                        textScaleFactor: 1),
                  ],
                ),
              )),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius30)),
          enableDrag: true,
        );
      },
      child: Text(
        'Credits'.tr,
        style: TextStyle(color: AppColors.textColorGray),
      ),
    );
  }
}
