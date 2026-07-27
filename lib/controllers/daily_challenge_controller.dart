import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../daily_challenge/daily_challenge_generator.dart';
import '../daily_challenge/daily_challenge_reminder.dart';
import '../daily_challenge/daily_challenge_repository.dart';
import '../daily_challenge/models/daily_challenge_day.dart';
import '../daily_challenge/models/daily_challenge_progress.dart';
import '../daily_challenge/models/daily_challenge_question.dart';
import '../models/country_model.dart';
import 'analytics_controller.dart';

typedef DailyChallengeScoreSubmitter = Future<void> Function({
  required int scoreMilliseconds,
  required String dayKey,
});

class DailyChallengeController extends GetxController implements GetxService {
  static const int wrongAnswerPenaltyMilliseconds = 3000;
  final DailyChallengeRepository repository;
  final DailyChallengeReminder reminder;
  final DailyChallengeGenerator generator;
  final List<CountryModel> Function() countriesProvider;
  final DailyChallengeScoreSubmitter submitScore;
  final AnalyticsController? analytics;
  final DateTime Function() now;
  final void Function()? playCorrectSound;
  final void Function()? playWrongSound;
  final Duration answerTransitionDuration;

  DailyChallengeController({
    required this.repository,
    required this.reminder,
    required this.countriesProvider,
    required this.submitScore,
    this.generator = const DailyChallengeGenerator(),
    this.analytics,
    DateTime Function()? now,
    this.playCorrectSound,
    this.playWrongSound,
    this.answerTransitionDuration = const Duration(milliseconds: 420),
  }) : now = now ?? DateTime.now;

  late DailyChallengeDay _day;
  late DailyChallengeProgress _progress;
  List<DailyChallengeQuestion> _questions = const [];
  Timer? _ticker;
  bool _initialized = false;
  bool _isTransitioning = false;
  String? _correctCountryCode;

  DailyChallengeDay get day => _day;
  DailyChallengeProgress get progress => _progress;
  List<DailyChallengeQuestion> get questions => _questions;
  bool get isInitialized => _initialized;
  bool get isTransitioning => _isTransitioning;
  String? get correctCountryCode => _correctCountryCode;
  bool get reminderEnabled => repository.reminderEnabled;
  DailyChallengeStatus get status => _progress.status;
  int get wrongAnswers => _progress.wrongAnswers;

  DailyChallengeQuestion? get currentQuestion {
    if (_questions.isEmpty ||
        _progress.currentQuestionIndex < 0 ||
        _progress.currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_progress.currentQuestionIndex];
  }

  int get currentQuestionNumber {
    if (_progress.status == DailyChallengeStatus.completed) {
      return _questions.length;
    }
    return _progress.currentQuestionIndex + 1;
  }

  Set<String> get currentWrongCountryCodes =>
      _progress.currentWrongCountryCodes;

  int get rawElapsedMilliseconds {
    final saved = _progress.rawElapsedMilliseconds;
    if (_progress.status == DailyChallengeStatus.completed && saved != null) {
      return saved;
    }
    final startedAt = _progress.startedAtUtc;
    if (startedAt == null) return 0;
    final elapsed = now().toUtc().difference(startedAt).inMilliseconds;
    return elapsed < 0 ? 0 : elapsed;
  }

  int get liveScoreMilliseconds {
    return rawElapsedMilliseconds +
        wrongAnswers * wrongAnswerPenaltyMilliseconds;
  }

  int? get completedScoreMilliseconds => _progress.scoreMilliseconds;

  Duration get timeUntilNextChallenge => _day.remainingAt(now());

