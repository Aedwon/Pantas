import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AttemptsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = AttemptsRepository(db);
  });
  tearDown(() => db.close());

  AttemptItem item(String questionId, {required bool correct}) => AttemptItem(
        questionId: questionId,
        questionVersion: 1,
        chosenChoiceId: correct ? 'c_a' : 'c_b',
        correctChoiceId: 'c_a',
        responseMs: 1200,
      );

  Future<void> save(
    String id,
    DateTime startedAt,
    List<AttemptItem> items, {
    String examId = 'exam_cse_pro',
  }) =>
      repo.save(
        Attempt(
          id: id,
          examId: examId,
          startedAt: startedAt,
          completedAt: startedAt,
          items: items,
        ),
      );

  test('questionOutcomes counts attempts and corrects per question', () async {
    await save('a_1', DateTime.utc(2026, 8, 1), [
      item('q_1', correct: true),
      item('q_2', correct: false),
    ]);
    await save('a_2', DateTime.utc(2026, 8, 2), [
      item('q_1', correct: false),
    ]);

    final outcomes = await repo.questionOutcomes(
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 8, 3),
    );

    expect(outcomes['q_1']!.attempts, 2);
    expect(outcomes['q_1']!.correct, 1);
    expect(outcomes['q_2']!.attempts, 1);
    expect(outcomes['q_2']!.correct, 0);
  });

  test('questionOutcomes ignores attempts older than the window', () async {
    await save('a_old', DateTime.utc(2026, 6, 1), [item('q_1', correct: true)]);

    final outcomes = await repo.questionOutcomes(
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 8, 3),
      window: const Duration(days: 30),
    );

    expect(outcomes, isEmpty);
  });

  test('questionOutcomes ignores other exams', () async {
    await save(
      'a_1',
      DateTime.utc(2026, 8, 1),
      [item('q_1', correct: true)],
      examId: 'exam_upcat',
    );

    final outcomes = await repo.questionOutcomes(
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 8, 3),
    );

    expect(outcomes, isEmpty);
  });

  test('tallyForDay counts only that local day', () async {
    await save('a_today', DateTime(2026, 8, 2, 9), [
      item('q_1', correct: true),
      item('q_2', correct: false),
    ]);
    await save('a_yesterday', DateTime(2026, 8, 1, 9), [
      item('q_3', correct: true),
    ]);

    final tally = await repo.tallyForDay(
      examId: 'exam_cse_pro',
      day: DateTime(2026, 8, 2, 21),
    );

    expect(tally.answered, 2);
    expect(tally.correct, 1);
  });

  test('tallyForDay is empty when nothing was answered', () async {
    final tally = await repo.tallyForDay(
      examId: 'exam_cse_pro',
      day: DateTime(2026, 8, 2),
    );

    expect(tally.answered, 0);
    expect(tally.correct, 0);
  });
}
