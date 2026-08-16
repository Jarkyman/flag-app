import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/daily_challenge_controller.dart';
import '../../controllers/game_services_controller.dart';
import '../../controllers/review_controller.dart';
import '../../daily_challenge/daily_challenge_generator.dart';
import '../../daily_challenge/models/daily_challenge_progress.dart';
import '../../daily_challenge/models/daily_challenge_question.dart';
import '../../helper/app_colors.dart';
import '../../helper/dimensions.dart';
import '../../helper/image_decode_size.dart';
import '../../game_services/models/game_leaderboard_score.dart';
import '../../models/country_model.dart';
import '../../widget/app_controls.dart';
import '../../widget/menu_background.dart';
import '../../widget/menu_page_header.dart';
import '../../widget/training/training_game_widgets.dart';

class DailyChallengePage extends StatefulWidget {
  const DailyChallengePage({super.key});

  @override
  State<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  static const Color _accentColor = AppColors.purpleColor;

  late final DailyChallengeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DailyChallengeController>();
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _controller.pauseLiveUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuBackground(
        child: SafeArea(
          bottom: false,
          child: GetBuilder<DailyChallengeController>(
            builder: (controller) {
              if (!controller.isInitialized) {
                return const Center(
                  child: CircularProgressIndicator(color: _accentColor),
                );
              }

              return Column(
                children: [
                  MenuPageHeader(
                    title: 'Daily challenge'.tr,
                    showHintBadge: false,
                    leadingAccentColor: _accentColor,
                    trailing: AppControlButton(
                      icon: controller.reminderEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      onTap: () => _toggleReminder(controller),
                      accentColor: controller.reminderEnabled
                          ? AppColors.goldColor
                          : _accentColor,
                      semanticLabel: 'Daily reminder'.tr,
                    ),
                  ),
                  Expanded(
                    child: switch (controller.status) {
                      DailyChallengeStatus.ready =>
                        _DailyChallengeLanding(controller: controller),
                      DailyChallengeStatus.active => _DailyChallengeGame(
                          controller: controller,
                          onAnswer: _answer,
                        ),
                      DailyChallengeStatus.completed =>
                        _DailyChallengeResults(controller: controller),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _toggleReminder(DailyChallengeController controller) async {
    await _updateReminder(
      controller,
      !controller.reminderEnabled,
      context,
    );
  }

  Future<void> _answer(CountryModel option) async {
    await _controller.answer(option);
    if (!mounted || _controller.status != DailyChallengeStatus.completed) {
      return;
    }
    ReviewController.checkReviewPopup(
      context,
      trainingScore: DailyChallengeGenerator.questionCount,
    );
  }
}

class _DailyChallengeLanding extends StatelessWidget {
  final DailyChallengeController controller;

  const _DailyChallengeLanding({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height10,
        Dimensions.width20,
        Dimensions.height30,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Dimensions.width20),
            decoration: _cardDecoration(
              accentColor: AppColors.purpleColor,
              accentOpacity: 0.24,
            ),
            child: Column(
              children: [
                _ChallengeEmblem(
                  progress: 0,
                  centerIcon: Icons.timer_outlined,
                ),
                SizedBox(height: Dimensions.height20),
                Text(
                  '10 countries. One global clock.'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font26,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  'Flags, maps and coats of arms. Everyone gets the same challenge.'
                      .tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColorGray,
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Row(
                  children: [
                    Expanded(
                      child: _ChallengeFact(
                        icon: Icons.quiz_rounded,
                        value: '${DailyChallengeGenerator.questionCount}',
                        label: 'Questions'.tr,
                        color: AppColors.skyColor,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Expanded(
                      child: _ChallengeFact(
                        icon: Icons.add_alarm_rounded,
                        value: '+3s',
                        label: 'Wrong answer'.tr,
                        color: AppColors.coralColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                _DailyPrimaryButton(
                  label: 'Start challenge'.tr,
                  icon: Icons.play_arrow_rounded,
                  onTap: controller.start,
                ),
              ],
            ),
          ),
          SizedBox(height: Dimensions.height15),
          _ReminderCard(controller: controller),
        ],
      ),
    );
  }
}

class _DailyChallengeGame extends StatelessWidget {
  final DailyChallengeController controller;
  final Future<void> Function(CountryModel) onAnswer;

  const _DailyChallengeGame({
    required this.controller,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final question = controller.currentQuestion;
    if (question == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleColor),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width15,
        Dimensions.height10,
        Dimensions.width15,
        Dimensions.height15,
      ),
      child: Column(
        children: [
          _ChallengeStatusStrip(controller: controller),
          SizedBox(height: Dimensions.height10),
          _ChallengeProgressRail(controller: controller),
          SizedBox(height: Dimensions.height10),
          Expanded(
            flex: 5,
            child: TrainingPromptCard(
              accentColor: AppColors.purpleColor,
              child: Column(
                children: [
                  _QuestionTypeLabel(type: question.type),
                  SizedBox(height: Dimensions.height10 * 0.5),
                  Expanded(
                    child: Image.asset(
                      question.type.assetPath(
                        question.country.countryCode!,
                      ),
                      fit: BoxFit.contain,
                      cacheWidth: imageDecodeWidth(
                        logicalWidth:
                            Dimensions.screenWidth - Dimensions.width20 * 4,
                        devicePixelRatio:
                            MediaQuery.devicePixelRatioOf(context),
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.height10 * 0.5),
                  Text(
                    'Identify the country'.tr,
                    style: TextStyle(
                      color: AppColors.textColorGray,
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                for (var index = 0;
                    index < question.options.length;
                    index++) ...[
                  Expanded(
                    child: Center(
                      child: TrainingTextAnswerCard(
                        text: question.options[index].countryName!,
                        accentColor: AppColors.purpleColor,
                        state: _answerState(
                          controller,
                          question.options[index],
                        ),
                        onTap: () {
                          unawaited(onAnswer(question.options[index]));
                        },
                      ),
                    ),
                  ),
                  if (index < question.options.length - 1)
                    SizedBox(height: Dimensions.height10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  TrainingAnswerState _answerState(
    DailyChallengeController controller,
    CountryModel option,
  ) {
    final code = option.countryCode;
    if (code == controller.correctCountryCode) {
      return TrainingAnswerState.correct;
    }
    if (code != null && controller.currentWrongCountryCodes.contains(code)) {
      return TrainingAnswerState.wrong;
    }
    if (controller.isTransitioning) {
      return TrainingAnswerState.disabled;
    }
    return TrainingAnswerState.idle;
  }
}

class _DailyChallengeResults extends StatelessWidget {
  final DailyChallengeController controller;

  const _DailyChallengeResults({required this.controller});

  @override
  Widget build(BuildContext context) {
    final gameServices = Get.find<GameServicesController>();
    final rawTime = controller.progress.rawElapsedMilliseconds ?? 0;
    final score = controller.completedScoreMilliseconds ?? rawTime;
    final penalty = score - rawTime;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height10,
        Dimensions.width20,
        Dimensions.height30,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Dimensions.width20),
            decoration: _cardDecoration(
              accentColor: AppColors.goldColor,
              accentOpacity: 0.3,
            ),
            child: Column(
              children: [
                _ChallengeEmblem(
                  progress: DailyChallengeGenerator.questionCount,
                  centerIcon: Icons.emoji_events_rounded,
                  accentColor: AppColors.goldColor,
                ),
                SizedBox(height: Dimensions.height15),
                Text(
                  'Challenge complete'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  _formatChallengeTime(score),
                  style: TextStyle(
                    color: AppColors.purpleColor,
                    fontSize: Dimensions.font26 * 1.65,
                    fontWeight: FontWeight.w900,
                    letterSpacing: Dimensions.width5 * 0.2,
                    height: 1,
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Row(
                  children: [
                    Expanded(
                      child: _ResultStat(
                        label: 'Raw time'.tr,
                        value: _formatChallengeTime(rawTime),
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Expanded(
                      child: _ResultStat(
                        label: 'Penalty'.tr,
                        value: '+${_formatChallengeTime(penalty)}',
                        color: penalty > 0
                            ? AppColors.coralColor
                            : AppColors.correctColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  '${controller.wrongAnswers} ${'wrong answers'.tr}',
                  style: TextStyle(
                    color: AppColors.textColorGray,
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (gameServices.hasDailyChallengeLeaderboard) ...[
                  SizedBox(height: Dimensions.height20),
                  _DailyPrimaryButton(
                    label: 'View leaderboard'.tr,
                    icon: Icons.leaderboard_rounded,
                    onTap: () async {
                      await controller.resubmitCompletedScore();
                      if (!context.mounted) return;
                      await _showDailyLeaderboard(
                        context: context,
                        gameServices: gameServices,
                        score: score,
                      );
                    },
                  ),
                ],
                SizedBox(height: Dimensions.height10),
                _DailyOutlineButton(
                  label: 'Invite friends'.tr,
                  icon: Icons.person_add_alt_1_rounded,
                  onTap: () => _shareDailyChallenge(context, score),
                ),
              ],
            ),
          ),
          SizedBox(height: Dimensions.height15),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height15,
            ),
            decoration: _cardDecoration(
              accentColor: AppColors.skyColor,
              accentOpacity: 0.18,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: AppColors.skyColor,
                  size: Dimensions.iconSize24,
                ),
                SizedBox(width: Dimensions.width10),
                Expanded(
                  child: Text(
                    '${'Next challenge'.tr} '
                    '${_formatClockTime(controller.day.endsAtUtc.toLocal())}',
                    style: TextStyle(
                      color: AppColors.mainBlackColor,
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Dimensions.height15),
          _ReminderCard(controller: controller),
        ],
      ),
    );
  }
}

class _ChallengeStatusStrip extends StatelessWidget {
  final DailyChallengeController controller;

  const _ChallengeStatusStrip({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height20 * 2.7,
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
      decoration: _cardDecoration(
        accentColor: AppColors.purpleColor,
        accentOpacity: 0.16,
      ),
      child: Row(
        children: [
          _StatusValue(
            icon: Icons.timer_outlined,
            label: 'Time'.tr,
            value: _formatChallengeTime(
              controller.liveScoreMilliseconds,
            ),
            color: AppColors.purpleColor,
          ),
          Container(
            width: Dimensions.width5 * 0.2,
            height: Dimensions.height30,
            color: AppColors.purpleColor.withValues(alpha: 0.14),
          ),
          _StatusValue(
            icon: Icons.flag_rounded,
            label: 'Question'.tr,
            value:
                '${controller.currentQuestionNumber}/${DailyChallengeGenerator.questionCount}',
            color: AppColors.skyColor,
          ),
        ],
      ),
    );
  }
}

class _StatusValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusValue({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: Dimensions.iconSize16 * 1.25,
          ),
          SizedBox(width: Dimensions.width10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textColorGray,
                  fontSize: Dimensions.font16 * 0.7,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.mainBlackColor,
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeProgressRail extends StatelessWidget {
  final DailyChallengeController controller;

  const _ChallengeProgressRail({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(DailyChallengeGenerator.questionCount, (index) {
        final completed = index < controller.progress.currentQuestionIndex;
        final current = index == controller.progress.currentQuestionIndex;
        final color = completed
            ? AppColors.correctColor
            : current
                ? AppColors.purpleColor
                : AppColors.textColorGray.withValues(alpha: 0.2);
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: current
                ? Dimensions.height10 * 0.7
                : Dimensions.height10 * 0.45,
            margin: EdgeInsets.symmetric(horizontal: Dimensions.width5 * 0.25),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Dimensions.radius10),
            ),
          ),
        );
      }),
    );
  }
}

class _QuestionTypeLabel extends StatelessWidget {
  final DailyChallengeQuestionType type;

  const _QuestionTypeLabel({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width10,
        vertical: Dimensions.height10 * 0.5,
      ),
      decoration: BoxDecoration(
        color: AppColors.purpleColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
      ),
      child: Text(
        type.translationKey.tr.toUpperCase(),
        style: TextStyle(
          color: AppColors.purpleColor,
          fontSize: Dimensions.font16 * 0.72,
          fontWeight: FontWeight.w900,
          letterSpacing: Dimensions.width5 * 0.12,
        ),
      ),
    );
  }
}

class _ChallengeEmblem extends StatelessWidget {
  final int progress;
  final IconData centerIcon;
  final Color accentColor;

  const _ChallengeEmblem({
    required this.progress,
    required this.centerIcon,
    this.accentColor = AppColors.purpleColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.height45 * 3,
      height: Dimensions.height45 * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: Dimensions.height45 * 2.15,
            height: Dimensions.height45 * 2.15,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.2),
                width: Dimensions.width5 * 0.3,
              ),
            ),
            child: Icon(
              centerIcon,
              color: accentColor,
              size: Dimensions.iconSize24 * 2,
            ),
          ),
          for (var index = 0;
              index < DailyChallengeGenerator.questionCount;
              index++)
            Align(
              alignment: _orbitAlignment(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: Dimensions.width10 * 1.15,
                height: Dimensions.width10 * 1.15,
                decoration: BoxDecoration(
                  color: index < progress
                      ? AppColors.correctColor
                      : _orbitColors[index % _orbitColors.length],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: Dimensions.width5 * 0.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainBlackColor.withValues(alpha: 0.1),
                      blurRadius: Dimensions.radius10 * 0.5,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Alignment _orbitAlignment(int index) {
    const alignments = [
      Alignment(0, -1),
      Alignment(0.59, -0.81),
      Alignment(0.95, -0.31),
      Alignment(0.95, 0.31),
      Alignment(0.59, 0.81),
      Alignment(0, 1),
      Alignment(-0.59, 0.81),
      Alignment(-0.95, 0.31),
      Alignment(-0.95, -0.31),
      Alignment(-0.59, -0.81),
    ];
    return alignments[index];
  }

  static const List<Color> _orbitColors = [
    AppColors.coralColor,
    AppColors.goldColor,
    AppColors.skyColor,
    AppColors.purpleColor,
  ];
}

class _ChallengeFact extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ChallengeFact({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: Dimensions.iconSize16 * 1.25,
          ),
          SizedBox(width: Dimensions.width10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.mainBlackColor,
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                AutoSizeText(
                  label,
                  maxLines: 2,
                  minFontSize: Dimensions.font16 * 0.5,
                  stepGranularity: Dimensions.font16 / 16,
                  style: TextStyle(
                    color: AppColors.textColorGray,
                    fontSize: Dimensions.font16 * 0.75,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    this.color = AppColors.mainBlackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textColorGray,
              fontSize: Dimensions.font16 * 0.74,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Dimensions.height10 * 0.5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: Dimensions.font20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final DailyChallengeController controller;

  const _ReminderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _updateReminder(
          controller,
          !controller.reminderEnabled,
          context,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        child: Ink(
          padding: EdgeInsets.all(Dimensions.width15),
          decoration: _cardDecoration(
            accentColor: AppColors.goldColor,
            accentOpacity: 0.18,
          ),
          child: Row(
            children: [
              Container(
                width: Dimensions.height45,
                height: Dimensions.height45,
                decoration: BoxDecoration(
                  color: AppColors.goldColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.goldColor,
                  size: Dimensions.iconSize24,
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily reminder'.tr,
                      style: TextStyle(
                        color: AppColors.mainBlackColor,
                        fontSize: Dimensions.font16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 * 0.25),
                    Text(
                      'Every day at 7 PM'.tr,
                      style: TextStyle(
                        color: AppColors.textColorGray,
                        fontSize: Dimensions.font16 * 0.78,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: controller.reminderEnabled,
                activeTrackColor: AppColors.goldColor,
                onChanged: (enabled) => _updateReminder(
                  controller,
                  enabled,
                  context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _updateReminder(
  DailyChallengeController controller,
  bool enabled,
  BuildContext context,
) async {
  final updated = await controller.setReminderEnabled(enabled);
  if (!context.mounted || !enabled || updated) return;

  Get.snackbar(
    'Notifications are off'.tr,
    'Enable notifications in system settings to get the daily reminder.'.tr,
    snackPosition: SnackPosition.BOTTOM,
  );
}

class _DailyPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final FutureOr<void> Function() onTap;

  const _DailyPrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.height20 * 2.8,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.purpleColor,
                  AppColors.skyColor.withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(Dimensions.radius20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleColor.withValues(alpha: 0.23),
                  blurRadius: Dimensions.radius15,
                  offset: Offset(0, Dimensions.height10 * 0.5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: Dimensions.iconSize24),
                SizedBox(width: Dimensions.width10),
                Flexible(
                  child: AutoSizeText(
                    label,
                    maxLines: 1,
                    minFontSize: Dimensions.font16 * 0.5,
                    stepGranularity: Dimensions.font16 / 16,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.font20,
                      fontWeight: FontWeight.w900,
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
}

class _DailyOutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final FutureOr<void> Function() onTap;

  const _DailyOutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.height20 * 2.6,
      child: OutlinedButton.icon(
        onPressed: () => onTap(),
        icon: Icon(icon, size: Dimensions.iconSize24),
        label: AutoSizeText(
          label,
          maxLines: 1,
          minFontSize: Dimensions.font16 * 0.5,
          stepGranularity: Dimensions.font16 / 16,
          style: TextStyle(
            fontSize: Dimensions.font16,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purpleColor,
          side: BorderSide(
            color: AppColors.purpleColor.withValues(alpha: 0.35),
            width: Dimensions.width5 * 0.25,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius20),
          ),
        ),
      ),
    );
  }
}

class _DailyLeaderboardSheet extends StatelessWidget {
  final Future<List<GameLeaderboardScore>?> scores;
  final GameServicesController gameServices;
  final int score;

  const _DailyLeaderboardSheet({
    required this.scores,
    required this.gameServices,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.82,
      child: DecoratedBox(
        key: const ValueKey('daily-leaderboard-sheet-background'),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBFA),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.radius30),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height10,
              Dimensions.width20,
              Dimensions.height20,
            ),
            child: Column(
              children: [
                Container(
                  width: Dimensions.width30 * 1.5,
                  height: Dimensions.height10 * 0.5,
                  decoration: BoxDecoration(
                    color: AppColors.textColorGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                  ),
                ),
                SizedBox(height: Dimensions.height15),
                Row(
                  children: [
                    Container(
                      width: Dimensions.height45,
                      height: Dimensions.height45,
                      decoration: BoxDecoration(
                        color: AppColors.purpleColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius15),
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: AppColors.purpleColor,
                        size: Dimensions.iconSize24,
                      ),
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Friends today'.tr,
                            style: TextStyle(
                              color: AppColors.mainBlackColor,
                              fontSize: Dimensions.font20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Daily challenge leaderboard'.tr,
                            style: TextStyle(
                              color: AppColors.textColorGray,
                              fontSize: Dimensions.font16 * 0.78,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height15),
                Expanded(
                  child: FutureBuilder<List<GameLeaderboardScore>?>(
                    future: scores,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.purpleColor,
                          ),
                        );
                      }
                      if (snapshot.data == null) {
                        return _LeaderboardMessage(
                          icon: Icons.cloud_off_rounded,
                          title: 'Could not load leaderboard'.tr,
                          message: 'Try again in Game Center or Play Games.'.tr,
                        );
                      }
                      final entries = snapshot.data!;
                      if (entries.isEmpty) {
                        return _LeaderboardMessage(
                          icon: Icons.person_add_alt_1_rounded,
                          title: 'No friends on the leaderboard yet'.tr,
                          message: 'Invite friends to compare daily times.'.tr,
                        );
                      }
                      return ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: Dimensions.height10),
                        itemBuilder: (context, index) =>
                            _LeaderboardEntry(score: entries[index]),
                      );
                    },
                  ),
                ),
                SizedBox(height: Dimensions.height15),
                _DailyPrimaryButton(
                  label: 'Open global leaderboard'.tr,
                  icon: Icons.public_rounded,
                  onTap: gameServices.showDailyChallengeLeaderboard,
                ),
                SizedBox(height: Dimensions.height10),
                _DailyOutlineButton(
                  label: 'Invite friends'.tr,
                  icon: Icons.person_add_alt_1_rounded,
                  onTap: () => _shareDailyChallenge(context, score),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final GameLeaderboardScore score;

  const _LeaderboardEntry({required this.score});

  @override
  Widget build(BuildContext context) {
    final avatar = _decodeAvatar(score.playerAvatarBase64);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width15,
        vertical: Dimensions.height10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(
          color: AppColors.purpleColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: Dimensions.width30,
            child: Text(
              '#${score.rank}',
              style: TextStyle(
                color: AppColors.purpleColor,
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: Dimensions.width10),
          CircleAvatar(
            radius: Dimensions.iconSize24,
            backgroundColor: AppColors.skyColor.withValues(alpha: 0.15),
            foregroundImage: avatar == null ? null : MemoryImage(avatar),
            child: avatar == null
                ? Icon(
                    Icons.person_rounded,
                    color: AppColors.skyColor,
                    size: Dimensions.iconSize24,
                  )
                : null,
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Text(
              score.playerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.mainBlackColor,
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Text(
            _formatChallengeTime(score.rawScore),
            style: TextStyle(
              color: AppColors.purpleColor,
              fontSize: Dimensions.font16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _LeaderboardMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.purpleColor,
              size: Dimensions.iconSize24 * 2,
            ),
            SizedBox(height: Dimensions.height15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mainBlackColor,
                fontSize: Dimensions.font20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColorGray,
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration({
  required Color accentColor,
  required double accentOpacity,
}) {
  return BoxDecoration(
    color: const Color(0xFFFCFFFE).withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(Dimensions.radius20),
    border: Border.all(
      color: accentColor.withValues(alpha: accentOpacity),
      width: Dimensions.width5 * 0.2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.mainBlackColor.withValues(alpha: 0.055),
        blurRadius: Dimensions.radius15,
        offset: Offset(0, Dimensions.height10 * 0.45),
      ),
    ],
  );
}

String _formatChallengeTime(int milliseconds) {
  final safeMilliseconds = milliseconds < 0 ? 0 : milliseconds;
  final minutes = safeMilliseconds ~/ Duration.millisecondsPerMinute;
  final seconds = (safeMilliseconds ~/ Duration.millisecondsPerSecond) % 60;
  final centiseconds = (safeMilliseconds % 1000) ~/ 10;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}.'
      '${centiseconds.toString().padLeft(2, '0')}';
}

String _formatClockTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

Future<void> _showDailyLeaderboard({
  required BuildContext context,
  required GameServicesController gameServices,
  required int score,
}) async {
  final scores = gameServices.loadDailyChallengeFriendScores();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DailyLeaderboardSheet(
      scores: scores,
      gameServices: gameServices,
      score: score,
    ),
  );
}

Future<void> _shareDailyChallenge(BuildContext context, int score) async {
  const downloadUrl = 'https://hartvigsolutions.com/#flags-game/download';
  final renderBox = context.findRenderObject();
  final shareOrigin = renderBox is RenderBox
      ? renderBox.localToGlobal(Offset.zero) & renderBox.size
      : null;
  await SharePlus.instance.share(
    ShareParams(
      subject: 'Daily challenge'.tr,
      text: 'Daily challenge invite'.trParams({
        'time': _formatChallengeTime(score),
        'url': downloadUrl,
      }),
      sharePositionOrigin: shareOrigin,
    ),
  );
}

Uint8List? _decodeAvatar(String? encodedAvatar) {
  if (encodedAvatar == null || encodedAvatar.isEmpty) return null;
  try {
    return base64Decode(encodedAvatar);
  } on FormatException {
    return null;
  }
}
