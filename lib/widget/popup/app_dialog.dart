import 'package:flutter/material.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';

class AppDialog extends StatelessWidget {
  final Widget child;

  const AppDialog({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height30,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Dimensions.width45 * 9.5,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFFFE),
            borderRadius: BorderRadius.circular(Dimensions.radius30),
            border: Border.all(
              color: AppColors.mainColor.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.mainBlackColor.withValues(alpha: 0.16),
                blurRadius: Dimensions.radius30,
                offset: Offset(0, Dimensions.height15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radius30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _DialogAccent(),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppDialogHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final bool showCloseButton;

  const AppDialogHeader({
    super.key,
    required this.title,
    required this.icon,
    this.accentColor = AppColors.mainColor,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: Dimensions.width20 * 2.2,
          height: Dimensions.height20 * 2.2,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          child: Icon(icon, color: accentColor, size: Dimensions.iconSize24),
        ),
        SizedBox(width: Dimensions.width15),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.mainBlackColor,
              fontSize: Dimensions.font20,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
        if (showCloseButton) ...[
          SizedBox(width: Dimensions.width10),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.mainColor.withValues(alpha: 0.08),
              foregroundColor: AppColors.mainBlackColor,
              minimumSize: Size(
                Dimensions.width20 * 2,
                Dimensions.height20 * 2,
              ),
            ),
            icon: Icon(
              Icons.close_rounded,
              size: Dimensions.iconSize24,
            ),
          ),
        ],
      ],
    );
  }
}

class AppDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;

  const AppDialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(double.infinity, Dimensions.height20 * 2.6),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w700),
      ),
    );

    if (primary) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: buttonStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.textColorGray.withValues(alpha: 0.3)
                : AppColors.mainColor,
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
        icon: icon == null
            ? const SizedBox.shrink()
            : Icon(icon, size: Dimensions.iconSize24),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: buttonStyle.copyWith(
        foregroundColor: const WidgetStatePropertyAll(AppColors.mainBlackColor),
        side: WidgetStatePropertyAll(
          BorderSide(color: AppColors.mainColor.withValues(alpha: 0.55)),
        ),
      ),
      icon: icon == null
          ? const SizedBox.shrink()
          : Icon(icon, size: Dimensions.iconSize24),
      label: Text(label),
    );
  }
}

class _DialogAccent extends StatelessWidget {
  const _DialogAccent();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height10 / 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.mainColor, AppColors.correctColor],
        ),
      ),
    );
  }
}
