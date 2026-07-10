import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/app_colors.dart';
import '../helper/dimensions.dart';
import 'app_controls.dart';

class MenuPageHeader extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final Color leadingAccentColor;
  final bool showHintBadge;
  final Widget? trailing;

  const MenuPageHeader({
    super.key,
    required this.title,
    this.leadingIcon = Icons.arrow_back_ios_new_rounded,
    this.onLeadingTap,
    this.leadingAccentColor = AppColors.mainColor,
    this.showHintBadge = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.height20 * 3.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width45 * 2),
            child: AutoSizeText(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mainBlackColor,
                fontSize: Dimensions.font26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            left: Dimensions.width10,
            child: MenuRoundButton(
              icon: leadingIcon,
              onTap: onLeadingTap ?? Get.back,
              accentColor: leadingAccentColor,
              semanticLabel: leadingIcon == Icons.close_rounded
                  ? MaterialLocalizations.of(context).closeButtonTooltip
                  : MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
          if (trailing != null || showHintBadge)
            Positioned(
              right: Dimensions.width10,
              child: trailing ?? const MenuHintBadge(),
            ),
        ],
      ),
    );
  }
}

class MenuRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;
  final String? semanticLabel;

  const MenuRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.accentColor = AppColors.mainColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppControlButton(
      icon: icon,
      onTap: onTap,
      accentColor: accentColor,
      semanticLabel: semanticLabel,
    );
  }
}

class MenuHintBadge extends StatelessWidget {
  final bool interactive;

  const MenuHintBadge({
    super.key,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppHintBadge(interactive: interactive);
  }
}
