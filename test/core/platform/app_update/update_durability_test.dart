import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';

import '../../../helpers/in_memory_database.dart';
import 'update_coordinator_test.dart' show FakeBridge;

void main() {
  test('apply waits for a real transaction and local outbox enqueue', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final bridge = FakeBridge();
    final held = Completer<void>();
    final entered = Completer<void>();
    final transaction = db.transaction(() async {
      await db.customStatement(
        "INSERT INTO device_prefs (key, value) VALUES ('answer', 'saved')",
      );
      entered.complete();
      await held.future;
      await PendingQueue(db).enqueue(
        tableType: 'device_prefs',
        rowId: 'answer',
        op: PendingSyncOp.upsert,
        queuedAt: DateTime.utc(2026),
      );
    });
    await entered.future;
    final coordinator = UpdateCoordinator(
      bridge: bridge,
      waitForWrites: db.waitForDurableWrites,
      onFailure: (error, _) => fail('$error'),
    )..routeChanged('/home');
    final checking = coordinator.check();
    await Future<void>.delayed(Duration.zero);
    expect(bridge.applies, 0);
    held.complete();
    await transaction;
    await checking;
    expect(bridge.applies, 1);
    expect((await db.select(db.pendingSync).get()).single.rowId, 'answer');
    expect(
      (await db
              .customSelect(
                "SELECT value FROM device_prefs WHERE key = 'answer'",
              )
              .getSingle())
          .read<String>('value'),
      'saved',
    );
  });

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
