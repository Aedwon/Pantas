import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/roadmap/data/roadmap_change_log_repository.dart';
import 'package:pantas/features/roadmap/data/roadmap_day_repository.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late RoadmapDayRepository days;
  late RoadmapChangeLogRepository log;

  setUp(() {
    db = inMemoryDatabase();
    days = RoadmapDayRepository(db);
    log = RoadmapChangeLogRepository(db);
  });
  tearDown(() => db.close());

  DaySnapshot snapshot(DateTime day, {List<String> lessons = const ['l1']}) =>
      DaySnapshot(
        plan: DayPlan(
          day: day,
          lessonIds: lessons,
          reviewQuestionIds: const ['r1'],
          newQuestionIds: const ['n1'],
          isMockDay: false,
          advancedIds: const {},
        ),
        digest: RoadmapDigest(
          examId: 'exam_upcat',
          examDate: '2026-12-07:day',
          scopeTopicIds: const ['t1'],
          contentRevision: 'rev2',
          assessmentCompleted: true,
          recordedMockCount: 0,
        ),
        topicOrderHead: const ['t1'],
      );

  test('a v24 database gains both roadmap tables and keeps its data', () async {
    final temp = await Directory.systemTemp.createTemp('pantas-roadmap-v24-');
    addTearDown(() => temp.delete(recursive: true));
    final file = File('${temp.path}/v24.db');
    sqlite.sqlite3.open(file.path)
      ..execute('create table keep_me (id text not null primary key)')
      ..execute("insert into keep_me (id) values ('still here')")
      ..execute('pragma user_version = 24')
      ..close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    final tables = await upgraded
        .customSelect("select name from sqlite_master where type = 'table'")
        .map((row) => row.read<String>('name'))
        .get();
    expect(
      tables,
      containsAll(['roadmap_day_local', 'roadmap_change_log_local']),
    );
    final kept = await upgraded.customSelect('select id from keep_me').get();
    expect(kept.single.read<String>('id'), 'still here');
  });

  test('a day round trips and a rewrite replaces it', () async {
    final day = DateTime(2026, 9, 30);
    await days.write('exam_upcat', snapshot(day), DateTime(2026, 9, 30, 7));
    await days.write(
      'exam_upcat',
      snapshot(day, lessons: ['l2']),
      DateTime(2026, 9, 30, 9),
    );

    final read = await days.read('exam_upcat', day);
    expect(read!.plan.lessonIds, ['l2']);
    expect(await days.read('exam_cse', day), isNull);
  });

  test('latestBefore finds the most recent earlier day across a gap', () async {
    await days.write(
      'exam_upcat',
      snapshot(DateTime(2026, 9, 20)),
      DateTime(2026, 9, 20),
    );
    await days.write(
      'exam_upcat',
      snapshot(DateTime(2026, 9, 25)),
      DateTime(2026, 9, 25),
    );

    final prior = await days.latestBefore('exam_upcat', DateTime(2026, 9, 30));
    expect(prior!.day, DateTime(2026, 9, 25));
    expect(
      await days.latestBefore('exam_upcat', DateTime(2026, 9, 20)),
      isNull,
    );
  });

  test('only the last fourteen days are kept per exam', () async {
    for (var i = 1; i <= 16; i++) {
      final day = DateTime(2026, 9, i);
      await days.write('exam_upcat', snapshot(day), day);
    }
    expect(await days.read('exam_upcat', DateTime(2026, 9, 2)), isNull);
    expect(await days.read('exam_upcat', DateTime(2026, 9, 3)), isNotNull);
    expect(await days.read('exam_upcat', DateTime(2026, 9, 16)), isNotNull);
  });

  test('changes are appended and read back newest first', () async {
    final first = RoadmapChange(
      cause: RoadmapChangeCause.newDay,
      occurredAt: DateTime(2026, 9, 30, 7),
      after: const RoadmapDayCounts(lessons: 2, newQuestions: 15, reviews: 18),
      firstTopicsBefore: const [],
      firstTopicsAfter: const ['t1'],
    );
    final second = RoadmapChange(
      cause: RoadmapChangeCause.advanced,
      occurredAt: DateTime(2026, 9, 30, 20),
      before: const RoadmapDayCounts(lessons: 2, newQuestions: 15, reviews: 18),
      after: const RoadmapDayCounts(lessons: 4, newQuestions: 30, reviews: 18),
      firstTopicsBefore: const ['t1'],
      firstTopicsAfter: const ['t1'],
      advancedCompleted: 3,
    );

    await log.append('exam_upcat', [first]);
    await log.append('exam_upcat', [second]);

    expect(await log.recent('exam_upcat'), [second, first]);
    expect(await log.recent('exam_cse'), isEmpty);
  });
}
