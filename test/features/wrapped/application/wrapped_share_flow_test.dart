import 'package:cse_cet_reviewer/features/wrapped/application/wrapped_share_flow.dart';
import 'package:cse_cet_reviewer/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('renders PNG and records local shared timestamp', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repository = UserMetricsArtifactRepository(db);
    final entry = UserMetricsArtifactEntry(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'artifact_1',
      payload: const WrappedPayload(
        title: 'Day 7 Streak',
        slides: [WrappedSlide(title: 'Streak', body: 'Seven days in a row.')],
        archetypeId: 'steady_builder',
        shareId: 'share_1',
      ),
      firedAt: DateTime(2026, 6, 10),
    );
    await repository.upsert(entry);

    final result = await WrappedShareFlow(
      repository: repository,
      now: () => DateTime(2026, 6, 11),
    ).renderAndMarkShared(entry: entry, includeArchetype: false);
    final stored = await repository.byArtifactId(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'artifact_1',
    );

    expect(result.pngBytes.length, greaterThan(1000));
    expect(stored!.sharedAt, DateTime(2026, 6, 11));
    expect(stored.sharePlatform, 'local_png');
  });
}
