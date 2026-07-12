class GameAchievementDefinition {
  final String key;
  final String appleId;
  final String? googleId;
  final String type;
  final int steps;
  final int points;
  final bool hidden;

  const GameAchievementDefinition({
    required this.key,
    required this.appleId,
    required this.googleId,
    required this.type,
    required this.steps,
    required this.points,
    required this.hidden,
  });

  bool get isIncremental => type == 'incremental';

  factory GameAchievementDefinition.fromJson(Map<String, dynamic> json) {
    return GameAchievementDefinition(
      key: json['key'] as String,
      appleId: json['appleId'] as String,
      googleId: json['googleId'] as String?,
      type: json['type'] as String,
      steps: json['steps'] as int,
      points: json['points'] as int,
      hidden: json['hidden'] as bool,
    );
  }
}
