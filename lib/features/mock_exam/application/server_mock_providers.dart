import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/data/server_mock_view_cache.dart';

/// The published mock callables. Tests replace this with a fake callable.
final serverMockApiProvider = Provider<ServerMockApi>(
  (ref) => ServerMockApi.firebase(),
);

final serverMockViewCacheProvider = Provider<ServerMockViewCache>(
  (ref) => ServerMockViewCache(ref.watch(appDatabaseProvider)),
);

/// The signed-in account right now. Read when a change is about to be sent,
/// not when the screen was built, so a change of account is seen.
final serverMockActorProvider = Provider<String? Function()>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return () => auth.currentSession?.uid;
});

/// A monotonic reading for the display clock. Only differences between two
/// readings are used, so it may start at any time. Tests replace it.
final serverMockElapsedProvider = Provider<Duration Function()>((ref) {
  final watch = Stopwatch()..start();
  return () => watch.elapsed;
});
