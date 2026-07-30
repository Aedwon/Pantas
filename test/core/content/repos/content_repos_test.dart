import 'dart:convert';

import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/repos/exam_repo.dart';
import 'package:pantas/core/content/repos/lesson_repo.dart';
import 'package:pantas/core/content/repos/question_repo.dart';
import 'package:pantas/core/content/repos/topic_repo.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentDatabase db;
  final updatedAt = DateTime.utc(2026, 5, 17);

  setUp(() async {
    db = ContentDatabase(NativeDatabase.memory());
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
