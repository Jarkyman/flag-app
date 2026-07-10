import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../menu_page_header.dart';

class AppBarRowExit extends StatelessWidget {
  const AppBarRowExit({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: Dimensions.width10,
          right: Dimensions.width10,
          top: Dimensions.height10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MenuRoundButton(
            icon: Icons.close_rounded,
            accentColor: AppColors.coralColor,
            semanticLabel: MaterialLocalizations.of(context).closeButtonTooltip,
            onTap: Get.back,
          ),
          const MenuHintBadge(interactive: false),
        ],
      ),
    );
  }
}
