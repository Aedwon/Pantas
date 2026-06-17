import 'dart:io';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart' show GeneratedDatabase, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app database creates local artifact cache table at schema version 12',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, equals(12));
    expect(await _tableNames(db), contains('user_metrics_artifacts_local'));
  });

  test('artifact cache stores one row per user exam and artifact', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 6, 10);

    await db.into(db.userMetricsArtifactsLocal).insert(
          UserMetricsArtifactsLocalCompanion.insert(
            userId: 'user_1',
            examId: 'exam_cse',
            artifactId: 'post_mock_recap',
            shareId: 'share_1',
            payloadJson: '{"title":"Mock 1"}',
            firedAt: now,
          ),
        );
    await db.into(db.userMetricsArtifactsLocal).insertOnConflictUpdate(
          UserMetricsArtifactsLocalCompanion.insert(
            userId: 'user_1',
            examId: 'exam_cse',
            artifactId: 'post_mock_recap',
            shareId: 'share_1',
            payloadJson: '{"title":"Mock 1 updated"}',
            firedAt: now,
            sharedAt: Value(now.add(const Duration(minutes: 5))),
            sharePlatform: const Value('system'),
          ),
        );

    final rows = await db.select(db.userMetricsArtifactsLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.sharedAt, now.add(const Duration(minutes: 5)));
    expect(rows.single.sharePlatform, 'system');
  });

  test('artifact cache table is not registered for sync', () {
    final registrySource = File('lib/core/sync/engine/collection_registry.dart')
        .readAsStringSync();

    expect(
      registrySource,
      isNot(contains('user_metrics_artifacts_local')),
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
