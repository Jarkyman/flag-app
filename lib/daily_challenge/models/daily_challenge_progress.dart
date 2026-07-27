enum DailyChallengeStatus { ready, active, completed }

class DailyChallengeProgress {
  final String dayKey;
  final DailyChallengeStatus status;
  final DateTime? startedAtUtc;
  final DateTime? completedAtUtc;
  final int currentQuestionIndex;
  final int wrongAnswers;
  final Set<String> currentWrongCountryCodes;
  final int? rawElapsedMilliseconds;
  final int? scoreMilliseconds;

  const DailyChallengeProgress({
    required this.dayKey,
    required this.status,
    this.startedAtUtc,
    this.completedAtUtc,
    this.currentQuestionIndex = 0,
    this.wrongAnswers = 0,
    this.currentWrongCountryCodes = const {},
    this.rawElapsedMilliseconds,
    this.scoreMilliseconds,
  });

  factory DailyChallengeProgress.ready(String dayKey) {
    return DailyChallengeProgress(
      dayKey: dayKey,
      status: DailyChallengeStatus.ready,
    );
  }

  factory DailyChallengeProgress.fromJson(Map<String, dynamic> json) {
    return DailyChallengeProgress(
      dayKey: json['dayKey'] as String,
      status: DailyChallengeStatus.values.firstWhere(
        (value) => value.name == json['status'],
      ),
      startedAtUtc: _dateTimeFromJson(json['startedAtUtc']),
      completedAtUtc: _dateTimeFromJson(json['completedAtUtc']),
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      wrongAnswers: json['wrongAnswers'] as int? ?? 0,
      currentWrongCountryCodes:
          (json['currentWrongCountryCodes'] as List<dynamic>? ?? const [])
              .cast<String>()
              .toSet(),
      rawElapsedMilliseconds: json['rawElapsedMilliseconds'] as int?,
      scoreMilliseconds: json['scoreMilliseconds'] as int?,
    );
  }

  DailyChallengeProgress copyWith({
    DailyChallengeStatus? status,
    DateTime? startedAtUtc,
    DateTime? completedAtUtc,
    int? currentQuestionIndex,
    int? wrongAnswers,
    Set<String>? currentWrongCountryCodes,
    int? rawElapsedMilliseconds,
    int? scoreMilliseconds,
  }) {
    return DailyChallengeProgress(
      dayKey: dayKey,
      status: status ?? this.status,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      currentWrongCountryCodes:
          currentWrongCountryCodes ?? this.currentWrongCountryCodes,
      rawElapsedMilliseconds:
          rawElapsedMilliseconds ?? this.rawElapsedMilliseconds,
      scoreMilliseconds: scoreMilliseconds ?? this.scoreMilliseconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayKey': dayKey,
      'status': status.name,
      'startedAtUtc': startedAtUtc?.toIso8601String(),
      'completedAtUtc': completedAtUtc?.toIso8601String(),
      'currentQuestionIndex': currentQuestionIndex,
      'wrongAnswers': wrongAnswers,
      'currentWrongCountryCodes':
          currentWrongCountryCodes.toList(growable: false)..sort(),
      'rawElapsedMilliseconds': rawElapsedMilliseconds,
      'scoreMilliseconds': scoreMilliseconds,
    };
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value)?.toUtc();
  }
}
