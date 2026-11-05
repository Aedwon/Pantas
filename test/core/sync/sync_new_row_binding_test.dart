import 'dart:async';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:pantas/core/sync/bootstrap/full_pull.dart';
import 'package:pantas/core/sync/bootstrap/full_push.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/engine/generation_repository.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_held_generation.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/sync/runtime/production_sync_runtime_engine.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';
import 'package:pantas/core/sync/sync_coordinator.dart';
import 'package:pantas/core/sync/sync_status.dart';

import '../../helpers/in_memory_database.dart';

const _uid = 'user-1';
const _generation = 'gen-1';

String _path(String collection, [String? rowId]) =>
    'users/$_uid/sync_generations/$_generation/$collection'
    '${rowId == null ? '' : '/$rowId'}';

/// A cloud with live listeners. Rows written through the outbox stay in
/// `documents`; a test delivers a snapshot when it wants one to arrive.
class _LiveGateway extends FakeFirestoreGateway {
  final _streams = <String, StreamController<List<SyncDocument>>>{};

  @override
  Stream<List<SyncDocument>> watchCollection(String path) =>
      (_streams[path] ??= StreamController.broadcast()).stream;

  void deliver(String path, [List<SyncDocument> rows = const []]) =>
      _streams[path]!.add(rows);

  void fail(String path) => _streams[path]!.addError(StateError('offline'));

  void deliverEmptyEverywhere() {
    for (final entry in activeSyncCollections) {
      deliver(_path(entry.firestorePath));
    }
  }

  Future<void> close() async {
    for (final stream in _streams.values) {
      await stream.close();
    }
  }
}

class _Device {
  _Device(this.gateway, {required this.id}) : db = inMemoryDatabase() {
    context = SyncActiveContextStore(db);
    engine = ProductionSyncRuntimeEngine(
      db: db,
      gateway: gateway,
      activeContextStore: context,
      deviceId: id,
      localMutationDebounce: const Duration(milliseconds: 1),
    );
  }

  final String id;
  final _LiveGateway gateway;
  final AppDatabase db;
  late final SyncActiveContextStore context;
  late final ProductionSyncRuntimeEngine engine;

  Future<void> hold() async {
    for (final entry in {
      SyncHeldGeneration.generationKey: _generation,
      SyncHeldGeneration.uidKey: _uid,
    }.entries) {
      await db.customStatement(
        'insert into sync_meta (key,value) values (?,?)',
        [entry.key, entry.value],
      );
    }
  }

  Future<void> run() async {
    await context.publishStable(uid: _uid, generationId: _generation);
    await engine.start(uid: _uid, generationId: _generation);
  }

  Future<void> close() async {
    await engine.stop();
    await db.close();
  }

  Future<Map<String, Object?>?> journal(String rowId) async {
    final row = await db.customSelect(
      'select causal_base_state,causal_uid,causal_generation_id '
      'from sync_local_mutations where row_id = ?',
      variables: [Variable<String>(rowId)],
    ).getSingleOrNull();
    return row?.data;
  }

  Future<void> settled() =>
      Future<void>.delayed(const Duration(milliseconds: 150));
}

class _ClaimYes implements SyncClaimGateway {
  @override
  Future<bool> refreshProClaim({required String uid}) async => true;
}

class _NoCoordinator implements SyncCoordinator {
  int calls = 0;
  @override
  Future<FullPushResult> keepThisDevice({
    required String uid,
    required String? expectedActiveGenerationId,
    SyncContinuation? shouldContinue,
  }) async {
    calls += 1;
    return const FullPushResult(
      outcome: FullPushOutcome.retryableFailure,
      generationId: 'unused',
    );
  }

  @override
  Future<FullPullResult> keepMyAccount({
    required String uid,
    required String generationId,
    SyncContinuation? shouldContinue,
  }) async {
    calls += 1;
    return const FullPullResult(FullPullOutcome.retryableFailure);
  }
}

