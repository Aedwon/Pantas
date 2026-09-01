import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/mapping/custom_blueprint_mapper.dart';
import 'package:pantas/core/sync/mapping/review_log_mapper.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  Future<int> journalCount(AppDatabase db) async => (await db
          .customSelect('select count(*) as c from sync_local_mutations')
          .getSingle())
      .read<int>('c');

  test('remote review-log apply and tombstone never journal locally', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    const mapper = ReviewLogMapper();
    final serverAt = DateTime.utc(2026, 8, 30, 3);
    final row = ReviewLogRow(
      id: 'review-remote',
      questionId: 'q-1',
      rating: 4,
      state: 2,
      due: serverAt,
      stability: 2,
      difficulty: 5,
      elapsedDays: 1,
      lastElapsedDays: 1,
      scheduledDays: 2,
      review: serverAt,
      durationMs: 700,
      isCorrect: true,
      heuristicVersion: 1,
    );
    final payload = mapper.toFirestore(
      row,
      updatedAt: serverAt,
      originDeviceId: 'remote-device',
    );
    final adapter = syncCollections
        .singleWhere((entry) => entry.tableType == 'review_logs')
        .adapter;

    await adapter.applyRemote(
      db: db,
      rowId: row.id,
      payload: payload,
      deleted: false,
      updatedAt: serverAt,
      originDeviceId: 'remote-device',
    );

    expect(await db.select(db.reviewLogs).get(), hasLength(1));
    expect(await journalCount(db), 0);
    final base = await SyncRowMetaRepository(db).readAcceptedBase(
      collection: 'review_logs',
      rowId: row.id,
    );
    expect(base?.state, SyncCausalBaseState.knownVersion);
    expect(base?.updatedAt, serverAt);

    final tombstoneAt = serverAt.add(const Duration(minutes: 1));
    await adapter.applyRemote(
      db: db,
      rowId: row.id,
      payload: null,
      deleted: true,
      updatedAt: tombstoneAt,
      originDeviceId: 'remote-device',
    );

    expect(await db.select(db.reviewLogs).get(), isEmpty);
    expect(await journalCount(db), 0);
    expect(
      (await SyncRowMetaRepository(db).readAcceptedBase(
        collection: 'review_logs',
        rowId: row.id,
      ))
          ?.updatedAt,
      tombstoneAt,
    );
  });

  test('remote typed track_scope applies metadata and scope without feedback',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'exam_custom_remote',
      topicId: 'topic:math/a.b',
      topicName: 'Math',
      questionIds: const [],
    );
    const mapper = TrackScopeMapper();
    final serverAt = DateTime.utc(2026, 8, 30, 4);
    const meta = CustomTrackMetaLocalRow(
      examId: 'exam_custom_remote',
      name: 'Remote Track',
    );
    const scope = TrackScopeExclusionRow(
      examId: 'exam_custom_remote',
      topicId: 'topic:math/a.b',
    );
    final adapter = syncCollections
        .singleWhere((entry) => entry.tableType == 'track_scope')
        .adapter;

    await adapter.applyRemote(
      db: db,
      rowId: mapper.metadataDocumentId(meta),
      payload: mapper.metadataToFirestore(
        meta,
        updatedAt: serverAt,
        originDeviceId: 'remote-device',
      ),
      deleted: false,
      updatedAt: serverAt,
      originDeviceId: 'remote-device',
    );
    await adapter.applyRemote(
      db: db,
      rowId: mapper.scopeDocumentId(scope),
      payload: mapper.scopeToFirestore(
        scope,
        updatedAt: serverAt,
        originDeviceId: 'remote-device',
      ),
      deleted: false,
      updatedAt: serverAt,
      originDeviceId: 'remote-device',
    );

    expect(
      (await db.select(db.customTrackMetaLocal).get()).single.name,
      'Remote Track',
    );
    expect(
      (await db.select(db.trackScopeLocal).get()).single.topicId,
      'topic:math/a.b',
    );
    expect(await journalCount(db), 0);
  });

  test('remote custom blueprint apply and tombstone bypass the recorder',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'exam_custom_bp',
      topicId: 'topic-1',
      topicName: 'Topic',
      questionIds: const [],
    );
    const mapper = CustomBlueprintMapper();
    final serverAt = DateTime.utc(2026, 8, 30, 5);
    final row = CustomBlueprintRow(
      examId: 'exam_custom_bp',
      totalQuestions: 40,
      totalMinutes: 50,
      sectionsJson: '[]',
      sectionsTimedSeparately: false,
      updatedAt: DateTime.utc(2026, 8, 29),
    );
    final adapter = syncCollections
        .singleWhere((entry) => entry.tableType == 'custom_blueprints')
        .adapter;

    await adapter.applyRemote(
      db: db,
      rowId: row.examId,
      payload: mapper.toFirestore(
        row,
        updatedAt: serverAt,
        originDeviceId: 'remote-device',
      ),
      deleted: false,
      updatedAt: serverAt,
      originDeviceId: 'remote-device',
    );
    expect(await db.select(db.customBlueprintsLocal).get(), hasLength(1));
    expect(await journalCount(db), 0);

    await adapter.applyRemote(
      db: db,
      rowId: row.examId,
      payload: null,
      deleted: true,
      updatedAt: serverAt.add(const Duration(minutes: 1)),
      originDeviceId: 'remote-device',
    );
    expect(await db.select(db.customBlueprintsLocal).get(), isEmpty);
    expect(await journalCount(db), 0);
  });
}
