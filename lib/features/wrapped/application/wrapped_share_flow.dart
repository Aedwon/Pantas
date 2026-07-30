import 'dart:typed_data';

import 'package:pantas/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:pantas/features/wrapped/domain/share_id_generator.dart';
import 'package:pantas/features/wrapped/domain/wrapped_share_host.dart';
import 'package:pantas/features/wrapped/rendering/wrapped_png_renderer.dart';

class WrappedShareResult {
  const WrappedShareResult({required this.pngBytes, required this.shareId});

  final Uint8List pngBytes;
  final String shareId;
}

class WrappedShareFlow {
  WrappedShareFlow({
    required UserMetricsArtifactRepository repository,
    required WrappedShareHost host,
    WrappedPngRenderer renderer = const WrappedPngRenderer(),
    ShareIdGenerator? shareIdGenerator,
    DateTime Function()? now,
  })  : _repository = repository,
        _host = host,
        _renderer = renderer,
        _shareIdGenerator = shareIdGenerator ?? ShareIdGenerator(),
        _now = now;

  final UserMetricsArtifactRepository _repository;
  final WrappedShareHost _host;
  final WrappedPngRenderer _renderer;
  final ShareIdGenerator _shareIdGenerator;
  final DateTime Function()? _now;

  /// Generates a hosted `shareId`, renders the card with the link + QR baked
  /// in, publishes it, and records the local shared state. The order matters:
  /// the PNG must be composed with the final URL before upload so the hosted
  /// image matches what is posted to social (landing-page spec §3.1).
  Future<WrappedShareResult> renderAndMarkShared({
    required UserMetricsArtifactEntry entry,
    required bool includeArchetype,
    String sharePlatform = 'local_png',
  }) async {
    final shareId = _shareIdGenerator.generate();
    final bytes = await _renderer.render(
      payload: entry.payload,
      includeArchetype: includeArchetype,
      shareId: shareId,
    );
    await _host.publish(
      uid: entry.userId,
      shareId: shareId,
      archetypeId: entry.payload.archetypeId,
      pngBytes: bytes,
    );
    await _repository.markShared(
      userId: entry.userId,
      examId: entry.examId,
      artifactId: entry.artifactId,
      sharedAt: (_now ?? DateTime.now)(),
      sharePlatform: sharePlatform,
      shareId: shareId,
    );
    return WrappedShareResult(pngBytes: bytes, shareId: shareId);
  }
}
