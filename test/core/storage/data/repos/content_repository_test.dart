import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentRepository repo;

  setUp(() async {
    db = inMemoryDatabase();
    repo = ContentRepository(db);

    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_cse_pro',
            code: 'CSE_PRO',
            name: 'CSE Pro',
            shortName: 'CSE Pro',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'exam_cse_pro',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.questions).insert(
          QuestionsCompanion.insert(
            id: 'q1',
            version: 1,
            examIdsJson: jsonEncode(['exam_cse_pro']),
            topicId: 't1',
            language: 'en',
            stem: 'stem',
            choicesJson: jsonEncode([
              {'id': 'c_a', 'label': 'A', 'text': 'x', 'isCorrect': false},
              {'id': 'c_b', 'label': 'B', 'text': 'y', 'isCorrect': true},
            ]),
            explanation: 'because y',
          ),
        );
  });

  tearDown(() => db.close());

  test('listExams returns exams with their nested subjects', () async {
    final exams = await repo.listExams();
    expect(exams, hasLength(1));
    expect(exams.first.id, equals('exam_cse_pro'));
    expect(exams.first.subjects, hasLength(1));
    expect(exams.first.subjects.first.id, equals('s1'));
  });

  test('questionsByTopic returns hydrated Question models', () async {
    final qs = await repo.questionsByTopic('t1');
    expect(qs, hasLength(1));
    expect(qs.first.choices, hasLength(2));
    expect(qs.first.correctChoice.id, equals('c_b'));
  });

  test('questionById returns null when not found', () async {
    expect(await repo.questionById('missing'), isNull);
  });
}
