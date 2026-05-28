import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/wrapped/data/user_metrics_artifact_repository.dart';
import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_payload.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists and reads wrapped payload json', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserMetricsArtifactRepository(db);
    final firedAt = DateTime.utc(2026, 6, 10);

    await repo.upsert(
      UserMetricsArtifactEntry(
        userId: 'user_1',
        examId: 'exam_cse',
        artifactId: 'post_mock_recap',
        payload: const WrappedPayload(
          title: 'Mock 1 - Personal Best',
          slides: [WrappedSlide(title: 'Score', body: '80%')],
          archetypeId: 'game_day_player',
          shareId: 'share_1',
        ),
        firedAt: firedAt,
      ),
    );

    final loaded = await repo.byArtifactId(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'post_mock_recap',
    );

    expect(loaded?.payload.title, 'Mock 1 - Personal Best');
    expect(loaded?.payload.slides.single.body, '80%');
  });
}
