class RemoteAchievementProgress {
  final String id;
  final int completedSteps;
  final int totalSteps;
  final bool unlocked;

  const RemoteAchievementProgress({
    required this.id,
    required this.completedSteps,
    required this.totalSteps,
    required this.unlocked,
  });
}
