import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/repos/exam_repo.dart';
import 'package:pantas/core/content/repos/lesson_repo.dart';
import 'package:pantas/core/content/repos/question_repo.dart';
import 'package:pantas/core/content/repos/topic_repo.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';

void main() {
  late ContentDatabase db;
  late _SelectSpy selectSpy;
  final updatedAt = DateTime.utc(2026, 5, 17);

  setUp(() async {
    selectSpy = _SelectSpy();
    db = ContentDatabase(NativeDatabase.memory().interceptWith(selectSpy));
    await _seedCoreContent(db, updatedAt);
  });

  tearDown(() => db.close());

  test('ExamRepo.activeExams returns active exams with ordered subjects',
      () async {
    final exams = await ExamRepo(db).activeExams();

    expect(exams.map((e) => e.id), equals(['exam_cse']));
    expect(
      exams.single.subjects.map((subject) => subject.id),
      equals(['subject_math', 'subject_verbal']),
    );
  });

  test('TopicRepo.byExam flattens subject topics in ordering order', () async {
    final topics = await TopicRepo(db).byExam('exam_cse');

    expect(
      topics.map((topic) => topic.id),
      equals(['topic_percent', 'topic_vocab']),
    );
  });

  test('QuestionRepo.byTopic filters inactive questions by default', () async {
    final questions = await QuestionRepo(db).byTopic('topic_vocab');

    expect(questions.map((question) => question.id), equals(['q_active']));
    expect(questions.single.stem, equals('Pick the synonym.'));
    expect(questions.single.explanation, equals('Same meaning.'));
    expect(questions.single.correctChoice.id, equals('choice_b'));
  });

  test('QuestionRepo.bySubtopic returns active questions for a subtopic',
      () async {
    final questions = await QuestionRepo(db).bySubtopic('subtopic_synonyms');

    expect(questions.map((question) => question.id), equals(['q_active']));
  });

  test('QuestionRepo.byExam uses content_question_exams junction', () async {
    final questions = await QuestionRepo(db).byExam('exam_cse');

    expect(questions.map((question) => question.id), equals(['q_active']));
  });

  test('QuestionRepo.findById returns retired questions for history', () async {
    final question = await QuestionRepo(db).findById('q_retired');

    expect(question, isNotNull);
    expect(question!.id, equals('q_retired'));
  });

  test('LessonRepo.byTopic filters inactive lessons and preserves bodyJson',
      () async {
    final lessons = await LessonRepo(db).byTopic('topic_vocab');

    expect(lessons.map((lesson) => lesson.id), equals(['lesson_active']));
    expect(lessons.single.bodyJson.single['_type'], equals('block'));
  });

  test('LessonRepo.findById exposes nullable subtopic id', () async {
    final lesson = await LessonRepo(db).findById('lesson_active');

    expect(lesson, isNotNull);
    expect(lesson!.subtopicId, equals('subtopic_synonyms'));
  });

  group('ContentRepository.lessonMetaByTopics', () {
    test('matches full lesson ordering and metadata across topics', () async {
      await db.batch((batch) {
        batch.insertAll(db.contentLessons, [
          for (final entry in [
            ('lesson_z', 'topic_vocab', 2),
            ('lesson_b', 'topic_vocab', 1),
            ('lesson_percent', 'topic_percent', 1),
            ('lesson_a', 'topic_vocab', 1),
          ])
            ContentLessonsCompanion.insert(
              id: entry.$1,
              schemaVersion: 1,
              updatedAt: updatedAt,
              topicId: entry.$2,
              title: 'Title ${entry.$1}',
              summary: 'Summary',
              estimatedMinutes: 7,
              ordering: Value(entry.$3),
              bodyJson: _pt('Body'),
            ),
        ]);
      });
      final repo = ContentRepository(db);
      const topics = ['topic_percent', 'topic_vocab'];
      final full = await repo.lessonsByTopics(topics);

      final metadata = await repo.lessonMetaByTopics(topics);

      expect(metadata.keys, topics);
      expect(metadata['topic_vocab']!.map((lesson) => lesson.id), [
        'lesson_active',
        'lesson_retired',
        'lesson_a',
        'lesson_b',
        'lesson_z',
      ]);
      expect(metadata['topic_percent']!.single.id, 'lesson_percent');
      for (final topic in topics) {
        expect(
          metadata[topic]!.map(
            (lesson) => (
              lesson.id,
              lesson.topicId,
              lesson.title,
              lesson.ordering,
              lesson.estimatedMinutes,
            ),
          ),
          full[topic]!.map(
            (lesson) => (
              lesson.id,
              lesson.topicId,
              lesson.title,
              lesson.ordering,
              lesson.estimatedMinutes,
            ),
          ),
        );
      }
    });

    test('keeps empty requested topics and excludes unrequested lessons',
        () async {
      final metadata = await ContentRepository(db).lessonMetaByTopics(
        ['topic_percent', 'missing_topic'],
      );

      expect(metadata.keys, ['topic_percent', 'missing_topic']);
      expect(metadata['topic_percent'], isEmpty);
      expect(metadata['missing_topic'], isEmpty);
    });

    for (final entry in [(0, 0), (1, 1), (400, 1), (401, 2), (805, 3)]) {
      test('uses ${entry.$2} queries for ${entry.$1} unique topics', () async {
        final topics = List.generate(entry.$1, (index) => 'batch_topic_$index');
        var queryCount = 0;
        final repo = ContentRepository(db, onQuery: () => queryCount++);
        selectSpy.statements.clear();

        // Duplicates do not consume another batch or duplicate results.
        final metadata =
            await repo.lessonMetaByTopics(topics.followedBy(topics));

        expect(metadata.keys, topics);
        expect(metadata.values.every((lessons) => lessons.isEmpty), isTrue);
        expect(queryCount, entry.$2);
        expect(selectSpy.statements, hasLength(entry.$2));
      });
    }

    test('selects only metadata columns without reading or decoding bodies',
        () async {
      await (db.update(db.contentLessons)
            ..where((lesson) => lesson.id.equals('lesson_active')))
          .write(
        const ContentLessonsCompanion(bodyJson: Value('INVALID_JSON')),
      );
      selectSpy.statements.clear();
      selectSpy.columns.clear();

      final metadata = await ContentRepository(db).lessonMetaByTopics(
        ['topic_vocab'],
      );

      expect(metadata['topic_vocab']!.first.title, 'Vocabulary Basics');
      expect(selectSpy.statements, hasLength(1));
      expect(selectSpy.statements.single, isNot(contains('body_json')));
      expect(selectSpy.columns.single, {
        'id',
        'topic_id',
        'title',
        'ordering',
        'estimated_minutes',
      });
    });
  });
}

