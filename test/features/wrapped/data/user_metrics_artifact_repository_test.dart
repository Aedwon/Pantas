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

  test('markShared persists the hosted shareId and lists shared cards',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserMetricsArtifactRepository(db);
    await repo.upsert(
      UserMetricsArtifactEntry(
        userId: 'user_1',
        examId: 'exam_cse',
        artifactId: 'streak_milestone',
        payload: const WrappedPayload(
          title: 'Day 7 Streak',
          slides: [WrappedSlide(title: 'Streak', body: '7 days')],
          archetypeId: 'steady_builder',
          shareId: 'placeholder',
        ),
        firedAt: DateTime.utc(2026, 6, 10),
      ),
    );

    await repo.markShared(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'streak_milestone',
      sharedAt: DateTime.utc(2026, 6, 11),
      sharePlatform: 'local_png',
      shareId: 'hostedshareid0000000000000000abcd',
    );

    final shared = await repo.listShared();
    expect(shared, hasLength(1));
    expect(shared.single.shareId, 'hostedshareid0000000000000000abcd');
    expect(shared.single.archetypeId, 'steady_builder');
    expect(shared.single.title, 'Day 7 Streak');
  });

  test('setLocalRevoked removes the card from the shared list', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = UserMetricsArtifactRepository(db);
    await repo.upsert(
      UserMetricsArtifactEntry(
        userId: 'user_1',
        examId: 'exam_cse',
        artifactId: 'streak_milestone',
        payload: const WrappedPayload(
          title: 'Day 7 Streak',
          slides: [WrappedSlide(title: 'Streak', body: '7 days')],
          archetypeId: 'steady_builder',
          shareId: 'placeholder',
        ),
        firedAt: DateTime.utc(2026, 6, 10),
      ),
    );
    await repo.markShared(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'streak_milestone',
      sharedAt: DateTime.utc(2026, 6, 11),
      sharePlatform: 'local_png',
      shareId: 'hostedshareid0000000000000000abcd',
    );

    await repo.setLocalRevoked(
      userId: 'user_1',
      examId: 'exam_cse',
      artifactId: 'streak_milestone',
    );

    expect(await repo.listShared(), isEmpty);
  });
}
