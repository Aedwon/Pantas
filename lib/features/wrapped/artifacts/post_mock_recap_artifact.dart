class PostMockRecapArtifact {
  const PostMockRecapArtifact();

  String get id => 'post_mock_recap';

  bool shouldFire({
    required double scorePercent,
    required double? previousBestPercent,
  }) {
    return previousBestPercent == null || scorePercent > previousBestPercent;
  }
}
