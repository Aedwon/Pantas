import 'dart:convert';
import 'package:drift/drift.dart' show Value;

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/features/mock_exam/application/mock_answer_recorder.dart';
import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ContentRepository content;
  late AttemptsRepository attempts;
  late ReviewStateRepository reviews;
  late MockAnswerRecorder recorder;

  final submittedAt = DateTime.utc(2026, 12, 1, 9);

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    content = ContentRepository(contentDb);
    attempts = AttemptsRepository(db);
    reviews = ReviewStateRepository(db);
    recorder = MockAnswerRecorder(
      mocks: MockAttemptRepo(db),
      attempts: attempts,
      reviews: reviews,
      content: content,
      scheduler: const FsrsScheduler(),
    );
    await seedContentExam(contentDb, examId: 'e1', code: 'CSE', name: 'CSE');
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Numerical',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Arithmetic',
    );
    for (final id in ['q1', 'q2', 'q3']) {
      await seedContentQuestion(
        contentDb,
        questionId: id,
        topicId: 't1',
        examId: 'e1',
      );
    }
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  /// The index of the correct or a wrong choice as the mock displays it.
  Future<int> indexOf(String questionId, {required bool correct}) async {
    final question = (await content.questionById(questionId))!;
    return question.choices.indexWhere((c) => c.isCorrect == correct);
  }

  Future<void> insertMock({
    required String id,
    required MockAttemptStatus status,
    required Map<String, int> answers,
    DateTime? submitted,
  }) async {
    final started =
        (submitted ?? submittedAt).subtract(const Duration(hours: 1));
    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: id,
            userId: 'local',
            examId: 'e1',
            blueprintId: 'bp',
            blueprintName: 'Full',
            durationMinutes: 60,
            status: status.value,
            strictMode: false,
            sampledQuestionsJson: jsonEncode([
              {
                'sectionId': 'sec1',
                'name': 'Numerical',
                'questionIds': ['q1', 'q2', 'q3'],
              },
            ]),
            answersJson: Value(
              jsonEncode({
                for (final entry in answers.entries)
                  entry.key: {'selectedIndex': entry.value, 'atSec': 30},
              }),
            ),
            startedAt: started,
            lastFlushedAt: started,
            updatedAt: started,
            submittedAt: Value(submitted),
          ),
        );
  }

  test('a completed mock records answered items as untimed mock answers',
      () async {
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.completed,
      submitted: submittedAt,
      answers: {
        'q1': await indexOf('q1', correct: true),
        'q2': await indexOf('q2', correct: false),
      },
    );

    expect(await recorder.record('m1'), isTrue);

    final attempt = (await attempts.byId('m1'))!;
    expect(attempt.origin, AttemptOrigins.mock);
    expect(attempt.items.map((i) => i.questionId), ['q1', 'q2']);
    expect(attempt.items.every((i) => i.responseMs == 0), isTrue);
    expect(attempt.items.map((i) => i.isCorrect), [true, false]);

    final missed = (await reviews.byQuestionId('q2'))!;
    final right = (await reviews.byQuestionId('q1'))!;
    expect(missed.due.isBefore(right.due), isTrue);
    expect(missed.lastReview, submittedAt);
    expect(await reviews.byQuestionId('q3'), isNull);
  });

  test('recording twice changes nothing the second time', () async {
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.completed,
      submitted: submittedAt,
      answers: {'q2': await indexOf('q2', correct: false)},
    );
    await recorder.record('m1');
    final first = (await reviews.byQuestionId('q2'))!;

    expect(await recorder.record('m1'), isFalse);

    final second = (await reviews.byQuestionId('q2'))!;
    expect(second.reps, first.reps);
    expect(second.due, first.due);
  });

  test('concurrent record calls apply a mock rating once', () async {
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.completed,
      submitted: submittedAt,
      answers: {'q1': await indexOf('q1', correct: true)},
    );

    final results = await Future.wait([
      recorder.record('m1'),
      recorder.record('m1'),
    ]);

    expect(results, unorderedEquals([true, false]));
    expect((await reviews.byQuestionId('q1'))!.reps, 1);
    expect((await attempts.byId('m1'))!.items, hasLength(1));
  });

  test('concurrent record and reconcile apply a mock rating once', () async {
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.completed,
      submitted: submittedAt,
      answers: {'q1': await indexOf('q1', correct: true)},
    );

    final results = await Future.wait([
      recorder.record('m1').then((recorded) => recorded ? 1 : 0),
      recorder.reconcile('e1'),
    ]);

    expect(results, unorderedEquals([1, 0]));
    expect((await reviews.byQuestionId('q1'))!.reps, 1);
  });

  test('reconciling a September 1 miss preserves a September 30 review',
      () async {
    final lastReview = DateTime.utc(2026, 9, 30, 9);
    await reviews.upsert(
      ReviewState(
        questionId: 'q2',
        questionVersion: 1,
        stage: ReviewStage.review,
        stability: 10,
        difficulty: 5,
        due: DateTime.utc(2026, 10, 10, 9),
        lastReview: lastReview,
        reps: 3,
        lapses: 1,
        elapsedDays: 10,
        scheduledDays: 10,
      ),
    );
    final before = (await reviews.byQuestionId('q2'))!;
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.completed,
      submitted: DateTime.utc(2026, 9, 1, 9),
      answers: {'q2': await indexOf('q2', correct: false)},
    );

    expect(await recorder.reconcile('e1'), 1);

    expect(await reviews.byQuestionId('q2'), before);
    final attempt = (await attempts.byId('m1'))!;
    expect(attempt.items.single.questionId, 'q2');
    expect(attempt.items.single.isCorrect, isFalse);
    expect(attempt.completedAt, DateTime.utc(2026, 9, 1, 9));
  });

  test('a forfeited mock records the answers given', () async {
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.forfeited,
      submitted: submittedAt,
      answers: {'q1': await indexOf('q1', correct: true)},
    );

    expect(await recorder.record('m1'), isTrue);
    expect((await attempts.byId('m1'))!.items, hasLength(1));
  });

  test('a discarded or unsubmitted mock records nothing', () async {
    await insertMock(
      id: 'discarded',
      status: MockAttemptStatus.discarded,
      submitted: submittedAt,
      answers: {'q1': 0},
    );
    await insertMock(
      id: 'open',
      status: MockAttemptStatus.inProgress,
      answers: {'q1': 0},
    );

    expect(await recorder.record('discarded'), isFalse);
    expect(await recorder.record('open'), isFalse);
    expect(await attempts.byId('discarded'), isNull);
    expect(await reviews.byQuestionId('q1'), isNull);
  });

  test('an out-of-range answer or retired question is skipped', () async {
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.completed,
      submitted: submittedAt,
      answers: {'q1': 99, 'q_retired': 0},
    );

    expect(await recorder.record('m1'), isTrue);
    expect((await attempts.byId('m1'))!.items, isEmpty);
    expect(await reviews.byQuestionId('q1'), isNull);
  });

  test('reconcile records every submitted mock not yet recorded', () async {
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.completed,
      submitted: submittedAt,
      answers: {'q1': await indexOf('q1', correct: true)},
    );
    await insertMock(
      id: 'm2',
      status: MockAttemptStatus.forfeited,
      submitted: submittedAt,
      answers: {'q2': await indexOf('q2', correct: false)},
    );
    await recorder.record('m1');

    expect(await recorder.reconcile('e1'), 1);
    expect(await attempts.byId('m2'), isNotNull);
    expect(await recorder.reconcile('e1'), 0);
  });

  test('an existing review state is advanced, not replaced', () async {
    await reviews.upsert(
      ReviewState.seed(questionId: 'q1', questionVersion: 1, now: submittedAt),
    );
    final before = (await reviews.byQuestionId('q1'))!;
    await insertMock(
      id: 'm1',
      status: MockAttemptStatus.completed,
      submitted: submittedAt,
      answers: {'q1': await indexOf('q1', correct: true)},
    );

    await recorder.record('m1');

    expect((await reviews.byQuestionId('q1'))!.reps, before.reps + 1);
  });
}
