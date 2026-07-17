import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/custom_track_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late CustomTrackRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = CustomTrackRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedCorpus() async {
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_upcat',
            code: 'UPCAT',
            name: 'UPCAT',
            shortName: 'UPCAT',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'math',
            examId: 'exam_upcat',
            name: 'Mathematics',
            ordering: 0,
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'sci',
            examId: 'exam_upcat',
            name: 'Science',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'algebra',
            subjectId: 'math',
            name: 'Algebra',
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

  test('creating a track stores its name and hides nothing it includes',
      () async {
    await seedCorpus();

    final examId = await repo.create(
      name: 'Provincial scholarship exam',
      includedTopicIds: {'algebra', 'chem'},
    );

    final exam = await (db.select(db.exams)..where((e) => e.id.equals(examId)))
        .getSingle();
    expect(exam.name, 'Provincial scholarship exam');
    expect(exam.shortName, 'Provincial scholarship exam');
    expect(await repo.excludedTopicIds(examId), isEmpty);
  });

  test('creating a track excludes every topic it did not include', () async {
    await seedCorpus();

    final examId = await repo.create(
      name: 'Maths only',
      includedTopicIds: {'algebra'},
    );

    expect(await repo.excludedTopicIds(examId), {'chem'});
  });

  test('the created track is custom and is not listed', () async {
    await seedCorpus();

    final examId = await repo.create(name: 'Mine', includedTopicIds: {});
    final exam = await (db.select(db.exams)..where((e) => e.id.equals(examId)))
        .getSingle();

    expect(exam.isCustom, isTrue);

    final listed = await (db.select(db.exams)
          ..where((e) => e.isCustom.equals(false)))
        .get();
    expect(listed.map((e) => e.id), ['exam_upcat']);
  });

  test('re-including a topic deletes its exclusion', () async {
    await seedCorpus();
    final examId = await repo.create(
      name: 'Maths only',
      includedTopicIds: {'algebra'},
    );

    await repo.setExcluded(examId: examId, topicIds: {});

    expect(await repo.excludedTopicIds(examId), isEmpty);
  });

  test('setting exclusions never touches attempts or review state', () async {
    await seedCorpus();
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: 'exam_upcat',
            startedAt: DateTime(2026, 8),
            completedAt: Value(DateTime(2026, 8, 1, 0, 10)),
            itemsJson: jsonEncode([]),
          ),
        );
    await db.into(db.reviewStateLocal).insert(
          ReviewStateLocalCompanion.insert(
            questionId: 'q_1',
            questionVersion: 1,
            stage: 'review',
            stability: 3,
            difficulty: 5,
            due: DateTime(2026, 8, 5),
            lastReview: DateTime(2026, 8),
            reps: 2,
            lapses: 0,
            elapsedDays: 1,
            scheduledDays: 4,
          ),
        );

    await repo.setExcluded(examId: 'exam_upcat', topicIds: {'chem'});

    // Narrowing hides and never purges: both survive untouched.
    expect(await db.select(db.attemptsLocal).get(), hasLength(1));
    expect(await db.select(db.reviewStateLocal).get(), hasLength(1));
  });

  test('two tracks keep their own scopes', () async {
    await seedCorpus();

    final first = await repo.create(name: 'One', includedTopicIds: {'algebra'});
    final second = await repo.create(name: 'Two', includedTopicIds: {'chem'});

    expect(await repo.excludedTopicIds(first), {'chem'});
    expect(await repo.excludedTopicIds(second), {'algebra'});
  });
}
