import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  Future<void> seedExamAndTopic(AppDatabase db) async {
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_upcat',
            code: 'UPCAT',
            name: 'UP College Admissions Test',
            shortName: 'UPCAT',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'sci',
            examId: 'exam_upcat',
            name: 'Science',
            ordering: 0,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'chem',
            subjectId: 'sci',
            name: 'Chemistry',
            ordering: 0,
          ),
        );
  }

  test('an existing exam reads as not custom', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedExamAndTopic(db);

    final exam = await (db.select(db.exams)
          ..where((e) => e.id.equals('exam_upcat')))
        .getSingle();

    // A listed exam is what every install already has, and the column
    // defaults rather than needing a backfill.
    expect(exam.isCustom, isFalse);
  });

  test('the exclusion table exists and takes a row', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedExamAndTopic(db);

    await db.into(db.trackScopeLocal).insert(
          TrackScopeLocalCompanion.insert(
            examId: 'exam_upcat',
            topicId: 'chem',
          ),
        );

    final rows = await db.select(db.trackScopeLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.topicId, 'chem');
  });

  test('the same exclusion cannot be written twice', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedExamAndTopic(db);

    for (var i = 0; i < 2; i += 1) {
      await db.into(db.trackScopeLocal).insertOnConflictUpdate(
            TrackScopeLocalCompanion.insert(
              examId: 'exam_upcat',
              topicId: 'chem',
            ),
          );
    }

    expect(await db.select(db.trackScopeLocal).get(), hasLength(1));
  });

  test('re-ticking a topic deletes the row and hides nothing', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedExamAndTopic(db);

    await db.into(db.trackScopeLocal).insert(
          TrackScopeLocalCompanion.insert(
            examId: 'exam_upcat',
            topicId: 'chem',
          ),
        );
    await (db.delete(db.trackScopeLocal)
          ..where(
            (s) => s.examId.equals('exam_upcat') & s.topicId.equals('chem'),
          ))
        .go();

    // Narrowing hides and re-ticking restores, because nothing was ever
    // keyed on the scope.
    expect(await db.select(db.trackScopeLocal).get(), isEmpty);
  });

  test('a custom track is an exam row that carries the flag', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'track_local_1',
            code: 'CUSTOM',
            name: 'Provincial scholarship exam',
            shortName: 'Scholarship',
            language: 'en',
            isCustom: const Value(true),
          ),
        );

    final exam = await (db.select(db.exams)
          ..where((e) => e.isCustom.equals(true)))
        .getSingle();
    expect(exam.id, 'track_local_1');
  });
}
