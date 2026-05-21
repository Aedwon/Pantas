class SanityConfig {
  const SanityConfig({
    required this.projectId,
    required this.dataset,
  });

  factory SanityConfig.fromEnvironment() {
    const projectId = String.fromEnvironment('SANITY_PROJECT_ID');
    const dataset = String.fromEnvironment('SANITY_DATASET');
    final config = SanityConfig.fromValues(
      projectId: projectId,
      dataset: dataset,
    );
    if (config == null) {
      throw StateError('Missing SANITY_PROJECT_ID or SANITY_DATASET');
    }
    return config;
  }

  static SanityConfig? fromValues({
    required String projectId,
    required String dataset,
  }) {
    if (projectId.trim().isEmpty || dataset.trim().isEmpty) return null;
    return SanityConfig(projectId: projectId, dataset: dataset);
  }

  final String projectId;
  final String dataset;
}
