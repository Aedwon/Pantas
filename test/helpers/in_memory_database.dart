import 'dart:convert';
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
