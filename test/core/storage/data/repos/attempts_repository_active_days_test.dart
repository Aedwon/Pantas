import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AttemptsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = AttemptsRepository(db);
  });
  tearDown(() => db.close());

  Future<void> save(
    String id,
    DateTime startedAt,
    int answers, {
    String examId = 'exam_upcat',
    String origin = 'today_topic',
  }) =>
      repo.save(
        Attempt(
          id: id,
          examId: examId,
          startedAt: startedAt,
          completedAt: startedAt,
          origin: origin,
          items: [
            for (var i = 0; i < answers; i++)
              AttemptItem(
                questionId: '${id}_$i',
                questionVersion: 1,
                chosenChoiceId: 'a',
                correctChoiceId: 'a',
                responseMs: 1000,
              ),
          ],
        ),
      );

  test('answers are summed per local day, newest first, active days only',
      () async {
    await save('a', DateTime(2026, 9, 28, 8), 10);
    await save('b', DateTime(2026, 9, 28, 20), 5);
    await save('c', DateTime(2026, 9, 25, 9), 12);
    await save('empty', DateTime(2026, 9, 26, 9), 0);
    await save('other', DateTime(2026, 9, 27, 9), 30, examId: 'exam_cse');

    expect(await repo.answeredPerActiveDay(examId: 'exam_upcat'), [15, 12]);
  });

  test('only the most recent active days are returned', () async {
    for (var day = 1; day <= 9; day++) {
      await save('d$day', DateTime(2026, 9, day, 9), day);
    }
    expect(
      await repo.answeredPerActiveDay(examId: 'exam_upcat'),
      [9, 8, 7, 6, 5, 4, 3],
    );
  });

  test('recorded mocks are counted by origin', () async {
    await save('m1', DateTime(2026, 9, 28), 3, origin: 'mock');
    await save('m2', DateTime(2026, 9, 29), 3, origin: 'mock');
    await save('p', DateTime(2026, 9, 29), 3);
    await save('x', DateTime(2026, 9, 29), 3, origin: 'mock', examId: 'e2');

    expect(
      await repo.countForOrigin(examId: 'exam_upcat', origin: 'mock'),
      2,
    );
  });
}
