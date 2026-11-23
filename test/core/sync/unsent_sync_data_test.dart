import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/sync/unsent_sync_data.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('an empty device has nothing unsent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    expect(await hasUnsentSyncData(db), isFalse);
  });

  test('a queued change is unsent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.pendingSync).insert(
          PendingSyncCompanion.insert(
            tableType: 'attempts',
            rowId: 'r1',
            op: 'upsert',
            queuedAt: DateTime(2026, 11, 23),
          ),
        );
    expect(await hasUnsentSyncData(db), isTrue);
  });

  test('a recorded local change waiting to be promoted is unsent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.customStatement(
      'insert into sync_local_mutations (collection, row_id, op, revision, '
      'mutation_epoch, causal_base_state, recorded_at) '
      "values ('attempts', 'r1', 'upsert', 1, 1, 'unbound', 1)",
    );
    expect(await hasUnsentSyncData(db), isTrue);
  });

  test('a first full upload that has not run is unsent, a pull is not',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.syncMeta).insert(
          const SyncMetaCompanion(
            key: Value('pending_full_pull'),
            value: Value('1'),
          ),
        );
    expect(await hasUnsentSyncData(db), isFalse);
    await db.into(db.syncMeta).insert(
          const SyncMetaCompanion(
            key: Value('pending_full_push'),
            value: Value('1'),
          ),
        );
    expect(await hasUnsentSyncData(db), isTrue);
  });

  group('what blocks a sign-out', () {
    Future<void> studyWrite(AppDatabase db) => db.customStatement(
          'insert into sync_local_mutations (collection, row_id, op, '
          'revision, mutation_epoch, causal_base_state, recorded_at) '
          "values ('attempts', 'r1', 'upsert', 1, 1, 'unbound', 1)",
        );

    test('a Free account with local study writes is not blocked', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await studyWrite(db);
      final reports = ReportQueue(db, account: () => 'free-1');
      expect(
        await hasUnsentForSignOut(
          db,
          canUploadStudyData: false,
          reports: reports,
        ),
        isFalse,
      );
    });

    test('a Pro account with study writes waiting is blocked', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await studyWrite(db);
      final reports = ReportQueue(db, account: () => 'pro-1');
      expect(
        await hasUnsentForSignOut(
          db,
          canUploadStudyData: true,
          reports: reports,
        ),
        isTrue,
      );
    });

    test('an unsent report blocks any account, Free included', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final reports = ReportQueue(db, account: () => 'free-1');
      await reports.add('q', 'Unsent', DateTime(2026, 11, 23));
      expect(
        await hasUnsentForSignOut(
          db,
          canUploadStudyData: false,
          reports: reports,
        ),
        isTrue,
      );
    });

    test("another account's unsent report does not block this one", () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      String? who = 'acct-a';
      final reports = ReportQueue(db, account: () => who);
      await reports.add('q', 'A', DateTime(2026, 11, 23));
      who = 'acct-b';
      expect(
        await hasUnsentForSignOut(
          db,
          canUploadStudyData: false,
          reports: reports,
        ),
        isFalse,
      );
    });
  });

  group('the wipe re-checks inside one transaction', () {
    test('it refuses when something became unsent, and wipes nothing',
        () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      var wiped = false;
      await expectLater(
        wipeUnlessUnsent(
          db,
          hasUnsent: () async => true,
          wipe: () async => wiped = true,
        ),
        throwsA(isA<AuthGatewayException>()),
      );
      expect(wiped, isFalse);
    });

    test('a check that throws fails closed and wipes nothing', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      var wiped = false;
      await expectLater(
        wipeUnlessUnsent(
          db,
          hasUnsent: () async => throw StateError('db'),
          wipe: () async => wiped = true,
        ),
        throwsA(isA<AuthGatewayException>()),
      );
      expect(wiped, isFalse);
    });

    test('a check that stalls fails closed and wipes nothing', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      var wiped = false;
      await expectLater(
        wipeUnlessUnsent(
          db,
          hasUnsent: () => Completer<bool>().future,
          wipe: () async => wiped = true,
          limit: const Duration(milliseconds: 50),
        ),
        throwsA(isA<AuthGatewayException>()),
      );
      expect(wiped, isFalse);
    });

    test('a write cannot land between the check and the wipe', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final order = <String>[];
      final gate = Completer<void>();
      final run = wipeUnlessUnsent(
        db,
        hasUnsent: () async {
          order.add('check');
          await gate.future;
          return hasUnsentSyncData(db);
        },
        wipe: () async {
          order.add('wipe');
          await db.delete(db.pendingSync).go();
        },
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      // A study write arrives while the check is waiting.
      final write = db
          .into(db.pendingSync)
          .insert(
            PendingSyncCompanion.insert(
              tableType: 'attempts',
              rowId: 'late',
              op: 'upsert',
              queuedAt: DateTime(2026, 11, 23),
            ),
          )
          .then((_) => order.add('write'));
      gate.complete();
      await run;
      await write;
      expect(order, ['check', 'wipe', 'write']);
    });
  });
}
