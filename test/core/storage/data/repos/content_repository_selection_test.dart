import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/question_selection_row.dart';

void main() {
  late ContentDatabase db;
  late ContentRepository repo;

  setUp(() async {
    db = ContentDatabase(NativeDatabase.memory());
    repo = ContentRepository(db);
    final now = DateTime.utc(2026, 9, 9);

    await db.into(db.contentExams).insert(
          ContentExamsCompanion.insert(
            id: 'exam',
            code: 'EXAM',
            name: 'Exam',
            shortName: 'Exam',
            language: 'en',
            ordering: 1,
            isCustom: const Value(false),
            updatedAt: now,
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentSubjects).insert(
          ContentSubjectsCompanion.insert(
            id: 'subject',
            examId: 'exam',
            name: 'Subject',
            ordering: 1,
            updatedAt: now,
            schemaVersion: 1,
          ),
        );
    for (final entry in [('topic_a', 1), ('topic_b', 2)]) {
      await db.into(db.contentTopics).insert(
            ContentTopicsCompanion.insert(
              id: entry.$1,
              subjectId: 'subject',
              name: entry.$1,
              ordering: entry.$2,
              updatedAt: now,
              schemaVersion: 1,
            ),
          );
    }
    await db.into(db.contentLessons).insert(
          ContentLessonsCompanion.insert(
            id: 'lesson_a',
            topicId: 'topic_a',
            title: 'Lesson',
            summary: 'Summary',
            bodyJson: '[]',
            estimatedMinutes: 5,
            updatedAt: now,
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentPassages).insert(
          ContentPassagesCompanion.insert(
            id: 'passage_a',
            topicId: 'topic_a',
            title: 'Passage',
            body: 'HEAVY_PASSAGE_BODY_SENTINEL',
            language: 'en',
            wordCount: 4,
            updatedAt: now,
            schemaVersion: 1,
          ),
        );

    Future<void> insertQuestion({
      required String id,
      required String topicId,
      required int version,
      bool active = true,
      String stem = 'stem',
      String explanation = 'explanation',
      String? lessonId,
      String? passageId,
      String? figureSpecJson,
    }) async {
      String portable(String text) => jsonEncode([
            {
              '_type': 'block',
              'children': [
                {'_type': 'span', 'text': text},
              ],
            }
          ]);
      await db.into(db.contentQuestions).insert(
            ContentQuestionsCompanion.insert(
              id: id,
              schemaVersion: 1,
              isActive: Value(active),
              updatedAt: now,
              topicId: topicId,
              language: 'en',
              stemJson: stem == 'INVALID_JSON_SENTINEL' ? stem : portable(stem),
              explanationJson: explanation == 'INVALID_JSON_SENTINEL'
                  ? explanation
                  : portable(explanation),
              version: version,
              lessonId: Value(lessonId),
              passageId: Value(passageId),
              figureSpecJson: Value(figureSpecJson),
            ),
          );
    }

    await insertQuestion(
      id: 'q_meta',
      topicId: 'topic_a',
      version: 7,
      stem: 'INVALID_JSON_SENTINEL',
      explanation: 'INVALID_JSON_SENTINEL',
      lessonId: 'lesson_a',
      passageId: 'passage_a',
      figureSpecJson: '{"kind":"diagram"}',
    );
    await insertQuestion(id: 'q1', topicId: 'topic_a', version: 2);
    await insertQuestion(id: 'q2', topicId: 'topic_b', version: 3);
    await insertQuestion(
      id: 'q_withdrawn',
      topicId: 'topic_a',
      version: 4,
      active: false,
    );

    for (final id in ['q_meta', 'q1', 'q2', 'q_withdrawn']) {
      await db.into(db.contentQuestionExams).insert(
            ContentQuestionExamsCompanion.insert(
              questionId: id,
              examId: 'exam',
            ),
          );
    }

    Future<void> addChoice(
      String questionId,
      String id,
      int ordering, {
      required bool correct,
    }) async {
      await db.into(db.contentChoices).insert(
            ContentChoicesCompanion.insert(
              id: id,
              questionId: questionId,
              label: id,
              textValue: 'text $id',
              isCorrect: correct,
              ordering: ordering,
              rationale: Value('rationale $id'),
              updatedAt: now,
              schemaVersion: 1,
            ),
          );
    }

    await addChoice('q1', 'q1_b', 2, correct: true);
    await addChoice('q1', 'q1_a', 1, correct: false);
    await addChoice('q2', 'q2_b', 2, correct: false);
    await addChoice('q2', 'q2_a', 1, correct: true);
    await addChoice('q_withdrawn', 'qw_a', 1, correct: true);
  });

  tearDown(() => db.close());

  test('topic selection returns only lightweight active metadata', () async {
    final rows = await repo.selectionRowsByTopic('topic_a');

    expect(rows.map((row) => row.id), ['q_meta', 'q1']);
    final row = rows.first;
    expect(row, isA<QuestionSelectionRow>());
    expect(row.version, 7);
    expect(row.topicId, 'topic_a');
    expect(row.lessonId, 'lesson_a');
    expect(row.passageId, 'passage_a');
    expect(row.hasFigure, isTrue);
  });

  test('exam selection excludes withdrawn questions and keeps metadata',
      () async {
    final rows = await repo.selectionRowsByExam('exam');

    expect(rows.map((row) => row.id).toSet(), {'q_meta', 'q1', 'q2'});
    expect(rows.every((row) => row.id != 'q_withdrawn'), isTrue);
  });

  test(
      'selected hydration preserves caller order and existing '
      'missing semantics', () async {
    final questions = await repo.hydrateSelectedQuestions(
      ['q2', 'missing', 'q1', 'q2', 'q_withdrawn'],
    );

    expect(
      questions.map((question) => question.id),
      ['q2', 'q1', 'q_withdrawn'],
    );
    expect(questions[0].version, 3);
    expect(questions[1].version, 2);
    expect(questions[0].examIds, ['exam']);
    expect(questions[1].choices.map((choice) => choice.id), ['q1_a', 'q1_b']);
    expect(questions[0].choices.map((choice) => choice.id), ['q2_a', 'q2_b']);
  });

  test('selected hydration returns empty for empty input', () async {
    expect(await repo.hydrateSelectedQuestions(const []), isEmpty);
  });

  test('selected hydration query count grows by bounded chunks', () async {
    final ids = List.generate(805, (index) => 'batch_q_$index');
    final now = DateTime.utc(2026, 9, 9);
    await db.batch((batch) {
      batch.insertAll(db.contentQuestions, [
        for (final id in ids)
          ContentQuestionsCompanion.insert(
            id: id,
            schemaVersion: 1,
            updatedAt: now,
            topicId: 'topic_a',
            language: 'en',
            stemJson: '[{"_type":"block","children":'
                '[{"_type":"span","text":"stem"}]}]',
            explanationJson: '[{"_type":"block","children":'
                '[{"_type":"span","text":"explanation"}]}]',
            version: 1,
          ),
      ]);
    });

    var queryCount = 0;
    final countingRepo = ContentRepository(db, onQuery: () => queryCount++);
    final questions = await countingRepo.hydrateSelectedQuestions(ids);

    expect(questions, hasLength(805));
    expect(questions.map((question) => question.id), ids);
    // ceil(805 / 400) == 3 chunks for each of questions, choices, memberships.
    expect(queryCount, 9);
  });
}
