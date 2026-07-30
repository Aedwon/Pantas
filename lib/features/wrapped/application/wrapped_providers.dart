import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/wrapped/data/firebase_wrapped_share_host.dart';
import 'package:pantas/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:pantas/features/wrapped/domain/wrapped_share_host.dart';

final userMetricsArtifactRepositoryProvider =
    Provider<UserMetricsArtifactRepository>((ref) {
  return UserMetricsArtifactRepository(ref.watch(appDatabaseProvider));
});

final wrappedShareHostProvider = Provider<WrappedShareHost>((ref) {
  return FirebaseWrappedShareHost();
});

final wrappedArtifactProvider =
    FutureProvider.family<UserMetricsArtifactEntry?, String>((ref, artifactId) {
  return ref
      .watch(userMetricsArtifactRepositoryProvider)
      .latestByArtifactId(artifactId);
});

/// Cards the user has published to a `pantas.app` link, for the
/// "My shared cards" revoke surface.
final sharedWrappedCardsProvider =
    FutureProvider<List<HostedWrappedCard>>((ref) {
  return ref.watch(userMetricsArtifactRepositoryProvider).listShared();
});