class _SelectSpy extends QueryInterceptor {
  final statements = <String>[];
  final columns = <Set<String>>[];

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    statements.add(statement);
    final rows = await executor.runSelect(statement, args);
    if (rows.isNotEmpty) {
      columns.add(rows.first.keys.map((key) => key.split('.').last).toSet());
    }
    return rows;
  }
}

Future<void> _seedCoreContent(ContentDatabase db, DateTime updatedAt) async {
  await db.into(db.contentExams).insert(
        ContentExamsCompanion.insert(
          id: 'exam_cse',
          schemaVersion: 1,
          updatedAt: updatedAt,
          code: 'CSE',
          name: 'Civil Service Exam',
          shortName: 'CSE',
          language: 'en',
          ordering: 1,
        ),
      );
  await db.into(db.contentExams).insert(
        ContentExamsCompanion.insert(
          id: 'exam_retired',
          schemaVersion: 1,
          isActive: const Value(false),
          updatedAt: updatedAt,
          code: 'OLD',
          name: 'Old Exam',
          shortName: 'Old',
          language: 'en',
          ordering: 2,
        ),
      );
  await db.into(db.contentSubjects).insert(
        ContentSubjectsCompanion.insert(
          id: 'subject_verbal',
          schemaVersion: 1,
          updatedAt: updatedAt,
          examId: 'exam_cse',
          name: 'Verbal',
          ordering: 2,
        ),
      );
  await db.into(db.contentSubjects).insert(
        ContentSubjectsCompanion.insert(
          id: 'subject_math',
          schemaVersion: 1,
          updatedAt: updatedAt,
          examId: 'exam_cse',
          name: 'Math',
          ordering: 1,
        ),
      );
  await db.into(db.contentTopics).insert(
        ContentTopicsCompanion.insert(
          id: 'topic_vocab',
          schemaVersion: 1,
          updatedAt: updatedAt,
          subjectId: 'subject_verbal',
          name: 'Vocabulary',
          ordering: 1,
        ),
      );
  await db.into(db.contentTopics).insert(
        ContentTopicsCompanion.insert(
          id: 'topic_percent',
          schemaVersion: 1,
          updatedAt: updatedAt,
          subjectId: 'subject_math',
          name: 'Percent',
          ordering: 1,
        ),
      );
  await db.into(db.contentQuestions).insert(
        ContentQuestionsCompanion.insert(
          id: 'q_active',
          schemaVersion: 1,
          updatedAt: updatedAt,
          topicId: 'topic_vocab',
          subtopicId: const Value('subtopic_synonyms'),
          language: 'en',
          stemJson: _pt('Pick the synonym.'),
          explanationJson: _pt('Same meaning.'),
          version: 1,
        ),
      );
  await db.into(db.contentQuestions).insert(
        ContentQuestionsCompanion.insert(
          id: 'q_retired',
          schemaVersion: 1,
          isActive: const Value(false),
          updatedAt: updatedAt,
          topicId: 'topic_vocab',
          subtopicId: const Value('subtopic_synonyms'),
          language: 'en',
          stemJson: _pt('Retired question.'),
          explanationJson: _pt('Retired explanation.'),
          version: 1,
        ),
      );
  await db.batch((batch) {
    batch
      ..insertAll(db.contentChoices, [
        ContentChoicesCompanion.insert(
          id: 'choice_a',
          schemaVersion: 1,
          updatedAt: updatedAt,
          questionId: 'q_active',
          label: 'A',
          textValue: 'Different',
          isCorrect: false,
          ordering: 1,
        ),
        ContentChoicesCompanion.insert(
          id: 'choice_b',
          schemaVersion: 1,
          updatedAt: updatedAt,
          questionId: 'q_active',
          label: 'B',
          textValue: 'Same',
          isCorrect: true,
          ordering: 2,
        ),
        ContentChoicesCompanion.insert(
          id: 'choice_retired',
          schemaVersion: 1,
          updatedAt: updatedAt,
          questionId: 'q_retired',
          label: 'A',
          textValue: 'Retired',
          isCorrect: true,
          ordering: 1,
        ),
      ])
      ..insertAll(
        db.contentQuestionExams,
        [
          ContentQuestionExamsCompanion.insert(
            questionId: 'q_active',
            examId: 'exam_cse',
          ),
          ContentQuestionExamsCompanion.insert(
            questionId: 'q_retired',
            examId: 'exam_cse',
          ),
        ],
      );
  });
  await db.into(db.contentLessons).insert(
        ContentLessonsCompanion.insert(
          id: 'lesson_active',
          schemaVersion: 1,
          updatedAt: updatedAt,
          topicId: 'topic_vocab',
          subtopicId: const Value('subtopic_synonyms'),
          title: 'Vocabulary Basics',
          summary: 'Core vocabulary concepts',
          estimatedMinutes: 5,
          bodyJson: _pt('Lesson body.'),
        ),
      );
  await db.into(db.contentLessons).insert(
        ContentLessonsCompanion.insert(
          id: 'lesson_retired',
          schemaVersion: 1,
          isActive: const Value(false),
          updatedAt: updatedAt,
          topicId: 'topic_vocab',
          title: 'Retired',
          summary: 'Retired',
          estimatedMinutes: 3,
          bodyJson: _pt('Retired body.'),
        ),
      );
}

String _pt(String text) => jsonEncode([
      {
        '_type': 'block',
        'style': 'normal',
        'children': [
          {'_type': 'span', 'text': text, 'marks': <String>[]},
        ],
      },
    ]);
