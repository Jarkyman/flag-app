import '../../models/training_continent.dart';

class GameLeaderboardDefinition {
  final String key;
  final String appleId;
  final String? googleId;
  final TrainingScoreGame game;

  const GameLeaderboardDefinition({
    required this.key,
    required this.appleId,
    required this.googleId,
    required this.game,
  });

  factory GameLeaderboardDefinition.fromJson(Map<String, dynamic> json) {
    return GameLeaderboardDefinition(
      key: json['key'] as String,
      appleId: json['appleId'] as String,
      googleId: json['googleId'] as String?,
      game: switch (json['game'] as String) {
        'find_flag' => TrainingScoreGame.findFlag,
        'match_flags' => TrainingScoreGame.matchFlags,
        'which_country' => TrainingScoreGame.whichCountry,
        final value => throw FormatException('Unknown training game: $value'),
      },
    );
  }
}
