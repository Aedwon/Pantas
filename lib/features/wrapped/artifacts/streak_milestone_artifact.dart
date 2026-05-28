class StreakMilestoneArtifact {
  const StreakMilestoneArtifact();

  static const thresholds = {7, 30, 100, 365};

  bool shouldFire(int currentStreakDays) {
    return thresholds.contains(currentStreakDays);
  }
}
