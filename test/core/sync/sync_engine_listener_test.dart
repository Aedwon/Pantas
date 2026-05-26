import 'package:cse_cet_reviewer/core/sync/engine/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('start opens one listener per active subcollection for named users',
      () async {
    final engine = SyncEngine(uid: 'user-1', isAnonymous: false);

    await engine.start();

    expect(engine.activeListenerPaths, [
      'users/user-1/quiz_attempts',
      'users/user-1/assessments',
      'users/user-1/fsrs_cards',
      'users/user-1/lesson_progress',
      'users/user-1/mock_exam_attempts',
    ]);
  });

  test('start is a no-op for anonymous users', () async {
    final engine = SyncEngine(uid: 'anon-1', isAnonymous: true);

    await engine.start();

    expect(engine.activeListenerPaths, isEmpty);
  });

  test('stop cancels every listener', () async {
    final engine = SyncEngine(uid: 'user-1', isAnonymous: false);
    await engine.start();

    await engine.stop();

    expect(engine.activeListenerPaths, isEmpty);
  });

  test('manual refresh restarts listeners and force flushes queue', () async {
    var flushes = 0;
    final engine = SyncEngine(
      uid: 'user-1',
      isAnonymous: false,
      forceFlush: () async => flushes += 1,
    );
    await engine.start();

    await engine.manualRefresh();

    expect(flushes, 1);
    expect(engine.activeListenerPaths, contains('users/user-1/quiz_attempts'));
  });
}
