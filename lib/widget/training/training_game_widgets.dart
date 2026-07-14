import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../helper/image_decode_size.dart';
import '../../models/training_continent.dart';
import '../app_controls.dart';
import '../menu_page_header.dart';

enum TrainingAnswerState { idle, correct, wrong, disabled }

class TrainingGameHeader extends StatelessWidget {
  final int score;
  final int highScore;
  final Color accentColor;
  final TrainingContinent selectedContinent;
  final VoidCallback? onContinentTap;

  const TrainingGameHeader({
    super.key,
    required this.score,
    required this.highScore,
    required this.accentColor,
    required this.selectedContinent,
    required this.onContinentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuPageHeader(
          title: '',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TrainingContinentButton(
                continent: selectedContinent,
                accentColor: accentColor,
                onTap: onContinentTap,
              ),
              SizedBox(width: Dimensions.width5),
              const MenuHintBadge(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
          child: Container(
            height: Dimensions.height20 * 2.7,
            decoration: BoxDecoration(
              color: const Color(0xFFFCFFFE).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(Dimensions.radius20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.16),
                width: Dimensions.width5 * 0.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mainBlackColor.withValues(alpha: 0.05),
                  blurRadius: Dimensions.radius15,
                  offset: Offset(0, Dimensions.height10 * 0.4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TrainingStat(
                    icon: Icons.bolt_rounded,
                    label: 'Score'.tr,
                    value: score,
                    color: accentColor,
                  ),
                ),
                Container(
                  width: Dimensions.width5 * 0.2,
                  height: Dimensions.height30,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                Expanded(
                  child: _TrainingStat(
                    icon: Icons.star_rounded,
                    label: 'Record'.tr,
                    value: highScore,
                    color: AppColors.yellowColor,
                    mirrored: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrainingContinentButton extends StatelessWidget {
  final TrainingContinent continent;
  final Color accentColor;
  final VoidCallback? onTap;

  const _TrainingContinentButton({
    required this.continent,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.45,
      duration: const Duration(milliseconds: 180),
      child: IgnorePointer(
        ignoring: !enabled,
        child: Stack(
          children: [
            AppControlButton(
              icon: Icons.travel_explore_rounded,
              onTap: onTap ?? () {},
              accentColor: accentColor,
              semanticLabel:
                  '${'Filter by continent'.tr}: ${continent.translationKey.tr}',
            ),
            if (continent != TrainingContinent.all)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: Dimensions.width20,
                    minHeight: Dimensions.height10 * 1.45,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width5 * 0.45,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                    border: Border.all(
                      color: const Color(0xFFFCFFFE),
                      width: Dimensions.width5 * 0.3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    continent.shortCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font16 * 0.52,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrainingStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final bool mirrored;

  const _TrainingStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.mirrored = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: Dimensions.width20 * 1.6,
      height: Dimensions.height20 * 1.6,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: Dimensions.iconSize16),
    );
    final textWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          mirrored ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: mirrored ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            color: AppColors.textColorGray,
            fontSize: Dimensions.font16 * 0.72,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$value',
          textAlign: mirrored ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            color: AppColors.mainBlackColor,
            fontSize: Dimensions.font20,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: mirrored
          ? [
              textWidget,
              SizedBox(width: Dimensions.width10),
              iconWidget,
            ]
          : [
              iconWidget,
              SizedBox(width: Dimensions.width10),
              textWidget,
            ],
    );
  }
}

class TrainingHintActions extends StatelessWidget {
  final VoidCallback onCorrectAnswer;
  final VoidCallback onFiftyFifty;
  final bool correctAnswerUsed;
  final bool fiftyFiftyUsed;
  final Color accentColor;

  const TrainingHintActions({
    super.key,
    required this.onCorrectAnswer,
    required this.onFiftyFifty,
    required this.correctAnswerUsed,
    required this.fiftyFiftyUsed,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width15,
        Dimensions.height10,
        Dimensions.width15,
        Dimensions.height10,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TrainingHintAction(
              onTap: correctAnswerUsed ? null : onCorrectAnswer,
              icon: Icon(
                Icons.check_rounded,
                color: accentColor,
                size: Dimensions.iconSize24,
              ),
              label: 'Correct'.tr,
              price: '3',
              accentColor: accentColor,
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: _TrainingHintAction(
              onTap: fiftyFiftyUsed ? null : onFiftyFifty,
              icon: ImageIcon(
                const AssetImage('assets/icon/fifty_fifty.png'),
                color: accentColor,
                size: Dimensions.iconSize24,
              ),
              label: '50 / 50',
              price: '1',
              accentColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingHintAction extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final String label;
  final String price;
  final Color accentColor;

  const _TrainingHintAction({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.price,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.45,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          child: Ink(
            height: Dimensions.height20 * 2.4,
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFFFE).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.16),
                width: Dimensions.width5 * 0.2,
              ),
            ),
            child: Row(
              children: [
                icon,
                SizedBox(width: Dimensions.width5),
                Expanded(
                  child: AutoSizeText(
                    label,
                    maxLines: 2,
                    style: TextStyle(
                      color: AppColors.mainBlackColor,
                      fontSize: Dimensions.font16 * 0.86,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.width5),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width5,
                    vertical: Dimensions.height10 * 0.2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yellowColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: AppColors.yellowColor,
                        size: Dimensions.iconSize16 * 0.82,
                      ),
                      SizedBox(width: Dimensions.width5 * 0.4),
                      Text(
                        price,
                        style: TextStyle(
                          color: AppColors.mainBlackColor,
                          fontSize: Dimensions.font16 * 0.78,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrainingPromptCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry? padding;

  const TrainingPromptCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: padding ?? EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFFFE).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: Dimensions.width5 * 0.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.09),
            blurRadius: Dimensions.radius20,
            offset: Offset(0, Dimensions.height10 * 0.6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TrainingTextPrompt extends StatelessWidget {
  final String text;
  final Color accentColor;

  const TrainingTextPrompt({
    super.key,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return TrainingPromptCard(
      accentColor: accentColor,
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: Center(
        child: AutoSizeText(
          text,
          maxLines: 2,
          minFontSize: Dimensions.font16,
          stepGranularity: Dimensions.font16 / 16,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.mainBlackColor,
            fontSize: Dimensions.font26 * 1.25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class TrainingTextAnswerCard extends StatelessWidget {
  final String text;
  final Color accentColor;
  final TrainingAnswerState state;
  final VoidCallback? onTap;

  const TrainingTextAnswerCard({
    super.key,
    required this.text,
    required this.accentColor,
    required this.state,
    required this.onTap,
  });

  Color get _stateColor {
    switch (state) {
      case TrainingAnswerState.correct:
        return AppColors.correctColor;
      case TrainingAnswerState.wrong:
        return AppColors.wrongColor;
      case TrainingAnswerState.disabled:
        return AppColors.textColorGray;
      case TrainingAnswerState.idle:
        return accentColor;
    }
  }

  IconData? get _stateIcon {
    switch (state) {
      case TrainingAnswerState.correct:
        return Icons.check_rounded;
      case TrainingAnswerState.wrong:
        return Icons.close_rounded;
      case TrainingAnswerState.disabled:
        return Icons.remove_rounded;
      case TrainingAnswerState.idle:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _stateColor;
    final isIdle = state == TrainingAnswerState.idle;
    final disabled = state == TrainingAnswerState.disabled;

    return AnimatedScale(
      scale: state == TrainingAnswerState.correct ? 1.02 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: disabled ? 0.48 : 1,
        duration: const Duration(milliseconds: 180),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onTap,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            child: Ink(
              height: Dimensions.height20 * 2.7,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
              decoration: BoxDecoration(
                color: isIdle
                    ? const Color(0xFFFCFFFE).withValues(alpha: 0.95)
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                border: Border.all(
                  color: color.withValues(alpha: isIdle ? 0.18 : 0.75),
                  width: Dimensions.width5 * 0.2,
                ),
                boxShadow: isIdle
                    ? [
                        BoxShadow(
                          color: AppColors.mainBlackColor.withValues(
                            alpha: 0.045,
                          ),
                          blurRadius: Dimensions.radius10,
                          offset: Offset(0, Dimensions.height10 * 0.35),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: Dimensions.width20 * 1.6 + Dimensions.width10,
                  ),
                  Expanded(
                    child: AutoSizeText(
                      text,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isIdle
                            ? AppColors.mainBlackColor
                            : disabled
                                ? AppColors.textColorGray
                                : color,
                        fontSize: Dimensions.font20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width10),
                  _stateIcon == null
                      ? SizedBox(
                          width: Dimensions.width20 * 1.6,
                          height: Dimensions.height20 * 1.6,
                        )
                      : Container(
                          width: Dimensions.width20 * 1.6,
                          height: Dimensions.height20 * 1.6,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _stateIcon,
                            color: color,
                            size: Dimensions.iconSize16,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TrainingFlagAnswerGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const TrainingFlagAnswerGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const naturalAspectRatio = 1.45;
        final rowCount = (itemCount / crossAxisCount).ceil();
        if (rowCount == 0) return const SizedBox.shrink();

        final mainAxisSpacing = Dimensions.height10;
        final crossAxisSpacing = Dimensions.width10;
        final itemWidth =
            (constraints.maxWidth - crossAxisSpacing * (crossAxisCount - 1)) /
                crossAxisCount;
        final naturalItemHeight = itemWidth / naturalAspectRatio;
        final availableItemHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - mainAxisSpacing * (rowCount - 1)) /
                rowCount
            : naturalItemHeight;
        final itemHeight =
            availableItemHeight > 0 && availableItemHeight < naturalItemHeight
                ? availableItemHeight
                : naturalItemHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: itemHeight,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class TrainingFlagAnswerCard extends StatelessWidget {
  final String image;
  final Color accentColor;
  final TrainingAnswerState state;
  final VoidCallback? onTap;

  const TrainingFlagAnswerCard({
    super.key,
    required this.image,
    required this.accentColor,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final correct = state == TrainingAnswerState.correct;
    final wrong = state == TrainingAnswerState.wrong;
    final disabled = state == TrainingAnswerState.disabled;
    final stateColor = correct
        ? AppColors.correctColor
        : wrong
            ? AppColors.wrongColor
            : accentColor;

    return AnimatedScale(
      scale: correct ? 1.025 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: disabled ? 0.34 : 1,
        duration: const Duration(milliseconds: 180),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onTap,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            child: Ink(
              padding: EdgeInsets.all(Dimensions.width10),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFFFE).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                border: Border.all(
                  color: stateColor.withValues(
                    alpha: correct || wrong ? 0.8 : 0.16,
                  ),
                  width: Dimensions.width5 * 0.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainBlackColor.withValues(alpha: 0.05),
                    blurRadius: Dimensions.radius10,
                    offset: Offset(0, Dimensions.height10 * 0.35),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(Dimensions.width5),
                      child: Image.asset(
                        image,
                        fit: BoxFit.contain,
                        cacheWidth: imageDecodeWidth(
                          logicalWidth: Dimensions.screenWidth / 2,
                          devicePixelRatio:
                              MediaQuery.devicePixelRatioOf(context),
                        ),
                      ),
                    ),
                  ),
                  if (correct || wrong)
                    Container(
                      width: Dimensions.width20 * 2.4,
                      height: Dimensions.height20 * 2.4,
                      decoration: BoxDecoration(
                        color: stateColor.withValues(alpha: 0.94),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: stateColor.withValues(alpha: 0.25),
                            blurRadius: Dimensions.radius10,
                          ),
                        ],
                      ),
                      child: Icon(
                        correct ? Icons.check_rounded : Icons.close_rounded,
                        color: Colors.white,
                        size: Dimensions.iconSize24,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
