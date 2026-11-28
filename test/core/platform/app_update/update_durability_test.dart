import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('durability includes local enqueue prelude before transaction',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final held = Completer<void>();
    final enqueue = db.trackLocalWrite(() async {
      await held.future;
      await PendingQueue(db).enqueue(
        tableType: 'device_prefs',
        rowId: 'late',
        op: PendingSyncOp.upsert,
        queuedAt: DateTime.utc(2026),
      );
    });
    var durable = false;
    final waiting = db.waitForDurableWrites().then((_) => durable = true);
    await Future<void>.delayed(Duration.zero);
    expect(durable, isFalse);
    held.complete();
    await enqueue;
    await waiting;
    expect(durable, isTrue);
    expect((await db.select(db.pendingSync).get()).single.rowId, 'late');
  });
}
