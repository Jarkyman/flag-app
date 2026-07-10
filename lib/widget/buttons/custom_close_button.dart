import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../app_controls.dart';

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.height10),
      child: Align(
        alignment: Alignment.topLeft,
        child: AppControlButton(
          icon: Icons.close_rounded,
          accentColor: AppColors.coralColor,
          semanticLabel: MaterialLocalizations.of(context).closeButtonTooltip,
          size: Dimensions.height20 * 2,
          onTap: Get.back,
        ),
      ),
    );
  }
}
