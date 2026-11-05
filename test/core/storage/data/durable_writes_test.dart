import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/durable_writes.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('a batch is followed by one flush', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    var flushes = 0;
    final subscription = flushAfterWrites(
      db,
      delay: const Duration(milliseconds: 1),
      flush: () async => flushes++,
    );
    addTearDown(subscription.cancel);

    await db.batch((batch) {
      batch
        ..insert(
          db.accountPrefs,
          AccountPrefsCompanion.insert(key: 'a', value: '1'),
        )
        ..insert(
          db.accountPrefs,
          AccountPrefsCompanion.insert(key: 'b', value: '2'),
        );
    });
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(flushes, 1);
  });

  test('a read does not flush', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    var flushes = 0;
    final subscription = flushAfterWrites(
      db,
      delay: const Duration(milliseconds: 1),
      flush: () async => flushes++,
    );
    addTearDown(subscription.cancel);

    await db.select(db.accountPrefs).get();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(flushes, 0);
  });

  test('a failed flush does not surface', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final subscription = flushAfterWrites(
      db,
      delay: const Duration(milliseconds: 1),
      flush: () async => throw StateError('closed'),
    );
    addTearDown(subscription.cancel);

    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(key: 'a', value: '1'),
          mode: InsertMode.insertOrReplace,
        );
    await Future<void>.delayed(const Duration(milliseconds: 30));
  });
}
