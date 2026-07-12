import 'dart:convert';

import 'package:flutter/services.dart';

import 'game_achievement_definition.dart';
import 'game_leaderboard_definition.dart';

class GameServicesCatalog {
  final List<GameAchievementDefinition> achievements;
  final List<GameLeaderboardDefinition> leaderboards;

  const GameServicesCatalog({
    required this.achievements,
    required this.leaderboards,
  });

  static Future<GameServicesCatalog> load() async {
    final achievementJson = jsonDecode(
      await rootBundle.loadString(
        'game_services/achievements/catalog.json',
      ),
    ) as Map<String, dynamic>;
    final leaderboardJson = jsonDecode(
      await rootBundle.loadString(
        'game_services/leaderboards/catalog.json',
      ),
    ) as Map<String, dynamic>;
    return GameServicesCatalog.fromJson(
      achievementJson: achievementJson,
      leaderboardJson: leaderboardJson,
    );
  }

  factory GameServicesCatalog.fromJson({
    required Map<String, dynamic> achievementJson,
    required Map<String, dynamic> leaderboardJson,
  }) {
    return GameServicesCatalog(
      achievements: (achievementJson['achievements'] as List<dynamic>)
          .map(
            (item) => GameAchievementDefinition.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      leaderboards: (leaderboardJson['leaderboards'] as List<dynamic>)
          .map(
            (item) => GameLeaderboardDefinition.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
    );
  }
}
