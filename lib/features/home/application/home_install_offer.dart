import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/platform/install/install_providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

/// True once the learner has finished at least one lesson. The reader bumps
/// the roadmap revision when it marks a lesson read, so this follows it.
final homeFirstLessonFinishedProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  ref.watch(roadmapRevisionProvider);
  return ref.watch(lessonProgressRepositoryProvider).hasAnyRead();
});

/// The install offer Home shows: nothing at first open, then the browser's
/// install path after the first finished lesson. It is never offered on
/// native builds, when Pantas is installed, when the browser has no install
/// path, or while the learner's "Not Now" still hides it.
final homeInstallOfferProvider = Provider.autoDispose<InstallPath>((ref) {
  // Ask the browser first: native builds and browsers with no install path
  // never reach the lesson query.
  final path = ref.watch(installControllerProvider);
  if (path == InstallPath.none) return path;
  final finished = ref.watch(homeFirstLessonFinishedProvider).valueOrNull;
  return (finished ?? false) ? path : InstallPath.none;
});
