import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/dimensions.dart';
import '../menu_page_header.dart';

class AppBarRow extends StatelessWidget {
  const AppBarRow({super.key});

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
            icon: Icons.arrow_back_ios_new_rounded,
            semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
            onTap: Get.back,
          ),
          const MenuHintBadge(),
        ],
      ),
    );
  }
}
