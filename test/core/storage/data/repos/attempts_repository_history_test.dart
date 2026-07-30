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

  AttemptItem item(
    String questionId, {
    required bool correct,
    int responseMs = 1200,
  }) =>
      AttemptItem(
        questionId: questionId,
        questionVersion: 1,
        chosenChoiceId: correct ? 'c_a' : 'c_b',
        correctChoiceId: 'c_a',
        responseMs: responseMs,
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

  test('the topic average is over that topic only', () async {
    final topicOf = {
      'q_1': 'topic_algebra',
      'q_2': 'topic_algebra',
      'q_3': 'topic_geometry',
    };
    await save('a_1', DateTime.utc(2026, 8), [
      item('q_1', correct: true, responseMs: 20000),
      item('q_2', correct: true, responseMs: 40000),
      item('q_3', correct: true, responseMs: 5000),
    ]);

    final averages = await repo.averageResponseMsByTopic(
      examId: 'exam_cse_pro',
      topicOf: topicOf,
      now: DateTime.utc(2026, 8, 2),
    );

    expect(averages['topic_algebra'], 30000);
    expect(averages['topic_geometry'], 5000);
  });

  test('a topic with no answers is absent rather than zero', () async {
    final topicOf = {
      'q_1': 'topic_algebra',
      'q_2': 'topic_geometry',
    };
    await save('a_1', DateTime.utc(2026, 8), [
      item('q_1', correct: true, responseMs: 20000),
    ]);

    final averages = await repo.averageResponseMsByTopic(
      examId: 'exam_cse_pro',
      topicOf: topicOf,
      now: DateTime.utc(2026, 8, 2),
    );

    expect(averages.containsKey('topic_algebra'), isTrue);
    expect(averages.containsKey('topic_geometry'), isFalse);
  });

  test('a prior correct answer comes back with its date', () async {
    final july14 = DateTime.utc(2026, 7, 14);
    final august2 = DateTime.utc(2026, 8, 2);

    await save('a_jul', july14, [item('q_1', correct: true)]);
    await save('a_aug', august2, [item('q_1', correct: false)]);

    final lastCorrect = await repo.lastCorrectAt(
      examId: 'exam_cse_pro',
      questionId: 'q_1',
      before: august2,
    );

    expect(lastCorrect, july14);
  });

  test('a prior wrong answer is not a prior correct one', () async {
    final july14 = DateTime.utc(2026, 7, 14);
    final august2 = DateTime.utc(2026, 8, 2);

    await save('a_jul', july14, [item('q_1', correct: false)]);

    final lastCorrect = await repo.lastCorrectAt(
      examId: 'exam_cse_pro',
      questionId: 'q_1',
      before: august2,
    );

    expect(lastCorrect, isNull);
  });

  test('the current attempt cannot count as its own history', () async {
    final thatMoment = DateTime.utc(2026, 8, 2, 10);

    await save('a_now', thatMoment, [item('q_1', correct: true)]);

    final lastCorrect = await repo.lastCorrectAt(
      examId: 'exam_cse_pro',
      questionId: 'q_1',
      before: thatMoment,
    );

    expect(lastCorrect, isNull);
  });
}