  Future<void> initialize() async {
    final currentDay = DailyChallengeDay.fromInstant(now());
    if (_initialized && currentDay == _day) {
      if (_progress.status == DailyChallengeStatus.active) {
        _startTicker();
      }
      update();
      return;
    }

    _day = currentDay;
    _questions = generator.generate(
      countries: countriesProvider(),
      day: _day,
    );
    _progress = repository.readProgress(_day);
    _correctCountryCode = null;
    _isTransitioning = false;
    _initialized = true;
    try {
      await reminder.initialize();
    } catch (error, stackTrace) {
      debugPrint('Daily challenge reminder initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    if (_progress.status == DailyChallengeStatus.active) {
      _startTicker();
    } else {
      _stopTicker();
    }
    update();
  }

  Future<void> start() async {
    await initialize();
    if (_progress.status != DailyChallengeStatus.ready) return;

    _progress = DailyChallengeProgress(
      dayKey: _day.key,
      status: DailyChallengeStatus.active,
      startedAtUtc: now().toUtc(),
    );
    await repository.saveProgress(_progress);
    _startTicker();
    unawaited(
      analytics?.gameStarted(gameMode: 'daily_challenge') ?? Future.value(),
    );
    update();
  }

  Future<void> answer(CountryModel selectedCountry) async {
    if (_progress.status != DailyChallengeStatus.active || _isTransitioning) {
      return;
    }
    final question = currentQuestion;
    final selectedCode = selectedCountry.countryCode;
    final correctCode = question?.country.countryCode;
    if (question == null || selectedCode == null || correctCode == null) {
      return;
    }

    if (selectedCode != correctCode) {
      if (_progress.currentWrongCountryCodes.contains(selectedCode)) return;
      playWrongSound?.call();
      _progress = _progress.copyWith(
        wrongAnswers: _progress.wrongAnswers + 1,
        currentWrongCountryCodes: {
          ..._progress.currentWrongCountryCodes,
          selectedCode,
        },
      );
      await repository.saveProgress(_progress);
      unawaited(
        analytics?.answerSubmitted(
              gameMode: 'daily_challenge',
              correct: false,
              streak: _progress.currentQuestionIndex,
              usedHint: false,
            ) ??
            Future.value(),
      );
      update();
      return;
    }

    playCorrectSound?.call();
    _correctCountryCode = correctCode;
    _isTransitioning = true;
    update();
    unawaited(
      analytics?.answerSubmitted(
            gameMode: 'daily_challenge',
            correct: true,
            streak: _progress.currentQuestionIndex + 1,
            usedHint: false,
          ) ??
          Future.value(),
    );

    await Future<void>.delayed(answerTransitionDuration);
    if (_progress.currentQuestionIndex >= _questions.length - 1) {
      await _complete();
      return;
    }

    _progress = _progress.copyWith(
      currentQuestionIndex: _progress.currentQuestionIndex + 1,
      currentWrongCountryCodes: const {},
    );
    _correctCountryCode = null;
    _isTransitioning = false;
    await repository.saveProgress(_progress);
    update();
  }

  Future<bool> setReminderEnabled(bool enabled) async {
    try {
      if (!enabled) {
        await reminder.disable();
        await repository.saveReminderEnabled(false);
        update();
        return true;
      }

      final granted = await reminder.enable(
        title: 'Daily challenge'.tr,
        body: 'Ten new countries are waiting for you.'.tr,
      );
      await repository.saveReminderEnabled(granted);
      update();
      return granted;
    } catch (error, stackTrace) {
      debugPrint('Daily challenge reminder update failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      await repository.saveReminderEnabled(false);
      update();
      return false;
    }
  }

  Future<void> resubmitCompletedScore() async {
    final score = _progress.scoreMilliseconds;
    if (_progress.status != DailyChallengeStatus.completed || score == null) {
      return;
    }
    await submitScore(scoreMilliseconds: score, dayKey: _day.key);
  }

  void pauseLiveUpdates() {
    _stopTicker();
  }

  Future<void> _complete() async {
    final completedAt = now().toUtc();
    final startedAt = _progress.startedAtUtc ?? completedAt;
    final rawElapsed = completedAt.difference(startedAt).inMilliseconds;
    final safeRawElapsed = rawElapsed < 0 ? 0 : rawElapsed;
    final scoreWithPenalty = safeRawElapsed +
        _progress.wrongAnswers * wrongAnswerPenaltyMilliseconds;
    final score = ((scoreWithPenalty + 9) ~/ 10) * 10;

    _progress = _progress.copyWith(
      status: DailyChallengeStatus.completed,
      completedAtUtc: completedAt,
      currentQuestionIndex: _questions.length,
      currentWrongCountryCodes: const {},
      rawElapsedMilliseconds: safeRawElapsed,
      scoreMilliseconds: score,
    );
    _correctCountryCode = null;
    _isTransitioning = false;
    _stopTicker();
    await repository.saveProgress(_progress);
    unawaited(
      analytics?.gameFinished(
            gameMode: 'daily_challenge',
            score: score,
            newRecord: false,
            reason: 'completed',
          ) ??
          Future.value(),
    );
    unawaited(
      submitScore(scoreMilliseconds: score, dayKey: _day.key),
    );
    update();
  }

  void _startTicker() {
    if (_ticker?.isActive == true) return;
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_progress.status != DailyChallengeStatus.active) {
        _stopTicker();
        return;
      }
      update();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void onClose() {
    _stopTicker();
    super.onClose();
  }
}
