import 'game_achievement_definition.dart';

class GameAchievementProgress {
  final GameAchievementDefinition definition;
  final int currentSteps;

  const GameAchievementProgress({
    required this.definition,
    required this.currentSteps,
  });

  int get clampedSteps => currentSteps.clamp(0, definition.steps);

  bool get isUnlocked => clampedSteps >= definition.steps;

  double get percentComplete {
    if (definition.steps <= 0) return 0;
    return clampedSteps / definition.steps * 100;
  }
}
