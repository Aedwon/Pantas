import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/signals/subject_affinity_signal.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    contentDb = ContentDatabase(NativeDatabase.memory());
    await seedContentSubject(
      contentDb,
      subjectId: 'sub_sci',
      examId: 'exam_cse',
      name: 'Science',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sub_math',
      examId: 'exam_cse',
      name: 'Maths',
      ordering: 2,
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top_sci',
      subjectId: 'sub_sci',
      name: 'Physics',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top_math',
      subjectId: 'sub_math',
      name: 'Algebra',
    );
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  Future<void> seedQuestion(String id, String topicId) async {
    await seedContentQuestionWithChoices(
      contentDb,
      questionId: id,
      topicId: topicId,
      examId: 'exam_cse',
      choices: [
        {'id': 'a', 'label': 'A', 'text': 'A', 'isCorrect': true},
        {'id': 'b', 'label': 'B', 'text': 'B', 'isCorrect': false},
      ],
      stem: 'Stem $id',
      explanation: '',
    );
  }

  Future<void> insertAttempt({
    required String id,
    required String origin,
    required String subject,
    required int correct,
    required int wrong,
    required int responseMsPerItem,
  }) async {
    final topicId = subject == 'Science' ? 'top_sci' : 'top_math';
    final items = <Map<String, dynamic>>[];
    for (var i = 0; i < correct; i++) {
      final qId = 'q_${id}_c_$i';
      await seedQuestion(qId, topicId);
      items.add({
        'questionId': qId,
        'questionVersion': 1,
        'chosenChoiceId': 'a',
        'correctChoiceId': 'a',
        'responseMs': responseMsPerItem,
      });
    }
    for (var i = 0; i < wrong; i++) {
      final qId = 'q_${id}_w_$i';
      await seedQuestion(qId, topicId);
      items.add({
        'questionId': qId,
        'questionVersion': 1,
        'chosenChoiceId': 'b',
        'correctChoiceId': 'a',
        'responseMs': responseMsPerItem,
      });
    }
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: id,
            examId: 'exam_cse',
            startedAt: DateTime.utc(2026, 6),
            completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
            origin: Value(origin),
            itemsJson: jsonEncode(items),
          ),
        );
  }

  ResolvedMetricsWindow window() => ResolvedMetricsWindow(
        window: MetricsWindow.rolling30d,
        start: DateTime.utc(2026, 5, 11),
        end: DateTime.utc(2026, 6, 10),
        sessionCount: 7,
        minSessionCount: 7,
      );

  test('an assessment row counts for accuracy', () async {
    await insertAttempt(
      id: 'a1',
      origin: 'assessment',
      subject: 'Science',
      correct: 1,
      wrong: 2,
      responseMsPerItem: 0,
    );

    final result = await SubjectAffinitySignal(db, contentDb).compute(
      window: window(),
      examId: 'exam_cse',
    );
    final row = result!.subjects['Science']!;
    expect(row.correct, 1);
    expect(row.total, 3);
  });

  test('an assessment row does not count for speed', () async {
    await insertAttempt(
      id: 'a1',
      origin: 'assessment',
      subject: 'Science',
      correct: 3,
      wrong: 0,
      responseMsPerItem: 0,
    );
    await insertAttempt(
      id: 'a2',
      origin: 'today_topic',
      subject: 'Science',
      correct: 1,
      wrong: 0,
      responseMsPerItem: 6000,
    );

    final result = await SubjectAffinitySignal(db, contentDb).compute(
      window: window(),
      examId: 'exam_cse',
    );
    final row = result!.subjects['Science']!;
    expect(row.total, 4, reason: 'all four count for accuracy');
    expect(
      row.averageMs,
      6000,
      reason: 'only the one timed item divides into the total',
    );
  });

  test('a subject with only untimed items reports zero milliseconds', () async {
    await insertAttempt(
      id: 'a1',
      origin: 'assessment',
      subject: 'Maths',
      correct: 2,
      wrong: 1,
      responseMsPerItem: 0,
    );

    final result = await SubjectAffinitySignal(db, contentDb).compute(
      window: window(),
      examId: 'exam_cse',
    );
    final row = result!.subjects['Maths']!;
    expect(row.total, 3);
    expect(row.averageMs, 0, reason: 'never a divide by zero');
  });
}
