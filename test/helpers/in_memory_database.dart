import 'dart:convert';
import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

AppDatabase inMemoryDatabase() => AppDatabase(NativeDatabase.memory());

Future<void> seedTopicWithQuestions(
  AppDatabase db, {
  required String examId,
  required String topicId,
  required String topicName,
  required List<String> questionIds,
  String subjectId = 'subj_default',
  List<String> lessonIds = const [],
  Map<String, String> questionLessonMap = const {},
}) async {
  await db.into(db.exams).insertOnConflictUpdate(
        ExamsCompanion.insert(
          id: examId,
          code: examId,
          name: examId,
          shortName: examId,
          language: 'en',
        ),
      );
  await db.into(db.subjects).insertOnConflictUpdate(
        SubjectsCompanion.insert(
          id: subjectId,
          examId: examId,
          name: subjectId,
          ordering: 0,
        ),
      );
  await db.into(db.topics).insertOnConflictUpdate(
        TopicsCompanion.insert(
          id: topicId,
          subjectId: subjectId,
          name: topicName,
          ordering: 0,
        ),
      );
  for (final lId in lessonIds) {
    await db.into(db.lessons).insertOnConflictUpdate(
          LessonsCompanion.insert(
            id: lId,
            topicId: topicId,
            title: 'Lesson $lId',
            summary: 'summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
            ordering: const Value(0),
          ),
        );
  }
  for (final qId in questionIds) {
    await db.into(db.questions).insertOnConflictUpdate(
          QuestionsCompanion.insert(
            id: qId,
            version: 1,
            examIdsJson: jsonEncode([examId]),
            topicId: topicId,
            lessonId: Value(questionLessonMap[qId]),
            language: 'en',
            stem: 'stem $qId',
            choicesJson: jsonEncode([
              {'id': 'c_a', 'label': 'A', 'text': 'a', 'isCorrect': true},
              {'id': 'c_b', 'label': 'B', 'text': 'b', 'isCorrect': false},
            ]),
            explanation: 'explanation $qId',
          ),
        );
  }
}

Future<void> seedContentTopicWithQuestions(
  ContentDatabase db, {
  required String examId,
  required String topicId,
  required String topicName,
  required List<String> questionIds,
  String subjectId = 'subj_default',
  List<String> lessonIds = const [],
  Map<String, String> questionLessonMap = const {},
}) async {
  await db.into(db.contentExams).insertOnConflictUpdate(
        ContentExamsCompanion.insert(
          id: examId,
          code: examId,
          name: examId,
          shortName: examId,
          language: 'en',
          ordering: 1,
          isCustom: const Value(false),
          updatedAt: DateTime.now(),
          schemaVersion: 1,
        ),
      );
  await db.into(db.contentSubjects).insertOnConflictUpdate(
        ContentSubjectsCompanion.insert(
          id: subjectId,
          examId: examId,
          name: subjectId,
          ordering: 0,
          updatedAt: DateTime.now(),
          schemaVersion: 1,
        ),
      );
  await db.into(db.contentTopics).insertOnConflictUpdate(
        ContentTopicsCompanion.insert(
          id: topicId,
          subjectId: subjectId,
          name: topicName,
          ordering: 0,
          updatedAt: DateTime.now(),
          schemaVersion: 1,
        ),
      );
  for (final lId in lessonIds) {
    await db.into(db.contentLessons).insertOnConflictUpdate(
          ContentLessonsCompanion.insert(
            id: lId,
            topicId: topicId,
            title: 'Lesson $lId',
            summary: 'summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
            ordering: const Value(0),
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
  }
  for (final qId in questionIds) {
    await db.into(db.contentQuestions).insertOnConflictUpdate(
          ContentQuestionsCompanion.insert(
            id: qId,
            version: 1,
            topicId: topicId,
            lessonId: Value(questionLessonMap[qId]),
            language: 'en',
            stemJson: jsonEncode([
              {'_type': 'block', 'children': [{'_type': 'span', 'text': 'stem $qId'}]}
            ]),
            explanationJson: jsonEncode([
              {'_type': 'block', 'children': [{'_type': 'span', 'text': 'explanation $qId'}]}
            ]),
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentChoices).insertOnConflictUpdate(
          ContentChoicesCompanion.insert(
            id: '${qId}_a',
            questionId: qId,
            label: 'A',
            textValue: 'a',
            isCorrect: true,
            ordering: 1,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentChoices).insertOnConflictUpdate(
          ContentChoicesCompanion.insert(
            id: '${qId}_b',
            questionId: qId,
            label: 'B',
            textValue: 'b',
            isCorrect: false,
            ordering: 2,
            updatedAt: DateTime.now(),
            schemaVersion: 1,
          ),
        );
    await db.into(db.contentQuestionExams).insertOnConflictUpdate(
          ContentQuestionExamsCompanion.insert(
            questionId: qId,
            examId: examId,
          ),
        );
  }
}
