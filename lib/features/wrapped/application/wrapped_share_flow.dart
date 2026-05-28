import 'dart:typed_data';

import 'package:cse_cet_reviewer/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:cse_cet_reviewer/features/wrapped/rendering/wrapped_png_renderer.dart';

class WrappedShareResult {
  const WrappedShareResult({required this.pngBytes});

  final Uint8List pngBytes;
}

class WrappedShareFlow {
  const WrappedShareFlow({
    required UserMetricsArtifactRepository repository,
    WrappedPngRenderer renderer = const WrappedPngRenderer(),
    DateTime Function()? now,
  })  : _repository = repository,
        _renderer = renderer,
        _now = now;

  final UserMetricsArtifactRepository _repository;
  final WrappedPngRenderer _renderer;
  final DateTime Function()? _now;

  Future<WrappedShareResult> renderAndMarkShared({
    required UserMetricsArtifactEntry entry,
    required bool includeArchetype,
    String sharePlatform = 'local_png',
  }) async {
    final bytes = await _renderer.render(
      payload: entry.payload,
      includeArchetype: includeArchetype,
    );
    await _repository.markShared(
      userId: entry.userId,
      examId: entry.examId,
      artifactId: entry.artifactId,
      sharedAt: (_now ?? DateTime.now)(),
      sharePlatform: sharePlatform,
    );
    return WrappedShareResult(pngBytes: bytes);
  }
}
