class GameLeaderboardScore {
  final int rank;
  final String displayScore;
  final int rawScore;
  final String playerName;
  final String? playerId;
  final String? playerAvatarBase64;

  const GameLeaderboardScore({
    required this.rank,
    required this.displayScore,
    required this.rawScore,
    required this.playerName,
    required this.playerId,
    required this.playerAvatarBase64,
  });
}

enum GameLeaderboardPlayerScope { global, friends }

enum GameLeaderboardTimeScope { today, week, allTime }
