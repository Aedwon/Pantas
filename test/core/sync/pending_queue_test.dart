import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('enqueue inserts a new upsert operation', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final now = DateTime.utc(2026, 5, 18);

    await queue.enqueue(
      tableType: 'quiz_attempts',
      rowId: 'attempt_1',
      op: PendingSyncOp.upsert,
      queuedAt: now,
    );

    final pending = await queue.drain(limit: 500);
    expect(pending, hasLength(1));
    expect(pending.single.tableType, 'quiz_attempts');
    expect(pending.single.rowId, 'attempt_1');
    expect(pending.single.op, PendingSyncOp.upsert.name);
    expect(pending.single.queuedAt, now);
  });

  test('enqueue coalesces duplicate table and row preserving oldest queuedAt',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final first = DateTime.utc(2026, 5, 18);
    final second = first.add(const Duration(seconds: 5));

    await queue.enqueue(
      tableType: 'quiz_attempts',
      rowId: 'attempt_1',
      op: PendingSyncOp.upsert,
      queuedAt: first,
    );
    await queue.enqueue(
      tableType: 'quiz_attempts',
      rowId: 'attempt_1',
      op: PendingSyncOp.delete,
      queuedAt: second,
    );

    final pending = await queue.drain(limit: 500);
    expect(pending, hasLength(1));
    expect(pending.single.queuedAt, first);
    expect(pending.single.op, PendingSyncOp.delete.name);
  });

  test('delete followed by upsert leaves an upsert operation', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final now = DateTime.utc(2026, 5, 18);

    await queue.enqueue(
      tableType: 'fsrs_cards',
      rowId: 'question_1',
      op: PendingSyncOp.delete,
      queuedAt: now,
    );
    await queue.enqueue(
      tableType: 'fsrs_cards',
      rowId: 'question_1',
      op: PendingSyncOp.upsert,
      queuedAt: now.add(const Duration(seconds: 1)),
    );

    final pending = await queue.drain(limit: 500);
    expect(pending.single.op, PendingSyncOp.upsert.name);
  });

  test('drain returns rows in FIFO order with a configurable limit', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final now = DateTime.utc(2026, 5, 18);

    await queue.enqueue(
      tableType: 'quiz_attempts',
      rowId: 'attempt_2',
      op: PendingSyncOp.upsert,
      queuedAt: now.add(const Duration(seconds: 2)),
    );
    await queue.enqueue(
      tableType: 'quiz_attempts',
      rowId: 'attempt_1',
      op: PendingSyncOp.upsert,
      queuedAt: now,
    );

    final pending = await queue.drain(limit: 1);
    expect(pending.map((row) => row.rowId), ['attempt_1']);
  });

  test('markFailure increments attempts and records last error', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final now = DateTime.utc(2026, 5, 18);

    await queue.enqueue(
      tableType: 'lesson_progress',
      rowId: 'lesson_1',
      op: PendingSyncOp.upsert,
      queuedAt: now,
    );
    final row = (await queue.drain(limit: 1)).single;
    await queue.markFailure(
      [PendingSyncIdentity.fromRow(row)],
      error: 'unavailable',
      attemptedAt: now.add(const Duration(seconds: 1)),
    );

    final failed = (await queue.drain(limit: 1)).single;
    expect(failed.attempts, 1);
    expect(failed.lastError, 'unavailable');
  });

  test('markSuccess deletes flushed rows', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);

    await queue.enqueue(
      tableType: 'assessments',
      rowId: 'cse',
      op: PendingSyncOp.upsert,
      queuedAt: DateTime.utc(2026, 5, 18),
    );
    final row = (await queue.drain(limit: 1)).single;

    await queue.markSuccess([PendingSyncIdentity.fromRow(row)]);

    expect(await queue.drain(limit: 500), isEmpty);
  });

  test('outbox identity is scoped by uid and generation', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final now = DateTime.utc(2026, 8, 30);

    Future<void> insert(String uid, String generationId) {
      return db.customStatement(
        'insert into pending_sync '
        '(uid,generation_id,table_type,row_id,op,base_state,mutation_id,'
        'revision,queued_at) values (?,?,?,?,?,?,?,?,?)',
        <Object?>[
          uid,
          generationId,
          'quiz_attempts',
          'attempt_1',
          'upsert',
          'knownAbsent',
          '$uid-$generationId',
          1,
          now.millisecondsSinceEpoch,
        ],
      );
    }

    await insert('uid-1', 'gen-1');
    await insert('uid-1', 'gen-2');
    await insert('uid-2', 'gen-1');

    final rows = await db
        .customSelect(
          'select uid,generation_id from pending_sync order by uid,generation_id',
        )
        .get();
    expect(rows, hasLength(3));
  });

  test('stale success identity cannot clear a newer outbox revision', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final now = DateTime.utc(2026, 8, 30);

    final first = await queue.enqueueGenerationBound(
      uid: 'u1',
      generationId: 'g1',
      tableType: 'quiz_attempts',
      rowId: 'a1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'm1',
      queuedAt: now,
    );
    final identity = PendingSyncIdentity.fromRow(first);
    final second = await queue.enqueueGenerationBound(
      uid: 'u1',
      generationId: 'g1',
      tableType: 'quiz_attempts',
      rowId: 'a1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'm2',
      queuedAt: now.add(const Duration(seconds: 1)),
    );

    expect(second.revision, first.revision + 1);
    await queue.markSuccess([identity]);

    final remaining = (await queue.drain(limit: 10)).single;
    expect(remaining.revision, second.revision);
    expect(remaining.mutationId, 'm2');
  });

  test('stale failure identity cannot mutate a newer outbox revision',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = PendingQueue(db);
    final now = DateTime.utc(2026, 8, 30);

    final first = await queue.enqueueGenerationBound(
      uid: 'u1',
      generationId: 'g1',
      tableType: 'fsrs_cards',
      rowId: 'q1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'm1',
      queuedAt: now,
    );
    final identity = PendingSyncIdentity.fromRow(first);
    await queue.enqueueGenerationBound(
      uid: 'u1',
      generationId: 'g1',
      tableType: 'fsrs_cards',
      rowId: 'q1',
      op: PendingSyncOp.upsert,
      baseState: 'knownAbsent',
      baseUpdatedAt: null,
      mutationId: 'm2',
      queuedAt: now.add(const Duration(seconds: 1)),
    );

    await queue.markFailure(
      [identity],
      error: 'stale-failure',
      attemptedAt: now.add(const Duration(seconds: 2)),
    );

    final remaining = (await queue.drain(limit: 10)).single;
    expect(remaining.mutationId, 'm2');
    expect(remaining.attempts, 0);
    expect(remaining.lastError, isNull);
  });
}
