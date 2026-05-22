import 'package:cse_cet_reviewer/core/sync/engine/pending_queue.dart';
import 'package:cse_cet_reviewer/core/sync/engine/push_pipeline.dart';
import 'package:cse_cet_reviewer/core/sync/firestore/firestore_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('flush writes queued upserts and deletes in one batch', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = FakeFirestoreGateway();
    final pipeline = PushPipeline(
      queue: queue,
      gateway: gateway,
      uid: 'user-1',
      isAnonymous: false,
    );
    final now = DateTime.utc(2026, 5, 18);

    await queue.enqueue(
      tableType: 'quiz_attempts',
      rowId: 'attempt_1',
      op: PendingSyncOp.upsert,
      queuedAt: now,
    );
    await queue.enqueue(
      tableType: 'fsrs_cards',
      rowId: 'q1',
      op: PendingSyncOp.delete,
      queuedAt: now,
    );

    await pipeline.flush();

    expect(gateway.committedBatches.single.map((write) => write.path), [
      'users/user-1/quiz_attempts/attempt_1',
      'users/user-1/fsrs_cards/q1',
    ]);
    expect(await queue.drain(limit: 500), isEmpty);
  });

  test('flush splits more than 500 operations into multiple batches', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = FakeFirestoreGateway();
    final pipeline = PushPipeline(
      queue: queue,
      gateway: gateway,
      uid: 'user-1',
      isAnonymous: false,
    );

    for (var i = 0; i < 501; i += 1) {
      await queue.enqueue(
        tableType: 'quiz_attempts',
        rowId: 'attempt_$i',
        op: PendingSyncOp.delete,
        queuedAt: DateTime.utc(2026, 5, 18, 0, 0, i),
      );
    }

    await pipeline.flush();

    expect(gateway.committedBatches, hasLength(2));
    expect(gateway.committedBatches.first, hasLength(500));
    expect(gateway.committedBatches.last, hasLength(1));
  });

  test('retryable failure increments attempts and keeps queue rows', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = ThrowingFirestoreGateway();
    final pipeline = PushPipeline(
      queue: queue,
      gateway: gateway,
      uid: 'user-1',
      isAnonymous: false,
    );

    await queue.enqueue(
      tableType: 'lesson_progress',
      rowId: 'lesson_1',
      op: PendingSyncOp.upsert,
      queuedAt: DateTime.utc(2026, 5, 18),
    );

    await pipeline.flush();

    final pending = await queue.drain(limit: 500);
    expect(pending.single.attempts, 1);
    expect(pending.single.lastError, 'unavailable');
  });

  test('anonymous user leaves queue untouched', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final gateway = FakeFirestoreGateway();
    final pipeline = PushPipeline(
      queue: queue,
      gateway: gateway,
      uid: 'anon-1',
      isAnonymous: true,
    );

    await queue.enqueue(
      tableType: 'quiz_attempts',
      rowId: 'attempt_1',
      op: PendingSyncOp.upsert,
      queuedAt: DateTime.utc(2026, 5, 18),
    );

    await pipeline.flush();

    expect(gateway.committedBatches, isEmpty);
    expect(await queue.drain(limit: 500), hasLength(1));
  });
}

class ThrowingFirestoreGateway implements FirestoreGateway {
  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    throw const SyncGatewayException('unavailable');
  }
}
