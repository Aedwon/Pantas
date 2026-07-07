import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/question_flags_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/practice_row_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  AttemptItem item(String questionId, {required bool correct}) => AttemptItem(
        questionId: questionId,
        questionVersion: 1,
        chosenChoiceId: correct ? 'c_a' : 'c_b',
        correctChoiceId: 'c_a',
        responseMs: 1200,
      );

  test('no attempts means nothing to fix', () async {
    expect(
      await container.read(recentMistakeCountProvider('exam_cse_pro').future),
      0,
    );
  });

  test('wrong answers inside the month are counted once each', () async {
    await AttemptsRepository(db).save(
      Attempt(
        id: 'a_1',
        examId: 'exam_cse_pro',
        startedAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now(),
        items: [
          item('q_1', correct: false),
          item('q_1', correct: false),
          item('q_2', correct: false),
          item('q_3', correct: true),
        ],
      ),
    );

    expect(
      await container.read(recentMistakeCountProvider('exam_cse_pro').future),
      2,
    );
  });

  test('the flag count starts at zero', () async {
    expect(await container.read(flagCountProvider.future), 0);
  });

  test('flags are counted', () async {
    await QuestionFlagsRepository(db).flag('q_1');
    await QuestionFlagsRepository(db).flag('q_2');

    expect(await container.read(flagCountProvider.future), 2);
  });
}
