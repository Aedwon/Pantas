import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/sync_engine.dart';

void main() {
  test('named sync starts exactly ten listeners under active generation',
      () async {
    final engine = SyncEngine(
      uid: 'user-1',
      isAnonymous: false,
    );

    await engine.start(generationId: 'generation-1');

    expect(engine.activeGenerationId, 'generation-1');
    expect(engine.activeListenerPaths, hasLength(10));
    expect(
      engine.activeListenerPaths.every(
        (path) => path.startsWith(
          'users/user-1/sync_generations/generation-1/',
        ),
      ),
      isTrue,
    );
  });

  test('generation switch stops old listeners before local replacement',
      () async {
    final engine = SyncEngine(uid: 'user-1', isAnonymous: false);
    await engine.start(generationId: 'generation-1');
    var replacementCalls = 0;

    await engine.switchGeneration(
      generationId: 'generation-2',
      replaceLocalSnapshot: () async {
        replacementCalls += 1;
        expect(engine.activeGenerationId, isNull);
        expect(engine.activeListenerPaths, isEmpty);
      },
    );

    expect(replacementCalls, 1);
    expect(engine.activeGenerationId, 'generation-2');
    expect(
      engine.activeListenerPaths.every(
        (path) => path.contains('/sync_generations/generation-2/'),
      ),
      isTrue,
    );
  });

  test('failed generation replacement leaves old generation quiesced',
      () async {
    final engine = SyncEngine(uid: 'user-1', isAnonymous: false);
    await engine.start(generationId: 'generation-1');

    await expectLater(
      engine.switchGeneration(
        generationId: 'generation-2',
        replaceLocalSnapshot: () async {
          throw StateError('download failed');
        },
      ),
      throwsStateError,
    );

    expect(engine.activeGenerationId, isNull);
    expect(engine.activeListenerPaths, isEmpty);
  });

  test('ordinary local mutations share one debounce timer', () async {
    var flushes = 0;
    final engine = SyncEngine(
      uid: 'user-1',
      isAnonymous: false,
      forceFlush: () async {
        flushes += 1;
      },
      localMutationDebounce: const Duration(milliseconds: 20),
    );
    await engine.start(generationId: 'generation-1');

    engine.notifyLocalMutation();
    engine.notifyLocalMutation();
    engine.notifyLocalMutation();
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(flushes, 1);
  });

  test('default local mutation debounce remains exactly five seconds', () {
    expect(SyncEngine.defaultLocalMutationDebounce, const Duration(seconds: 5));
  });

  test('reconnect cancels pending debounce and requests immediate flush',
      () async {
    var flushes = 0;
    final engine = SyncEngine(
      uid: 'user-1',
      isAnonymous: false,
      forceFlush: () async {
        flushes += 1;
      },
      localMutationDebounce: const Duration(milliseconds: 40),
    );
    await engine.start(generationId: 'generation-1');

    engine.notifyLocalMutation();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await engine.onReconnect();
    expect(flushes, 1);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(flushes, 1);
  });

  test('anonymous engine never starts listeners or flushes', () async {
    var flushes = 0;
    final engine = SyncEngine(
      uid: 'anon-1',
      isAnonymous: true,
      forceFlush: () async {
        flushes += 1;
      },
      localMutationDebounce: const Duration(milliseconds: 10),
    );

    await engine.start(generationId: 'generation-1');
    engine.notifyLocalMutation();
    await engine.onReconnect();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(engine.activeGenerationId, isNull);
    expect(engine.activeListenerPaths, isEmpty);
    expect(flushes, 0);
  });
}
