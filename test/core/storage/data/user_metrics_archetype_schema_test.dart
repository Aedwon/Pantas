import 'dart:io';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart' show GeneratedDatabase;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app database creates local archetype cache table at schema version 14',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, equals(14));
    expect(await _tableNames(db), contains('user_metrics_archetypes_local'));
  });

  test('archetype cache stores one row per user exam window and archetype',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 6, 10);

    await db.into(db.userMetricsArchetypesLocal).insert(
          UserMetricsArchetypesLocalCompanion.insert(
            userId: 'user_1',
            examId: 'exam_cse',
            window: 'prepWindow',
            archetypeId: 'night_owl_sprinter',
            matchScore: 0.82,
            synthesizedCopy: 'Sharpest at 9pm.',
            computedAt: now,
            validUntil: now.add(const Duration(hours: 24)),
          ),
        );
    await db.into(db.userMetricsArchetypesLocal).insertOnConflictUpdate(
          UserMetricsArchetypesLocalCompanion.insert(
            userId: 'user_1',
            examId: 'exam_cse',
            window: 'prepWindow',
            archetypeId: 'night_owl_sprinter',
            matchScore: 0.9,
            synthesizedCopy: 'Updated.',
            computedAt: now,
            validUntil: now.add(const Duration(hours: 24)),
          ),
        );

    final rows = await db.select(db.userMetricsArchetypesLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.matchScore, 0.9);
  });

  test('archetype cache table is not registered for sync', () {
    final registrySource = File('lib/core/sync/engine/collection_registry.dart')
        .readAsStringSync();

    expect(
      // Keep this as a source guard so derived tables never enter Spec 3 sync.
      registrySource,
      isNot(contains('user_metrics_archetypes_local')),
    );
  });
}

Future<List<String>> _tableNames(GeneratedDatabase database) async {
  final rows = await database
      .customSelect(
        "select name from sqlite_master where type = 'table' "
        "and name not like 'sqlite_%' order by name",
      )
      .get();
  return rows.map((row) => row.read<String>('name')).toList();
}
