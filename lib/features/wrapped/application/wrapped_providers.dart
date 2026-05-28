import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userMetricsArtifactRepositoryProvider =
    Provider<UserMetricsArtifactRepository>((ref) {
  return UserMetricsArtifactRepository(ref.watch(appDatabaseProvider));
});

final wrappedArtifactProvider =
    FutureProvider.family<UserMetricsArtifactEntry?, String>((ref, artifactId) {
  return ref
      .watch(userMetricsArtifactRepositoryProvider)
      .latestByArtifactId(artifactId);
});
