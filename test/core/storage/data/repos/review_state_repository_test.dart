import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ReviewStateRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = ReviewStateRepository(db);
  });
  tearDown(() => db.close());

  test('upsert + byQuestionId round-trip preserves all FSRS fields', () async {
    final now = DateTime.utc(2026, 5, 9);
    final state =
        ReviewState.seed(questionId: 'q_1', questionVersion: 1, now: now)
            .copyWith(
      stage: ReviewStage.review,
      stability: 5.5,
      difficulty: 3.2,
      reps: 2,
    );
    await repo.upsert(state);
    final read = await repo.byQuestionId('q_1');
    expect(read, equals(state));
  });

  test('dirtyStates returns only rows with dirty=true', () async {
    final now = DateTime.utc(2026, 5, 9);
    await repo.upsert(
      ReviewState.seed(questionId: 'q_1', questionVersion: 1, now: now),
    );
    await repo.upsert(
      ReviewState.seed(questionId: 'q_2', questionVersion: 1, now: now),
    );
    await repo.markClean('q_1');
    final dirty = await repo.dirtyStates();
    expect(dirty.map((s) => s.questionId).toList(), equals(['q_2']));
  });

  ReviewState state(String id) => ReviewState.seed(
      questionId: id, questionVersion: 1, now: DateTime.utc(2026, 5, 9));

  test('allStates returns every stored state', () async {
    await repo.upsert(state('q_1'));
    await repo.upsert(state('q_2'));

    final states = await repo.allStates();

    expect(states.map((s) => s.questionId), unorderedEquals(['q_1', 'q_2']));
  });

  test('allStates is empty on a fresh database', () async {
    expect(await repo.allStates(), isEmpty);
  });
}
