import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('concurrent notes preserve different question updates', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AttemptsRepository(db);
    await repo.save(
      Attempt(
        id: 'a',
        examId: 'e',
        startedAt: DateTime.utc(2026),
        items: [
          for (final id in ['q1', 'q2'])
            AttemptItem(
              questionId: id,
              questionVersion: 1,
              chosenChoiceId: 'b',
              correctChoiceId: 'a',
              responseMs: 1,
            ),
        ],
      ),
    );
    await Future.wait([
      repo.tagItem(attemptId: 'a', questionId: 'q1', tag: MistakeTag.misread),
      repo.tagItem(attemptId: 'a', questionId: 'q2', tag: MistakeTag.slipped),
    ]);
    final attempt = (await repo.byId('a'))!;
    expect(attempt.items[0].mistakeTag, MistakeTag.misread);
    expect(attempt.items[1].mistakeTag, MistakeTag.slipped);
  });
  test('note replacement and removal preserve omitted legacy notes', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AttemptsRepository(db);
    final attempt = Attempt(
      id: 'a',
      examId: 'e',
      startedAt: DateTime.utc(2026),
      completedAt: DateTime.utc(2026, 1, 2),
      items: const [
        AttemptItem(
          questionId: 'q',
          questionVersion: 1,
          chosenChoiceId: 'b',
          correctChoiceId: 'a',
          responseMs: 12,
        ),
      ],
    );
    await repo.save(attempt);
    await repo.tagItem(
      attemptId: 'a',
      questionId: 'q',
      tag: MistakeTag.other,
      note: 'Check the units',
      replaceNote: true,
    );
    await repo.tagItem(
      attemptId: 'a',
      questionId: 'q',
      tag: MistakeTag.misread,
    );
    expect((await repo.byId('a'))!.items.single.mistakeNote, 'Check the units');
    await repo.tagItem(
      attemptId: 'a',
      questionId: 'q',
      tag: null,
      replaceNote: true,
    );
    expect((await repo.byId('a'))!.items.single.mistakeNote, isNull);
    expect((await repo.byId('a'))!.completedAt, attempt.completedAt);
  });

  test('expired guard after write rolls back note and sync revision', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AttemptsRepository(db);
    await repo.save(
      Attempt(
        id: 'a',
        examId: 'e',
        startedAt: DateTime.utc(2026),
        items: const [
          AttemptItem(
            questionId: 'q',
            questionVersion: 1,
            chosenChoiceId: 'b',
            correctChoiceId: 'a',
            responseMs: 12,
          ),
        ],
      ),
    );
    final before = await db
        .customSelect('select revision from sync_local_mutations')
        .getSingle();
    var checks = 0;
    await expectLater(
      repo.tagItem(
        attemptId: 'a',
        questionId: 'q',
        tag: MistakeTag.other,
        note: 'must roll back',
        replaceNote: true,
        canPersist: () async => ++checks < 3,
      ),
      throwsStateError,
    );
    expect((await repo.byId('a'))!.items.single.mistakeTag, isNull);
    expect((await repo.byId('a'))!.items.single.mistakeNote, isNull);
    final after = await db
        .customSelect('select revision from sync_local_mutations')
        .getSingle();
    expect(after.read<int>('revision'), before.read<int>('revision'));
  });

  test('missing attempt or foreign question never creates progress', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AttemptsRepository(db);
    await expectLater(
      repo.tagItem(
        attemptId: 'missing',
        questionId: 'q',
        tag: MistakeTag.other,
      ),
      throwsStateError,
    );
    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    expect(
      await db.customSelect('select * from sync_local_mutations').get(),
      isEmpty,
    );
    await repo.save(
      Attempt(
        id: 'a',
        examId: 'e',
        startedAt: DateTime.utc(2026),
        items: const [],
      ),
    );
    final before = await repo.byId('a');
    final revision = (await db
            .customSelect('select revision from sync_local_mutations')
            .getSingle())
        .read<int>('revision');
    await expectLater(
      repo.tagItem(
        attemptId: 'a',
        questionId: 'foreign',
        tag: MistakeTag.other,
      ),
      throwsStateError,
    );
    expect(await repo.byId('a'), before);
    expect(
      (await db
              .customSelect('select revision from sync_local_mutations')
              .getSingle())
          .read<int>('revision'),
      revision,
    );
    expect(
      (await db.customSelect('select * from sync_local_mutations').get())
          .length,
      1,
    );
  });
  test('ownership invalidation in recorder tail rolls back completed mutation',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AttemptsRepository(db);
    await repo.save(
      Attempt(
        id: 'a',
        examId: 'e',
        startedAt: DateTime.utc(2026),
        items: const [
          AttemptItem(
            questionId: 'q',
            questionVersion: 1,
            chosenChoiceId: 'b',
            correctChoiceId: 'a',
            responseMs: 1,
          ),
        ],
      ),
    );
    final before = (await db
            .customSelect('select revision from sync_local_mutations')
            .getSingle())
        .read<int>('revision');
    var current = true;
    final guarded = AttemptsRepository(
      db,
      syncRecorder: _TailRecorder(db, () => current = false),
    );
    await expectLater(
      guarded.tagItem(
        attemptId: 'a',
        questionId: 'q',
        tag: MistakeTag.other,
        note: 'stale',
        replaceNote: true,
        canPersist: () => current,
      ),
      throwsStateError,
    );
    expect((await repo.byId('a'))!.items.single.mistakeNote, isNull);
    expect(
      (await db
              .customSelect('select revision from sync_local_mutations')
              .getSingle())
          .read<int>('revision'),
      before,
    );
  });
}

class _TailRecorder extends LocalSyncMutationRecorder {
  _TailRecorder(super.db, this.onRecorded)
      : super(
          activeContextStore: SyncActiveContextStore(db),
          rowMetaRepository: SyncRowMetaRepository(db),
        );
  final void Function() onRecorded;
  @override
  Future<T> runRecorded<T>({
    required String collection,
    required String rowId,
    required SyncLocalMutationOp op,
    required FutureOr<T> Function() mutate,
  }) async {
    final result = await super.runRecorded<T>(
      collection: collection,
      rowId: rowId,
      op: op,
      mutate: mutate,
    );
    onRecorded();
    return result;
  }
}
