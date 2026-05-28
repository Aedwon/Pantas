import 'package:cse_cet_reviewer/features/wrapped/application/wrapped_share_flow.dart';
import 'package:cse_cet_reviewer/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../fake_wrapped_share_host.dart';

void main() {
  test('renders, publishes to the host, and records the hosted shareId',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repository = UserMetricsArtifactRepository(db);
    final host = FakeWrappedShareHost();
    final entry = UserMetricsArtifactEntry(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'artifact_1',
      payload: const WrappedPayload(
        title: 'Day 7 Streak',
        slides: [WrappedSlide(title: 'Streak', body: 'Seven days in a row.')],
        archetypeId: 'steady_builder',
        shareId: 'placeholder',
      ),
      firedAt: DateTime(2026, 6, 10),
    );
    await repository.upsert(entry);

    final result = await WrappedShareFlow(
      repository: repository,
      host: host,
      now: () => DateTime(2026, 6, 11),
    ).renderAndMarkShared(entry: entry, includeArchetype: false);

    final stored = await repository.byArtifactId(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'artifact_1',
    );

    expect(result.pngBytes.length, greaterThan(1000));
    expect(result.shareId, hasLength(32));
    expect(host.published, hasLength(1));
    expect(host.published.single.shareId, result.shareId);
    expect(host.published.single.uid, 'user_1');
    expect(host.published.single.archetypeId, 'steady_builder');
    expect(stored!.sharedAt, DateTime(2026, 6, 11));
    expect(stored.sharePlatform, 'local_png');
  });
}
