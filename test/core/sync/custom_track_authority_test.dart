import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late CustomTrackRepository repo;

  Future<void> seedCorpus() async {
    await seedContentExam(contentDb, examId: 'exam_upcat', code: 'UPCAT');
    await seedContentSubject(
      contentDb,
      subjectId: 'math',
      examId: 'exam_upcat',
      name: 'Math',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'science',
      examId: 'exam_upcat',
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'algebra',
      subjectId: 'math',
      name: 'Algebra',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'chem',
      subjectId: 'science',
      name: 'Chemistry',
    );
  }

  Future<Map<String, Object?>?> journal(String rowId) async =>
      (await db.customSelect(
        'select row_id,op,revision,mutation_epoch from sync_local_mutations '
        "where collection = 'track_scope' and row_id = ?",
        variables: [Variable<String>(rowId)],
      ).getSingleOrNull())
          ?.data;

  Future<int> epoch() async {
    final row = await db
        .customSelect(
          "select value from sync_meta where key = 'localMutationEpoch'",
        )
        .getSingleOrNull();
    return row == null ? 0 : int.parse(row.read<String>('value'));
  }

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    repo = CustomTrackRepository(db, contentDb);
    await seedCorpus();
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test('create commits metadata scope journal and projection before returning',
      () async {
    final examId = await repo.create(
      name: 'Math only',
      includedTopicIds: {'algebra'},
    );

    final meta = await (db.select(db.customTrackMetaLocal)
          ..where((row) => row.examId.equals(examId)))
        .getSingle();
    expect(meta.name, 'Math only');
    expect(await repo.excludedTopicIds(examId), {'chem'});

    final metaJournal = await journal(TrackScopeDocumentId.metadata(examId));
    final scopeJournal =
        await journal(TrackScopeDocumentId.scope(examId, 'chem'));
    expect(metaJournal?['op'], 'upsert');
    expect(scopeJournal?['op'], 'upsert');
    expect(await epoch(), 2);
    expect(await repo.projectionRequired(examId), isFalse);

    final projected = await (contentDb.select(contentDb.contentExams)
          ..where((row) => row.id.equals(examId)))
        .getSingle();
    expect(projected.name, 'Math only');
    expect(projected.isCustom, isTrue);
  });

  test('rename updates authoritative metadata and its typed journal row',
      () async {
    final examId = await repo.create(name: 'Old', includedTopicIds: {});

    await repo.rename(examId: examId, name: 'New');

    final meta = await (db.select(db.customTrackMetaLocal)
          ..where((row) => row.examId.equals(examId)))
        .getSingle();
    expect(meta.name, 'New');
    final mutation = await journal(TrackScopeDocumentId.metadata(examId));
    expect(mutation?['op'], 'upsert');
    expect(mutation?['revision'], 2);
    final projected = await (contentDb.select(contentDb.contentExams)
          ..where((row) => row.id.equals(examId)))
        .getSingle();
    expect(projected.name, 'New');
  });

  test('setExcluded journals only added and removed typed scope rows',
      () async {
    final examId = await repo.create(
      name: 'All',
      includedTopicIds: {'algebra', 'chem'},
    );

    await repo.setExcluded(examId: examId, topicIds: {'chem'});
    final chemId = TrackScopeDocumentId.scope(examId, 'chem');
    final algebraId = TrackScopeDocumentId.scope(examId, 'algebra');
    expect((await journal(chemId))?['op'], 'upsert');
    expect((await journal(chemId))?['revision'], 1);
    expect(await journal(algebraId), isNull);

    await repo.setExcluded(examId: examId, topicIds: {'algebra'});
    expect((await journal(chemId))?['op'], 'delete');
    expect((await journal(chemId))?['revision'], 2);
    expect((await journal(algebraId))?['op'], 'upsert');
    expect((await journal(algebraId))?['revision'], 1);
    expect(await repo.excludedTopicIds(examId), {'algebra'});
  });

  test('delete journals metadata and scope deletes before authority disappears',
      () async {
    final examId = await repo.create(
      name: 'Delete me',
      includedTopicIds: {'algebra'},
    );
    final metaId = TrackScopeDocumentId.metadata(examId);
    final scopeId = TrackScopeDocumentId.scope(examId, 'chem');

    await repo.delete(examId);

    expect(
      await (db.select(db.customTrackMetaLocal)
            ..where((row) => row.examId.equals(examId)))
          .getSingleOrNull(),
      isNull,
    );
    expect(await repo.excludedTopicIds(examId), isEmpty);
    expect((await journal(metaId))?['op'], 'delete');
    expect((await journal(metaId))?['revision'], 2);
    expect((await journal(scopeId))?['op'], 'delete');
    expect((await journal(scopeId))?['revision'], 2);
    expect(await repo.projectionRequired(examId), isFalse);
    expect(
      await (contentDb.select(contentDb.contentExams)
            ..where((row) => row.id.equals(examId)))
          .getSingleOrNull(),
      isNull,
    );
  });

  test('journal failure rolls back the whole multi-row authority action',
      () async {
    final examId = await repo.create(
      name: 'Atomic',
      includedTopicIds: {'algebra', 'chem'},
    );
    final beforeEpoch = await epoch();
    await db.customStatement(
      'create trigger fail_track_scope_journal before insert on '
      'sync_local_mutations '
      "when new.collection = 'track_scope' and new.row_id like 'scope.%' "
      "begin select raise(abort, 'forced journal failure'); end",
    );

    await expectLater(
      repo.setExcluded(examId: examId, topicIds: {'chem'}),
      throwsA(anything),
    );

    expect(await repo.excludedTopicIds(examId), isEmpty);
    expect(await repo.projectionRequired(examId), isFalse);
    expect(await epoch(), beforeEpoch);
  });
}
