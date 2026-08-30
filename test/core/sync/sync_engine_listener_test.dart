import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/sync_engine.dart';

void main() {
  test('start opens one listener per active generation subcollection',
      () async {
    final engine = SyncEngine(uid: 'user-1', isAnonymous: false);

    await engine.start(generationId: 'generation-1');

    expect(engine.activeGenerationId, 'generation-1');
    expect(engine.activeListenerPaths, [
      'users/user-1/sync_generations/generation-1/quiz_attempts',
      'users/user-1/sync_generations/generation-1/assessments',
      'users/user-1/sync_generations/generation-1/fsrs_cards',
      'users/user-1/sync_generations/generation-1/lesson_progress',
      'users/user-1/sync_generations/generation-1/lesson_bookmarks',
      'users/user-1/sync_generations/generation-1/question_flags',
      'users/user-1/sync_generations/generation-1/mock_exam_attempts',
      'users/user-1/sync_generations/generation-1/review_logs',
      'users/user-1/sync_generations/generation-1/track_scope',
      'users/user-1/sync_generations/generation-1/custom_blueprints',
    ]);
  });

  test('start is a no-op for anonymous users', () async {
    final engine = SyncEngine(uid: 'anon-1', isAnonymous: true);

    await engine.start(generationId: 'generation-1');

    expect(engine.activeGenerationId, isNull);
    expect(engine.activeListenerPaths, isEmpty);
  });

  test('stop cancels every listener and clears generation', () async {
    final engine = SyncEngine(uid: 'user-1', isAnonymous: false);
    await engine.start(generationId: 'generation-1');

    await engine.stop();

    expect(engine.activeGenerationId, isNull);
    expect(engine.activeListenerPaths, isEmpty);
  });

  test('manual refresh restarts active generation and force flushes queue',
      () async {
    var flushes = 0;
    final engine = SyncEngine(
      uid: 'user-1',
      isAnonymous: false,
      forceFlush: () async => flushes += 1,
    );
    await engine.start(generationId: 'generation-1');

    await engine.manualRefresh();

    expect(flushes, 1);
    expect(engine.activeGenerationId, 'generation-1');
    expect(
      engine.activeListenerPaths,
      contains(
        'users/user-1/sync_generations/generation-1/quiz_attempts',
      ),
    );
  });
}
