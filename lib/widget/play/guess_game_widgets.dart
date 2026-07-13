import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../app_controls.dart';
import '../menu_page_header.dart';

class GuessGameHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onHelp;

  const GuessGameHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onHelp,
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
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width45 * 2.4,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(height: Dimensions.height10 * 0.35),
                AutoSizeText(
                  subtitle,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColorGray,
                    fontSize: Dimensions.font16 * 0.72,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: Dimensions.width10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppControlButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                  semanticLabel:
                      MaterialLocalizations.of(context).backButtonTooltip,
                ),
                SizedBox(width: Dimensions.width5),
                AppControlButton(
                  icon: Icons.question_mark_rounded,
                  onTap: onHelp,
                  accentColor: AppColors.skyColor,
                  semanticLabel: 'Help'.tr,
                ),
              ],
            ),
          ),
          Positioned(
            right: Dimensions.width10,
            child: const MenuHintBadge(),
          ),
        ],
      ),
    );
  }
}

class GuessHintActions extends StatelessWidget {
  final VoidCallback onFinish;
  final VoidCallback? onBomb;
  final VoidCallback onLetter;
  final Color accentColor;

  const GuessHintActions({
    super.key,
    required this.onFinish,
    required this.onBomb,
    required this.onLetter,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width15,
        Dimensions.height10 * 0.4,
        Dimensions.width15,
        Dimensions.height10,
      ),
      child: Row(
        children: [
          Expanded(
            child: _GuessHintButton(
              onTap: onFinish,
              icon: Icon(
                Icons.check_rounded,
                color: accentColor,
                size: Dimensions.iconSize24,
              ),
              price: '5',
              accentColor: accentColor,
              semanticLabel: 'Get the correct answer'.tr,
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: _GuessHintButton(
              onTap: onBomb,
              icon: ImageIcon(
                const AssetImage('assets/icon/bomb.png'),
                color: accentColor,
                size: Dimensions.iconSize24,
              ),
              price: '2',
              accentColor: accentColor,
              semanticLabel: 'Remove all the wrong letters'.tr,
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: _GuessHintButton(
              onTap: onLetter,
              icon: ImageIcon(
                const AssetImage('assets/icon/a.png'),
                color: accentColor,
                size: Dimensions.iconSize24,
              ),
              price: '1',
              accentColor: accentColor,
              semanticLabel: 'Get a correct Letter'.tr,
            ),
          ),
        ],
      ),
    );
  }
}

class GuessPromptCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const GuessPromptCard({
    super.key,
    required this.child,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFFFE).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.23),
          width: Dimensions.width5 * 0.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.09),
            blurRadius: Dimensions.radius20,
            offset: Offset(0, Dimensions.height10 * 0.5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        child: child,
      ),
    );
  }
}

class GuessLetterTray extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const GuessLetterTray({
    super.key,
    required this.child,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width10,
        vertical: Dimensions.height10 * 0.7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFFFE).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.14),
          width: Dimensions.width5 * 0.2,
        ),
      ),
      child: child,
    );
  }
}

class GuessFactData {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;
  final TextAlign textAlign;

  const GuessFactData({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.textAlign = TextAlign.right,
  });
}

class GuessFactsCard extends StatelessWidget {
  final List<GuessFactData> facts;
  final Color accentColor;

  const GuessFactsCard({
    super.key,
    required this.facts,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width15,
        vertical: Dimensions.height10 * 0.8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFFFE).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: Dimensions.width5 * 0.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainBlackColor.withValues(alpha: 0.06),
            blurRadius: Dimensions.radius20,
            offset: Offset(0, -Dimensions.height10 * 0.3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(facts.length, (index) {
            final fact = facts[index];
            return _GuessFactRow(
              fact: fact,
              accentColor: accentColor,
              showDivider: index < facts.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _GuessHintButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final String price;
  final Color accentColor;
  final String semanticLabel;

  const _GuessHintButton({
    required this.onTap,
    required this.icon,
    required this.price,
    required this.accentColor,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.42,
        duration: const Duration(milliseconds: 180),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            child: Ink(
              height: Dimensions.height20 * 2.35,
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFFFE).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.18),
                  width: Dimensions.width5 * 0.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  icon,
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
                        SizedBox(width: Dimensions.width5 * 0.35),
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
      ),
    );
  }
}

class _GuessFactRow extends StatelessWidget {
  final GuessFactData fact;
  final Color accentColor;
  final bool showDivider;

  const _GuessFactRow({
    required this.fact,
    required this.accentColor,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.height10 * 0.45),
          child: Row(
            children: [
              Container(
                width: Dimensions.width20 * 1.65,
                height: Dimensions.height20 * 1.65,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
                child: Icon(
                  fact.icon,
                  color: accentColor,
                  size: Dimensions.iconSize16,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              SizedBox(
                width: Dimensions.width20 * 5.6,
                child: AutoSizeText(
                  fact.label,
                  maxLines: 1,
                  minFontSize: Dimensions.font16 * 0.625,
                  stepGranularity: Dimensions.font16 / 16,
                  style: TextStyle(
                    color: AppColors.textColorGray,
                    fontSize: Dimensions.font16 * 0.76,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Flexible(
                flex: 3,
                child: AutoSizeText(
                  fact.value,
                  maxLines: fact.maxLines,
                  textAlign: fact.textAlign,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font16 * 0.86,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: Dimensions.height10 * 0.2,
            thickness: Dimensions.height10 * 0.08,
            color: accentColor.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}