void main() {
  late _LiveGateway cloud;
  late _Device device;

  setUp(() {
    cloud = _LiveGateway();
    device = _Device(cloud, id: 'device-a');
  });

  tearDown(() async {
    await device.close();
    await cloud.close();
  });

  Future<void> bookmark(_Device on, String lessonId) =>
      LessonBookmarksRepository(on.db).mark(lessonId);

  group('a brand-new row while Sync runs', () {
    test('uploads on its own, with no tombstone seeded first', () async {
      await device.run();
      cloud.deliverEmptyEverywhere();
      await device.settled();

      await bookmark(device, 'lesson-1');
      await device.settled();

      final uploaded =
          await cloud.readDocument(_path('lesson_bookmarks', 'lesson-1'));
      expect(uploaded, isNotNull);
      expect(uploaded!.deleted, isFalse);
      expect(await device.journal('lesson-1'), isNull);
      expect(
        await SyncRowMetaRepository(device.db).readAcceptedBase(
          collection: 'lesson_bookmarks',
          rowId: 'lesson-1',
        ),
        isNotNull,
      );
    });

    test('reaches a second device', () async {
      await device.run();
      cloud.deliverEmptyEverywhere();
      await device.settled();
      await bookmark(device, 'lesson-1');
      await device.settled();
      final uploaded =
          (await cloud.readDocument(_path('lesson_bookmarks', 'lesson-1')))!;

      final second = _Device(cloud, id: 'device-b');
      addTearDown(second.close);
      await second.run();
      cloud
        ..deliverEmptyEverywhere()
        ..deliver(_path('lesson_bookmarks'), [uploaded]);
      await second.settled();

      expect(
        await LessonBookmarksRepository(second.db).isMarked('lesson-1'),
        isTrue,
      );
    });

    test('binds only per collection whose first snapshot applied', () async {
      await device.run();
      cloud.deliver(_path('lesson_bookmarks'));
      await device.settled();

      await bookmark(device, 'after-its-snapshot');
      await LocalSyncMutationRecorder.forDatabase(device.db).runRecorded<void>(
        collection: 'question_flags',
        rowId: 'before-its-snapshot',
        op: SyncLocalMutationOp.upsert,
        mutate: () {},
      );
      await device.settled();

      final waiting = (await device.journal('before-its-snapshot'))!;
      expect(waiting['causal_base_state'], 'unbound');
      expect(waiting['causal_uid'], _uid);
      expect(waiting['causal_generation_id'], _generation);
    });
  });

  group('a change made before the first snapshot waits', () {
    Future<void> waitingRow(String rowId) async {
      await bookmark(device, rowId);
      final row = (await device.journal(rowId))!;
      expect(row['causal_base_state'], 'unbound');
      expect(row['causal_generation_id'], _generation);
    }

    test('a row the cloud lacks binds as absent and uploads', () async {
      await device.run();
      await waitingRow('lesson-1');

      cloud.deliverEmptyEverywhere();
      await device.settled();

      expect(await device.journal('lesson-1'), isNull);
      expect(
        await cloud.readDocument(_path('lesson_bookmarks', 'lesson-1')),
        isNotNull,
      );
    });

    test('a row this device pushed binds to that version and uploads',
        () async {
      await device.run();
      await waitingRow('lesson-1');
      final pushedAt = DateTime.utc(2026, 11, 5, 1);
      cloud.documents[_path('lesson_bookmarks', 'lesson-1')] = {
        'lessonId': 'lesson-1',
        'markedAt': pushedAt,
        'updatedAt': pushedAt,
        'originDeviceId': device.id,
        'mutationId': 'full-push',
        'schemaVersion': 1,
        'deleted': false,
      };

      cloud.deliver(_path('lesson_bookmarks'), [
        (await cloud.readDocument(_path('lesson_bookmarks', 'lesson-1')))!,
      ]);
      await device.settled();
      expect(
        (await device.journal('lesson-1'))!['causal_base_state'],
        'knownVersion',
        reason: 'bound at once, and sent when every first snapshot has come',
      );

      for (final entry in activeSyncCollections) {
        if (entry.tableType != 'lesson_bookmarks') {
          cloud.deliver(_path(entry.firestorePath));
        }
      }
      await device.settled();

      expect(await device.journal('lesson-1'), isNull);
      final after =
          (await cloud.readDocument(_path('lesson_bookmarks', 'lesson-1')))!;
      expect(after.mutationId, isNot('full-push'));
    });

    test('a row another device wrote keeps the edit and stays unbound',
        () async {
      await device.run();
      await waitingRow('lesson-1');
      final before = await LessonBookmarksRepository(device.db).recentFirst();
      final theirs = SyncDocument(
        id: 'lesson-1',
        data: {
          'lessonId': 'lesson-1',
          'markedAt': DateTime.utc(2020),
          'updatedAt': DateTime.utc(2026, 11, 5, 1),
          'originDeviceId': 'device-b',
          'mutationId': 'theirs',
          'schemaVersion': 1,
          'deleted': false,
        },
      );

      cloud.deliver(_path('lesson_bookmarks'), [theirs]);
      await device.settled();

      expect(
        await LessonBookmarksRepository(device.db).recentFirst(),
        before,
      );
      final row = (await device.journal('lesson-1'))!;
      expect(row['causal_base_state'], 'unbound');
    });
  });

  group('a later snapshot', () {
    test('does not delete a recreated row waiting in the journal', () async {
      // Long debounce: the change is still only in the journal.
      final slow = _Device(cloud, id: 'device-c');
      addTearDown(slow.close);
      final engine = ProductionSyncRuntimeEngine(
        db: slow.db,
        gateway: cloud,
        activeContextStore: slow.context,
        deviceId: slow.id,
        localMutationDebounce: const Duration(hours: 1),
      );
      addTearDown(engine.stop);
      await slow.context.publishStable(uid: _uid, generationId: _generation);
      await engine.start(uid: _uid, generationId: _generation);
      cloud.deliverEmptyEverywhere();
      await slow.settled();
      await SyncRowMetaRepository(slow.db).acceptKnownAbsent(
        collection: 'lesson_bookmarks',
        rowId: 'lesson-1',
      );
      await bookmark(slow, 'lesson-1');

      cloud.deliver(_path('lesson_bookmarks'));
      await slow.settled();

      expect(
        await LessonBookmarksRepository(slow.db).isMarked('lesson-1'),
        isTrue,
      );
    });
  });

  group('work waiting from before this start', () {
    Future<void> leaveBoundEdit() async {
      await device.hold();
      await SyncHeldGeneration(device.db).markSnapshotComplete(
        generationId: _generation,
        collection: 'lesson_bookmarks',
      );
      await bookmark(device, 'lesson-1');
      expect(
        (await device.journal('lesson-1'))!['causal_base_state'],
        'knownAbsent',
      );
    }

    Future<SyncDocument?> uploaded() =>
        cloud.readDocument(_path('lesson_bookmarks', 'lesson-1'));

    test('uploads once the first snapshots have applied', () async {
      await leaveBoundEdit();
      await device.run();
      await device.settled();
      expect(await uploaded(), isNull, reason: 'before the first snapshots');

      cloud.deliverEmptyEverywhere();
      await device.settled();

      expect(await uploaded(), isNotNull);
      expect(await device.db.select(device.db.pendingSync).get(), isEmpty);
      expect(
        await LessonBookmarksRepository(device.db).isMarked('lesson-1'),
        isTrue,
      );
    });

    test('the journal timer waits for the first snapshots too', () async {
      await leaveBoundEdit();
      await SyncHeldGeneration(device.db).clearSnapshotMarks();
      await bookmark(device, 'lesson-2');
      expect(
        (await device.journal('lesson-2'))!['causal_base_state'],
        'unbound',
      );
      await device.run();
      await device.settled();
      expect(await uploaded(), isNull, reason: 'before the first snapshots');

      cloud.deliverEmptyEverywhere();
      await device.settled();

      expect(await uploaded(), isNotNull);
      expect(
        await cloud.readDocument(_path('lesson_bookmarks', 'lesson-2')),
        isNotNull,
        reason: 'what the journal held went with it',
      );
      final bookmarks = LessonBookmarksRepository(device.db);
      expect(await bookmarks.isMarked('lesson-1'), isTrue);
      expect(await bookmarks.isMarked('lesson-2'), isTrue);
    });

    test('waits for every collection, not just the first', () async {
      await leaveBoundEdit();
      await device.run();

      cloud.deliver(_path('lesson_bookmarks'));
      await device.settled();

      expect(await uploaded(), isNull);
    });

    test('a listener that fails does not hold it back', () async {
      await leaveBoundEdit();
      await device.run();

      cloud.fail(_path('question_flags'));
      for (final entry in activeSyncCollections) {
        if (entry.tableType != 'question_flags') {
          cloud.deliver(_path(entry.firestorePath));
        }
      }
      await device.settled();

      expect(await uploaded(), isNotNull);
    });

    test('a stopped engine does not upload', () async {
      await leaveBoundEdit();
      await device.run();
      cloud.deliverEmptyEverywhere();
      await device.engine.stop();
      await device.settled();

      expect(await uploaded(), isNull);
    });

    test('later snapshots do not flush again', () async {
      await device.run();
      cloud.deliverEmptyEverywhere();
      await device.settled();
      final events = <Object>[];
      final watching = device.engine.events.listen(events.add);
      addTearDown(watching.cancel);

      await device.db.into(device.db.pendingSync).insert(
            PendingSyncCompanion.insert(
              uid: const Value(_uid),
              generationId: const Value(_generation),
              tableType: 'lesson_bookmarks',
              rowId: 'not-yet-due',
              op: 'upsert',
              queuedAt: DateTime.utc(2026),
            ),
          );
      cloud.deliver(_path('lesson_bookmarks'));
      await device.settled();

      final row = await device.db.select(device.db.pendingSync).getSingle();
      expect(row.rowId, 'not-yet-due');
      expect(row.lastError, isNull);
    });
  });

  group('a conflict the first snapshot left unsettled', () {
    SyncDocument theirs({bool deleted = false}) => SyncDocument(
          id: 'lesson-1',
          data: {
            'lessonId': 'lesson-1',
            'markedAt': DateTime.utc(2020),
            'updatedAt': DateTime.utc(2026, 11, 5, 1),
            'originDeviceId': 'device-b',
            'mutationId': 'theirs',
            'schemaVersion': 1,
            'deleted': deleted,
          },
        );

    Future<void> conflict({bool deleted = false}) async {
      await device.run();
      await bookmark(device, 'lesson-1');
      cloud
        ..documents[_path('lesson_bookmarks', 'lesson-1')] =
            theirs(deleted: deleted).data
        ..deliver(_path('lesson_bookmarks'), [theirs(deleted: deleted)]);
      await device.settled();
    }

    Future<void> expectUnsettled() async {
      final row = (await device.journal('lesson-1'))!;
      expect(row['causal_base_state'], 'unbound');
      expect(row['causal_uid'], _uid);
      expect(row['causal_generation_id'], _generation);
      expect(await device.db.select(device.db.pendingSync).get(), isEmpty);
      final cloudRow =
          (await cloud.readDocument(_path('lesson_bookmarks', 'lesson-1')))!;
      expect(cloudRow.mutationId, 'theirs');
    }

    for (final deleted in [false, true]) {
      test('a re-edit stays unbound and keeps the row, tombstone $deleted',
          () async {
        await conflict(deleted: deleted);
        await bookmark(device, 'lesson-1');
        await device.settled();
        await bookmark(device, 'lesson-1');
        await device.settled();

        await expectUnsettled();
        expect(
          await LessonBookmarksRepository(device.db).isMarked('lesson-1'),
          isTrue,
        );
      });
    }

    test('a delete stays unbound and uploads nothing', () async {
      await conflict();
      await LessonBookmarksRepository(device.db).unmark('lesson-1');
      await device.settled();

      await expectUnsettled();
      final row = await device.db
          .customSelect('select op from sync_local_mutations')
          .getSingle();
      expect(row.read<String>('op'), 'delete');
    });

    test('a delete then a re-add stays unbound', () async {
      await conflict(deleted: true);
      await LessonBookmarksRepository(device.db).unmark('lesson-1');
      await bookmark(device, 'lesson-1');
      await device.settled();

      await expectUnsettled();
      expect(
        await LessonBookmarksRepository(device.db).isMarked('lesson-1'),
        isTrue,
      );
    });

    test('a later snapshot still does not overwrite the re-edit', () async {
      await conflict(deleted: true);
      await bookmark(device, 'lesson-1');
      cloud.deliver(_path('lesson_bookmarks'), [theirs(deleted: true)]);
      await device.settled();

      await expectUnsettled();
      expect(
        await LessonBookmarksRepository(device.db).isMarked('lesson-1'),
        isTrue,
      );
    });
  });

  group('a re-edit never moves a row to another tie', () {
    Future<void> journal({String? uid, String? generation, String? state}) =>
        device.db.customStatement(
          'insert into sync_local_mutations '
          '(collection,row_id,op,revision,mutation_epoch,causal_uid,'
          'causal_generation_id,causal_base_state,recorded_at) '
          'values (?,?,?,?,?,?,?,?,?)',
          [
            'lesson_bookmarks',
            'lesson-1',
            'upsert',
            1,
            1,
            uid,
            generation,
            state ?? 'unbound',
            0,
          ],
        );

    Future<void> holdComplete() async {
      await device.hold();
      await SyncHeldGeneration(device.db).markSnapshotComplete(
        generationId: _generation,
        collection: 'lesson_bookmarks',
      );
    }

    test('a change with no tie keeps having none', () async {
      await holdComplete();
      await journal();

      await bookmark(device, 'lesson-1');

      final row = (await device.journal('lesson-1'))!;
      expect(row['causal_base_state'], 'unbound');
      expect(row['causal_uid'], isNull);
      expect(row['causal_generation_id'], isNull);
    });

    test('a change tied to another generation stays there', () async {
      await holdComplete();
      await journal(uid: _uid, generation: 'gen-old', state: 'knownAbsent');

      await bookmark(device, 'lesson-1');

      final row = (await device.journal('lesson-1'))!;
      expect(row['causal_base_state'], 'knownAbsent');
      expect(row['causal_generation_id'], 'gen-old');
    });

    test('a change tied to another account stays there', () async {
      await holdComplete();
      await journal(uid: 'user-2', generation: _generation, state: 'unbound');

      await bookmark(device, 'lesson-1');

      expect((await device.journal('lesson-1'))!['causal_uid'], 'user-2');
    });

    test('a change already bound here takes the newest accepted state',
        () async {
      await holdComplete();
      await journal(uid: _uid, generation: _generation, state: 'knownAbsent');
      await SyncRowMetaRepository(device.db).acceptKnownVersion(
        collection: 'lesson_bookmarks',
        rowId: 'lesson-1',
        updatedAt: DateTime.utc(2026, 11, 5, 1),
      );

      await bookmark(device, 'lesson-1');

      expect(
        (await device.journal('lesson-1'))!['causal_base_state'],
        'knownVersion',
      );
    });
  });

  group('recording while Sync is stopped', () {
    Future<void> complete(String collection) =>
        SyncHeldGeneration(device.db).markSnapshotComplete(
          generationId: _generation,
          collection: collection,
        );

    test('an edit binds to what was accepted, frozen at that moment', () async {
      await device.hold();
      await complete('lesson_bookmarks');
      final v1 = DateTime.utc(2026, 11, 5, 1);
      await SyncRowMetaRepository(device.db).acceptKnownVersion(
        collection: 'lesson_bookmarks',
        rowId: 'known',
        updatedAt: v1,
      );

      await bookmark(device, 'known');
      await SyncRowMetaRepository(device.db).acceptKnownVersion(
        collection: 'lesson_bookmarks',
        rowId: 'known',
        updatedAt: v1.add(const Duration(hours: 1)),
      );

      final row = await device.db
          .customSelect(
            'select causal_base_state s, causal_uid u, causal_generation_id g, '
            'cast(base_updated_at as integer) b from sync_local_mutations',
          )
          .getSingle();
      expect(row.read<String>('s'), 'knownVersion');
      expect(row.read<String>('u'), _uid);
      expect(row.read<String>('g'), _generation);
      expect(row.read<int>('b'), v1.millisecondsSinceEpoch);
    });

    test('a new row binds as absent once the collection is complete', () async {
      await device.hold();
      await complete('lesson_bookmarks');

      await bookmark(device, 'new');

      final row = (await device.journal('new'))!;
      expect(row['causal_base_state'], 'knownAbsent');
    });

    test('a new row waits when the collection is not complete', () async {
      await device.hold();

      await bookmark(device, 'new');

      final row = (await device.journal('new'))!;
      expect(row['causal_base_state'], 'unbound');
      expect(row['causal_uid'], _uid);
    });

    test('a device holding nothing records no account or generation', () async {
      await bookmark(device, 'new');

      final row = (await device.journal('new'))!;
      expect(row['causal_base_state'], 'unbound');
      expect(row['causal_uid'], isNull);
      expect(row['causal_generation_id'], isNull);
    });

    for (final marker in ['pending_full_push', 'pending_full_pull']) {
      test('$marker means nothing is held', () async {
        await device.hold();
        await complete('lesson_bookmarks');
        await device.db.customStatement(
          'insert into sync_meta (key,value) values (?,?)',
          [marker, 'gen-next'],
        );

        await bookmark(device, 'new');

        expect((await device.journal('new'))!['causal_uid'], isNull);
      });
    }
  });

  group('a reload', () {
    SyncRuntimeController controller() => SyncRuntimeController(
          db: device.db,
          claimGateway: _ClaimYes(),
          activeContextStore: device.context,
          generationRepositoryForUid: (uid) => GenerationRepository(
            gateway: cloud,
            functionsGateway: FakeSyncFunctionsGateway(),
            uid: uid,
          ),
          coordinator: _NoCoordinator(),
          engine: device.engine,
        );

    Future<void> seedCloud() async {
      cloud.documents['users/$_uid/sync_state/current'] = {
        'activeGenerationId': _generation,
      };
      await device.db.into(device.db.lessonProgressLocal).insert(
            LessonProgressLocalCompanion.insert(
              lessonId: 'local',
              readAt: DateTime.utc(2026),
            ),
          );
      cloud.collections[_path('lesson_progress')] = [
        {
          'id': 'cloud',
          'deleted': false,
          'updatedAt': DateTime.utc(2026),
        },
      ];
    }

    Future<SyncStatus> reload() async {
      final next = controller();
      await next.update(
        identity: const SyncIdentity(uid: _uid),
        entitlement: SyncEntitlement.pro,
      );
      return next.status;
    }

    test('does not ask after a session that made new rows', () async {
      await seedCloud();
      await device.hold();
      await device.run();
      cloud.deliverEmptyEverywhere();
      await device.settled();
      await bookmark(device, 'lesson-1');
      await device.engine.stop();

      expect(await reload(), isNot(isA<SyncReconciliationRequired>()));
    });

    test('does not ask for an edit made before Sync was back', () async {
      await seedCloud();
      await device.hold();
      for (final entry in activeSyncCollections) {
        await SyncHeldGeneration(device.db).markSnapshotComplete(
          generationId: _generation,
          collection: entry.tableType,
        );
      }

      await bookmark(device, 'edited-in-the-window');

      expect(await reload(), isNot(isA<SyncReconciliationRequired>()));
      expect(await device.journal('edited-in-the-window'), isNull);
    });

    test('does not ask while a change can still bind to a first snapshot',
        () async {
      await seedCloud();
      await device.hold();
      await bookmark(device, 'lesson-1');

      expect(await reload(), isNot(isA<SyncReconciliationRequired>()));
    });

    test('asks for a change the first snapshot could not bind', () async {
      await seedCloud();
      await device.hold();
      await device.run();
      await bookmark(device, 'lesson-1');
      cloud.deliver(_path('lesson_bookmarks'), [
        SyncDocument(
          id: 'lesson-1',
          data: {
            'lessonId': 'lesson-1',
            'markedAt': DateTime.utc(2020),
            'updatedAt': DateTime.utc(2026, 11, 5, 1),
            'originDeviceId': 'device-b',
            'mutationId': 'theirs',
            'schemaVersion': 1,
            'deleted': false,
          },
        ),
      ]);
      await device.settled();
      await device.engine.stop();

      expect(await reload(), isA<SyncReconciliationRequired>());
    });

    test('asks for a change with no account or generation', () async {
      await seedCloud();
      await bookmark(device, 'made-before-holding');
      await device.hold();

      expect(await reload(), isA<SyncReconciliationRequired>());
    });

    test('a signed-in or anonymous other account ends the hold', () async {
      for (final other in const [
        SyncIdentity(uid: 'user-2'),
        SyncIdentity(uid: 'anon-2', isAnonymous: true),
      ]) {
        await device.hold();
        await controller().update(
          identity: other,
          entitlement: SyncEntitlement.free,
        );
        expect(await SyncHeldGeneration(device.db).read(), isNull);
      }
    });

    test('the placeholder identity at startup keeps the hold', () async {
      await device.hold();
      await controller().update(
        identity: const SyncIdentity(
          uid: SyncIdentity.signedOutUid,
          isAnonymous: true,
        ),
        entitlement: SyncEntitlement.free,
      );
      expect(await SyncHeldGeneration(device.db).read(), isNotNull);
    });
  });

  group('bootstraps', () {
    test('a finished download marks every collection complete', () async {
      cloud.documents['users/$_uid/sync_generations/$_generation'] = {
        'status': 'active',
        'schemaVersion': 1,
        'createdAt': DateTime.utc(2026),
        'createdByDeviceId': 'x',
        'preferences': <String, Object?>{},
      };
      final result = await FullPullBootstrap(
        db: device.db,
        gateway: cloud,
        uid: _uid,
      ).run(generationId: _generation);
      expect(result.outcome, FullPullOutcome.applied);
      final held = SyncHeldGeneration(device.db);
      for (final entry in activeSyncCollections) {
        expect(
          await held.isSnapshotComplete(
            generationId: _generation,
            collection: entry.tableType,
          ),
          isTrue,
          reason: entry.tableType,
        );
      }
    });

    test('a finished upload forgets old completeness', () async {
      final held = SyncHeldGeneration(device.db);
      await held.markSnapshotComplete(
        generationId: 'gen-old',
        collection: 'lesson_bookmarks',
      );
      final result = await FullPushBootstrap(
        db: device.db,
        gateway: cloud,
        functionsGateway: FakeSyncFunctionsGateway(),
        uid: _uid,
        deviceId: device.id,
        generationIdFactory: () => 'gen-new',
      ).run(expectedActiveGenerationId: null);
      expect(result.outcome, FullPushOutcome.activated);
      expect(
        await held.isSnapshotComplete(
          generationId: 'gen-old',
          collection: 'lesson_bookmarks',
        ),
        isFalse,
      );
      expect(
        await held.isSnapshotComplete(
          generationId: 'gen-new',
          collection: 'lesson_bookmarks',
        ),
        isFalse,
      );
    });
  });
}
