import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart' show GeneratedDatabase;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app database creates mock_attempts at schema version 9', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, equals(9));
    expect(await _tableNames(db), contains('mock_attempts'));
  });

  test('mock_attempts stores crash safe state and score snapshots', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final startedAt = DateTime.utc(2026, 5, 19, 1);

    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'mock_1',
            userId: 'user_1',
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
            blueprintName: 'CSE Practice',
            durationMinutes: 90,
            status: 'in_progress',
            strictMode: false,
            sampledQuestionsJson: '[]',
            startedAt: startedAt,
            lastFlushedAt: startedAt,
            updatedAt: startedAt,
          ),
        );

    final row = await db.select(db.mockAttempts).getSingle();
    expect(row.elapsedSeconds, 0);
    expect(row.accumulatedPausedSeconds, 0);
    expect(row.pausedAtLastFlush, isFalse);
    expect(row.answersJson, '{}');
    expect(row.flagsJson, '[]');
    expect(row.currentIndex, 0);
    expect(row.scoreRaw, isNull);
  });

  test('mock_attempts has active attempt and history indexes', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final indexNames = await _indexNames(db);

    expect(indexNames, contains('mock_attempts_active_idx'));
    expect(indexNames, contains('mock_attempts_history_idx'));
  });

  test('content database does not include mock_attempts', () async {
    final db = ContentDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await _tableNames(db), isNot(contains('mock_attempts')));
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

Future<List<String>> _indexNames(GeneratedDatabase database) async {
  final rows = await database
      .customSelect(
        "select name from sqlite_master where type = 'index' "
        "and name not like 'sqlite_%' order by name",
      )
      .get();
  return rows.map((row) => row.read<String>('name')).toList();
}
