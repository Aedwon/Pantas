class MasteryCrossingArtifact {
  const MasteryCrossingArtifact();

  static const weakToStrongStabilityDays = 14.0;

  bool shouldFire({
    required double previousStability,
    required double nextStability,
  }) {
    return previousStability < weakToStrongStabilityDays &&
        nextStability >= weakToStrongStabilityDays;
  }
}
