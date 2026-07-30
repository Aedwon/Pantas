import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
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

  AttemptItem item(String questionId, {int responseMs = 30000}) => AttemptItem(
        questionId: questionId,
        questionVersion: 1,
        chosenChoiceId: 'c_a',
        correctChoiceId: 'c_a',
        responseMs: responseMs,
      );

  Future<void> save(
    String id, {
    required List<AttemptItem> items,
    DateTime? startedAt,
    bool completed = true,
  }) {
    final began = startedAt ?? DateTime.utc(2026, 8);
    return repo.save(
      Attempt(
        id: id,
        examId: 'exam_cse_pro',
        startedAt: began,
        completedAt: completed ? began : null,
        items: items,
      ),
    );
  }

  test('the pace is withheld below seven completed attempts', () async {
    for (var i = 0; i < 6; i++) {
      await save('a_$i', items: [item('q_$i')]);
    }

    expect(
      await repo.averageResponseMs(examId: 'exam_cse_pro'),
      isNull,
    );
  });

  test('the pace averages every answer once seven attempts exist', () async {
    for (var i = 0; i < 7; i++) {
      await save('a_$i', items: [item('q_$i', responseMs: 40000)]);
    }

    expect(
      await repo.averageResponseMs(examId: 'exam_cse_pro'),
      40000,
    );
  });

  test('unfinished attempts do not count toward the pace', () async {
    for (var i = 0; i < 6; i++) {
      await save('a_$i', items: [item('q_$i')]);
    }
    await save('a_open', items: [item('q_open')], completed: false);

    expect(
      await repo.averageResponseMs(examId: 'exam_cse_pro'),
      isNull,
    );
  });

  test('questions answered inside the window come back', () async {
    await save(
      'a_recent',
      items: [item('q_1'), item('q_2')],
      startedAt: DateTime.utc(2026, 8),
    );

    final ids = await repo.questionIdsAnsweredSince(
      examId: 'exam_cse_pro',
      since: DateTime.utc(2026, 7, 28),
    );

    expect(ids, equals({'q_1', 'q_2'}));
  });

  test('questions answered before the window do not', () async {
    await save(
      'a_old',
      items: [item('q_1')],
      startedAt: DateTime.utc(2026, 7),
    );

    final ids = await repo.questionIdsAnsweredSince(
      examId: 'exam_cse_pro',
      since: DateTime.utc(2026, 7, 28),
    );

    expect(ids, isEmpty);
  });
}
