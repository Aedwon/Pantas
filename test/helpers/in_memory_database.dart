import 'dart:convert';
import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase inMemoryDatabase() => AppDatabase(NativeDatabase.memory());

ContentDatabase inMemoryContentDatabase() =>
    ContentDatabase(NativeDatabase.memory());

/// A content database that closes itself when the test ends.
///
/// Most tests here assert on a student's own data and touch the corpus only
/// because a provider they depend on reads it. They still have to supply a
/// content database or that provider throws. Call this from inside a test or
/// a `setUp` so the teardown registers against the right scope.
ContentDatabase openTestContentDatabase() {
  final db = inMemoryContentDatabase();
  addTearDown(db.close);
  return db;
}

/// The content tables all carry `schemaVersion` and `updatedAt`, which the
/// sync path writes and a test never asserts on. These four helpers supply
/// them so a test seeds only the fields it is actually about.
final _seedStamp = DateTime.utc(2026, 8, 11);

Future<void> seedContentExam(
  ContentDatabase db, {
  required String examId,
  String? code,
  String? name,
  String? shortName,
  int ordering = 1,
  bool isCustom = false,
}) async {
  await db.into(db.contentExams).insertOnConflictUpdate(
        ContentExamsCompanion.insert(
          id: examId,
          code: code ?? examId,
          name: name ?? examId,
          shortName: shortName ?? code ?? examId,
          language: 'en',
          ordering: ordering,
          isCustom: Value(isCustom),
          schemaVersion: 1,
          updatedAt: _seedStamp,
        ),
      );
}

Future<void> seedContentSubject(
  ContentDatabase db, {
  required String subjectId,
  required String examId,
  String? name,
  int ordering = 1,
}) async {
  await db.into(db.contentSubjects).insertOnConflictUpdate(
        ContentSubjectsCompanion.insert(
          id: subjectId,
          examId: examId,
          name: name ?? subjectId,
          ordering: ordering,
          schemaVersion: 1,
          updatedAt: _seedStamp,
        ),
      );
}

Future<void> seedContentTopic(
  ContentDatabase db, {
  required String topicId,
  required String subjectId,
  String? name,
  int ordering = 1,
}) async {
  await db.into(db.contentTopics).insertOnConflictUpdate(
        ContentTopicsCompanion.insert(
          id: topicId,
          subjectId: subjectId,
          name: name ?? topicId,
          ordering: ordering,
          schemaVersion: 1,
          updatedAt: _seedStamp,
        ),
      );
}

Future<void> seedContentLesson(
  ContentDatabase db, {
  required String lessonId,
  required String topicId,
  String? title,
  String summary = 'Summary',
  List<Map<String, Object?>>? body,
  String? bodyJson,
  int estimatedMinutes = 5,
  int ordering = 0,
}) async {
  await db.into(db.contentLessons).insertOnConflictUpdate(
        ContentLessonsCompanion.insert(
          id: lessonId,
          topicId: topicId,
          title: title ?? 'Lesson $lessonId',
          summary: summary,
          bodyJson:
              bodyJson ?? jsonEncode(body ?? const <Map<String, Object?>>[]),
          estimatedMinutes: estimatedMinutes,
          ordering: Value(ordering),
          schemaVersion: 1,
          updatedAt: _seedStamp,
        ),
      );
}

/// Seeds one question with two choices, A correct, and tags it for [examId].
/// The exam tag is a row in its own table now, so a question seeded without
/// one is invisible to every exam-scoped read.
Future<void> seedContentQuestion(
  ContentDatabase db, {
  required String questionId,
  required String topicId,
  required String examId,
  String? stem,
  String? lessonId,
  bool isActive = true,
  String correctText = 'Choice A',
  String wrongText = 'Choice B',
}) async {
  await db.into(db.contentQuestions).insertOnConflictUpdate(
        ContentQuestionsCompanion.insert(
          id: questionId,
          version: 1,
          topicId: topicId,
          lessonId: Value(lessonId),
          language: 'en',
          stemJson: _portableText(stem ?? 'Question $questionId?'),
          explanationJson: _portableText('Explanation for $questionId'),
          isActive: Value(isActive),
          schemaVersion: 1,
          updatedAt: _seedStamp,
        ),
      );
  await db.into(db.contentChoices).insertOnConflictUpdate(
        ContentChoicesCompanion.insert(
          id: '${questionId}_a',
          questionId: questionId,
          label: 'A',
          textValue: correctText,
          isCorrect: true,
          ordering: 1,
          schemaVersion: 1,
          updatedAt: _seedStamp,
        ),
      );
  await db.into(db.contentChoices).insertOnConflictUpdate(
        ContentChoicesCompanion.insert(
          id: '${questionId}_b',
          questionId: questionId,
          label: 'B',
          textValue: wrongText,
          isCorrect: false,
          ordering: 2,
          schemaVersion: 1,
          updatedAt: _seedStamp,
        ),
      );
  await db.into(db.contentQuestionExams).insertOnConflictUpdate(
        ContentQuestionExamsCompanion.insert(
          questionId: questionId,
          examId: examId,
        ),
      );
}

/// Seeds a question whose choices are given explicitly, keeping the ids the
/// caller chose. Tests that assert on a chosen answer name those ids, so a
/// helper that invented its own would quietly change what they check.
///
/// [choices] takes the shape the old asset used: id, label, text, isCorrect.
Future<void> seedContentQuestionWithChoices(
  ContentDatabase db, {
  required String questionId,
  required String topicId,
  required List<Map<String, Object?>> choices,
  String? examId,
  List<String> examIds = const [],
  String? stem,
  String? explanation,
  String? lessonId,
  String? passageId,
  bool isActive = true,
  int version = 1,
}) async {
  await db.into(db.contentQuestions).insertOnConflictUpdate(
        ContentQuestionsCompanion.insert(
          id: questionId,
          version: version,
          topicId: topicId,
          lessonId: Value(lessonId),
          passageId: Value(passageId),
          language: 'en',
          stemJson: _portableText(stem ?? 'Question $questionId?'),
          explanationJson: _portableText(explanation ?? 'Explanation'),
          isActive: Value(isActive),
          schemaVersion: 1,
          updatedAt: _seedStamp,
        ),
      );
  var ordering = 1;
  for (final choice in choices) {
    await db.into(db.contentChoices).insertOnConflictUpdate(
          ContentChoicesCompanion.insert(
            id: choice['id']! as String,
            questionId: questionId,
            label: choice['label']! as String,
            textValue: choice['text']! as String,
            isCorrect: choice['isCorrect'] == true,
            ordering: ordering++,
            schemaVersion: 1,
            updatedAt: _seedStamp,
          ),
        );
  }
  for (final tag in {if (examId != null) examId, ...examIds}) {
    await db.into(db.contentQuestionExams).insertOnConflictUpdate(
          ContentQuestionExamsCompanion.insert(
            questionId: questionId,
            examId: tag,
          ),
        );
  }
}

String _portableText(String text) => jsonEncode([
      {
        '_type': 'block',
        'style': 'normal',
        'children': [
          {'_type': 'span', 'text': text, 'marks': <String>[]},
        ],
      },
    ]);

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
            stemJson: _portableText('stem $qId'),
            explanationJson: _portableText('explanation $qId'),
            updatedAt: _seedStamp,
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
