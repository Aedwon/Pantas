import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/bootstrap/full_pull.dart';
import 'package:pantas/core/sync/bootstrap/full_push.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/engine/generation_repository.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_outbox_promoter.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';
import 'package:pantas/core/sync/sync_coordinator.dart';
import 'package:pantas/core/sync/sync_status.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  for (final nativeDenial in [false, true]) {
    test(
        'bootstrap denial retries after cooldown '
        'without restart ($nativeDenial)', () async {
      final h = _Harness();
      addTearDown(h.close);
      final clock = _BootstrapClock();
      h.coordinator.failuresRemaining = 1;
      h.coordinator.nativeDenial = nativeDenial;
      await clock.run(
        () => h.runtime.update(
          identity: const SyncIdentity(uid: 'user-1'),
          entitlement: SyncEntitlement.pro,
        ),
      );
      expect(h.runtime.status, isA<SyncError>());
      expect(clock.timers, hasLength(1));
      expect(
        clock.timers.single.delay,
        greaterThan(const Duration(minutes: 5)),
      );
      expect(
        clock.timers.single.delay,
        lessThanOrEqualTo(const Duration(minutes: 5, seconds: 10)),
      );
      expect(h.engine.starts, isEmpty);
      clock.timers.single.fire();
      await _waitFor(() => h.runtime.status is SyncUpToDate);
      expect(h.coordinator.pushCalls, 2);
      expect(h.engine.starts, ['user-1:gen-user-1-2']);
      expect(clock.timers.where((timer) => timer.isActive), isEmpty);
    });
  }

  test('bootstrap retry preserves an explicit keep-device choice', () async {
    final h = _Harness();
    addTearDown(h.close);
    final clock = _BootstrapClock();
    h.seedGeneration(
      uid: 'user-1',
      generationId: 'gen-cloud',
      meaningful: true,
    );
    await h.seedLocalLesson();
    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );
    h.coordinator.failuresRemaining = 1;
    await clock.run(
      () => h.runtime
          .chooseReconciliation(SyncReconciliationChoice.keepThisDevice),
    );
    expect(clock.timers, hasLength(1));
    clock.timers.single.fire();
    await _waitFor(() => h.runtime.status is SyncUpToDate);
    expect(
      h.coordinator.operations,
      ['push:user-1:gen-cloud', 'push:user-1:gen-cloud'],
    );
  });

  test('account change cancels a pending bootstrap retry', () async {
    final h = _Harness();
    addTearDown(h.close);
    final clock = _BootstrapClock();
    h.coordinator.failuresRemaining = 1;
    await clock.run(
      () => h.runtime.update(
        identity: const SyncIdentity(uid: 'user-1'),
        entitlement: SyncEntitlement.pro,
      ),
    );
    expect(clock.timers, hasLength(1));
    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-2'),
      entitlement: SyncEntitlement.pro,
    );
    expect(clock.timers.single.isActive, isFalse);
    clock.timers.single.fire();
    await Future<void>.delayed(Duration.zero);
    expect(h.coordinator.operations, ['push:user-1:null', 'push:user-2:null']);
    expect(h.engine.starts, ['user-2:gen-user-2-1']);
  });

  test('sign-out cancels a pending bootstrap retry', () async {
    final h = _Harness();
    addTearDown(h.close);
    final clock = _BootstrapClock();
    h.coordinator.failuresRemaining = 1;
    await clock.run(
      () => h.runtime.update(
        identity: const SyncIdentity(uid: 'user-1'),
        entitlement: SyncEntitlement.pro,
      ),
    );
    expect(clock.timers, hasLength(1));
    await h.runtime.quiesce(flush: false);
    expect(clock.timers.single.isActive, isFalse);
    clock.timers.single.fire();
    await Future<void>.delayed(Duration.zero);
    expect(h.coordinator.pushCalls, 1);
    expect(h.runtime.status, isA<SyncOff>());
  });

  test('anonymous Pro is off without claim or progress reads', () async {
    final h = _Harness();
    addTearDown(h.close);

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'anon-1', isAnonymous: true),
      entitlement: SyncEntitlement.pro,
    );

    expect(h.runtime.status, isA<SyncOff>());
    expect(h.claim.calls, 0);
    expect(h.firestore.reads, 0);
    expect(h.engine.starts, isEmpty);
  });

  test('named Free is off without claim or progress reads', () async {
    final h = _Harness();
    addTearDown(h.close);

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.free,
    );

    expect(h.runtime.status, isA<SyncOff>());
    expect(h.claim.calls, 0);
    expect(h.firestore.reads, 0);
  });

  test(
      'named RevenueCat Pro without refreshed claim activates with zero '
      'Firestore reads', () async {
    final h = _Harness(hasClaim: false);
    addTearDown(h.close);

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );

    expect(h.runtime.status, isA<SyncActivating>());
    expect(h.claim.calls, 1);
    expect(h.firestore.reads, 0);
    expect(h.coordinator.operations, isEmpty);
  });

  test(
      'no generation automatically keeps this device before publishing context',
      () async {
    final h = _Harness();
    addTearDown(h.close);

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );

    expect(h.coordinator.operations, ['push:user-1:null']);
    expect(h.engine.starts, ['user-1:gen-user-1-1']);
    final active = await h.activeContext.readStable();
    expect(active!.uid, 'user-1');
    expect(active.generationId, 'gen-user-1-1');
    expect(h.runtime.status, isA<SyncUpToDate>());
  });

  test('existing generation plus empty local automatically keeps account',
      () async {
    final h = _Harness();
    addTearDown(h.close);
    h.seedGeneration(uid: 'user-1', generationId: 'gen-cloud');

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );

    expect(h.coordinator.operations, ['pull:user-1:gen-cloud']);
    expect(h.engine.starts, ['user-1:gen-cloud']);
  });

  test(
      'local meaningful plus empty cloud generation automatically keeps device',
      () async {
    final h = _Harness();
    addTearDown(h.close);
    h.seedGeneration(uid: 'user-1', generationId: 'gen-cloud');
    await h.seedLocalLesson();

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );

    expect(h.coordinator.operations, ['push:user-1:gen-cloud']);
    expect(h.engine.starts, ['user-1:gen-user-1-1']);
  });

  test('both meaningful blocks engine and context until explicit choice',
      () async {
    final h = _Harness();
    addTearDown(h.close);
    h.seedGeneration(
      uid: 'user-1',
      generationId: 'gen-cloud',
      meaningful: true,
    );
    await h.seedLocalLesson();

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );

    final status = h.runtime.status;
    expect(status, isA<SyncReconciliationRequired>());
    expect(
      (status as SyncReconciliationRequired).activeGenerationId,
      'gen-cloud',
    );
    expect(h.engine.starts, isEmpty);
    expect(await h.activeContext.readStable(), isNull);
    expect(h.coordinator.operations, isEmpty);

    await h.runtime.chooseReconciliation(
      SyncReconciliationChoice.keepMyAccount,
    );

    expect(h.coordinator.operations, ['pull:user-1:gen-cloud']);
    expect(h.engine.starts, ['user-1:gen-cloud']);
    expect((await h.activeContext.readStable())!.generationId, 'gen-cloud');
  });

  test(
      'eligibility loss clears stable context before a slow engine stop '
      'finishes', () async {
    final h = _Harness();
    addTearDown(h.close);
    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );
    h.engine.blockStops = true;

    final off = h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.free,
    );
    await h.engine.stopEntered.future;

    expect(await h.activeContext.readStable(), isNull);
    expect(h.runtime.status, isA<SyncOff>());

    h.engine.releaseStop();
    await off;
  });

  test('all local-only runtime states keep mutations unbound and out of outbox',
      () async {
    Future<void> expectLocalOnlyMutation(_Harness h, String label) async {
      expect(await h.activeContext.readStable(), isNull);
      final recorder = LocalSyncMutationRecorder(
        h.db,
        activeContextStore: h.activeContext,
        rowMetaRepository: SyncRowMetaRepository(h.db),
        now: () => DateTime.utc(2026, 8, 30, 6),
      );
      final rowId = 'matrix-$label';
      await recorder.runRecorded(
        collection: 'lesson_progress',
        rowId: rowId,
        op: SyncLocalMutationOp.upsert,
        mutate: () => h.db.customStatement(
          'insert into account_prefs (key,value) values (?,?) '
          'on conflict(key) do update set value=excluded.value',
          ['matrix-$label', 'local'],
        ),
      );

      final row = await h.db.customSelect(
        'select causal_base_state,causal_uid,causal_generation_id, '
        'base_updated_at from sync_local_mutations '
        'where collection = ? and row_id = ?',
        variables: [
          const Variable<String>('lesson_progress'),
          Variable<String>(rowId),
        ],
      ).getSingle();
      expect(row.read<String>('causal_base_state'), 'unbound');
      expect(row.data['causal_uid'], isNull);
      expect(row.data['causal_generation_id'], isNull);
      expect(row.data['base_updated_at'], isNull);

      final queue = PendingQueue(h.db);
      final promoted = await SyncOutboxPromoter(
        h.db,
        activeContextStore: h.activeContext,
        pendingQueue: queue,
      ).promoteAvailable();
      expect(promoted, 0);
      expect(await queue.drain(limit: 10), isEmpty);
    }

    final anonymous = _Harness();
    await anonymous.runtime.update(
      identity: const SyncIdentity(uid: 'anon-1', isAnonymous: true),
      entitlement: SyncEntitlement.pro,
    );
    expect(anonymous.runtime.status, isA<SyncOff>());
    await expectLocalOnlyMutation(anonymous, 'anonymous');
    await anonymous.close();

    final namedFree = _Harness();
    await namedFree.runtime.update(
      identity: const SyncIdentity(uid: 'user-free'),
      entitlement: SyncEntitlement.free,
    );
    expect(namedFree.runtime.status, isA<SyncOff>());
    await expectLocalOnlyMutation(namedFree, 'named-free');
    await namedFree.close();

    final activating = _Harness(hasClaim: false);
    await activating.runtime.update(
      identity: const SyncIdentity(uid: 'user-activating'),
      entitlement: SyncEntitlement.pro,
    );
    expect(activating.runtime.status, isA<SyncActivating>());
    await expectLocalOnlyMutation(activating, 'activating');
    await activating.close();

    final b3Pending = _Harness()
      ..seedGeneration(
        uid: 'user-b3',
        generationId: 'gen-cloud',
        meaningful: true,
      );
    await b3Pending.seedLocalLesson();
    await b3Pending.runtime.update(
      identity: const SyncIdentity(uid: 'user-b3'),
      entitlement: SyncEntitlement.pro,
    );
    expect(b3Pending.runtime.status, isA<SyncReconciliationRequired>());
    await expectLocalOnlyMutation(b3Pending, 'b3-pending');
    await b3Pending.close();

    final quiesced = _Harness();
    await quiesced.runtime.update(
      identity: const SyncIdentity(uid: 'user-quiesced'),
      entitlement: SyncEntitlement.pro,
    );
    expect(await quiesced.activeContext.readStable(), isNotNull);
    await quiesced.runtime.quiesce(flush: false);
    expect(quiesced.runtime.status, isA<SyncOff>());
    await expectLocalOnlyMutation(quiesced, 'quiesced');
    await quiesced.close();
  });

  test(
      'entitlement restoration reruns B3 instead of blindly resuming old '
      'generation', () async {
    final h = _Harness();
    addTearDown(h.close);

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );
    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.free,
    );
    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );

    expect(h.coordinator.pushCalls, 2);
    expect(h.engine.starts, ['user-1:gen-user-1-1', 'user-1:gen-user-1-2']);
  });

  test('UID switch never retargets prior generation-bound outbox work',
      () async {
    final h = _Harness();
    addTearDown(h.close);
    await h.db.into(h.db.pendingSync).insert(
          PendingSyncCompanion.insert(
            uid: const Value('old-user'),
            generationId: const Value('old-gen'),
            tableType: 'lesson_progress',
            rowId: 'lesson-old',
            op: 'upsert',
            queuedAt: DateTime.utc(2026, 8, 30),
          ),
        );

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'new-user'),
      entitlement: SyncEntitlement.pro,
    );

    final pending = (await h.db.select(h.db.pendingSync).get()).single;
    expect(pending.uid, 'old-user');
    expect(pending.generationId, 'old-gen');
    expect((await h.activeContext.readStable())!.uid, 'new-user');
  });

  test(
      'auth and entitlement events serialize instead of running concurrent '
      'B3 flows', () async {
    final claim = _BlockingClaimGateway();
    final h = _Harness(claimGateway: claim);
    addTearDown(h.close);

    final first = h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );
    await claim.firstEntered.future;
    final second = h.runtime.update(
      identity: const SyncIdentity(uid: 'user-2'),
      entitlement: SyncEntitlement.pro,
    );
    claim.releaseFirst();
    await Future.wait([first, second]);

    expect(claim.maxConcurrent, 1);
    expect(h.coordinator.operations, ['push:user-2:null']);
    expect(h.engine.starts, ['user-2:gen-user-2-1']);
  });

  for (final unsettled in ['journal', 'outbox', 'projection']) {
    test('status cannot be upToDate while $unsettled is unsettled', () async {
      final h = _Harness();
      addTearDown(h.close);
      await h.seedUnsettled(unsettled);

      await h.runtime.update(
        identity: const SyncIdentity(uid: 'user-1'),
        entitlement: SyncEntitlement.pro,
      );

      expect(h.runtime.status, isA<Syncing>());
      expect(h.runtime.status, isNot(isA<SyncUpToDate>()));
    });
  }

  test('failed outbox publishes error instead of generic syncing', () async {
    final h = _Harness();
    addTearDown(h.close);
    await h.db.into(h.db.pendingSync).insert(
          PendingSyncCompanion.insert(
            uid: const Value('old-user'),
            generationId: const Value('old-gen'),
            tableType: 'lesson_progress',
            rowId: 'failed-outbox',
            op: 'upsert',
            queuedAt: DateTime.utc(2026, 8, 30),
            lastError: const Value('push failed'),
          ),
        );

    await h.runtime.update(
      identity: const SyncIdentity(uid: 'user-1'),
      entitlement: SyncEntitlement.pro,
    );

    expect(h.runtime.status, isA<SyncError>());
    expect((h.runtime.status as SyncError).message, 'push failed');
  });
}

class _Harness {
  _Harness({
    bool hasClaim = true,
    SyncClaimGateway? claimGateway,
  })  : db = inMemoryDatabase(),
        firestore = _CountingFirestoreGateway(),
        coordinator = _FakeCoordinator(),
        engine = _FakeRuntimeEngine(),
        claim = claimGateway is _CountingClaimGateway
            ? claimGateway
            : _CountingClaimGateway(hasClaim: hasClaim) {
    final configuredClaim = claimGateway ?? claim;
    activeContext = SyncActiveContextStore(db);
    runtime = SyncRuntimeController(
      db: db,
      claimGateway: configuredClaim,
      activeContextStore: activeContext,
      generationRepositoryForUid: (uid) => GenerationRepository(
        gateway: firestore,
        functionsGateway: FakeSyncFunctionsGateway(),
        uid: uid,
      ),
      coordinator: coordinator,
      engine: engine,
    );
  }

  final AppDatabase db;
  final _CountingFirestoreGateway firestore;
  final _FakeCoordinator coordinator;
  final _FakeRuntimeEngine engine;
  final _CountingClaimGateway claim;
  late final SyncActiveContextStore activeContext;
  late final SyncRuntimeController runtime;

  void seedGeneration({
    required String uid,
    required String generationId,
    bool meaningful = false,
  }) {
    firestore.documents['users/$uid/sync_state/current'] = {
      'activeGenerationId': generationId,
    };
    firestore.documents['users/$uid/sync_generations/$generationId'] = {
      'status': 'active',
      'schemaVersion': 1,
      'createdAt': DateTime.utc(2026, 8, 29),
      'createdByDeviceId': 'cloud-device',
      'preferences': <String, Object?>{},
    };
    if (meaningful) {
      firestore.collections[
          'users/$uid/sync_generations/$generationId/lesson_progress'] = [
        {
          'id': 'cloud-lesson',
          'deleted': false,
          'updatedAt': DateTime.utc(2026, 8, 30),
        },
      ];
    }
  }

  Future<void> seedLocalLesson() => db.into(db.lessonProgressLocal).insert(
        LessonProgressLocalCompanion.insert(
          lessonId: 'local-lesson',
          readAt: DateTime.utc(2026, 8, 30),
        ),
      );

  Future<void> seedUnsettled(String kind) async {
    switch (kind) {
      case 'journal':
        await db.customStatement(
          'insert into sync_local_mutations '
          '(collection,row_id,op,revision,mutation_epoch,'
          'causal_base_state,recorded_at) '
          'values (?,?,?,?,?,?,?)',
          [
            'lesson_progress',
            'journal-only',
            'upsert',
            1,
            1,
            'unbound',
            DateTime.utc(2026, 8, 30).millisecondsSinceEpoch,
          ],
        );
      case 'outbox':
        await db.into(db.pendingSync).insert(
              PendingSyncCompanion.insert(
                uid: const Value('old-user'),
                generationId: const Value('old-gen'),
                tableType: 'lesson_progress',
                rowId: 'outbox-only',
                op: 'upsert',
                queuedAt: DateTime.utc(2026, 8, 30),
              ),
            );
      case 'projection':
        await db.customStatement(
          'insert into sync_meta (key,value) values '
          "('customTrackProjectionRequired:test','1')",
        );
    }
  }

  Future<void> close() => db.close();
}

class _CountingFirestoreGateway extends FakeFirestoreGateway {
  int reads = 0;

  @override
  Future<SyncDocument?> readDocument(String path) async {
    reads += 1;
    return super.readDocument(path);
  }

  @override
  Future<List<SyncDocument>> readCollection(String path) async {
    reads += 1;
    return super.readCollection(path);
  }
}

class _CountingClaimGateway implements SyncClaimGateway {
  _CountingClaimGateway({required this.hasClaim});

  final bool hasClaim;
  int calls = 0;

  @override
  Future<bool> refreshProClaim({required String uid}) async {
    calls += 1;
    return hasClaim;
  }
}

class _BlockingClaimGateway implements SyncClaimGateway {
  final firstEntered = Completer<void>();
  final _release = Completer<void>();
  var _calls = 0;
  var _active = 0;
  int maxConcurrent = 0;

  @override
  Future<bool> refreshProClaim({required String uid}) async {
    _calls += 1;
    _active += 1;
    if (_active > maxConcurrent) maxConcurrent = _active;
    if (_calls == 1) {
      firstEntered.complete();
      await _release.future;
    }
    _active -= 1;
    return true;
  }

  void releaseFirst() => _release.complete();
}

class _FakeCoordinator implements SyncCoordinator {
  final operations = <String>[];
  final _pushPerUid = <String, int>{};
  int failuresRemaining = 0;
  bool nativeDenial = false;

  int get pushCalls => operations.where((op) => op.startsWith('push:')).length;

  @override
  Future<FullPushResult> keepThisDevice({
    required String uid,
    required String? expectedActiveGenerationId,
    SyncContinuation? shouldContinue,
  }) async {
    operations.add('push:$uid:$expectedActiveGenerationId');
    final count = (_pushPerUid[uid] ?? 0) + 1;
    _pushPerUid[uid] = count;
    if (failuresRemaining > 0) {
      failuresRemaining -= 1;
      if (nativeDenial) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        );
      }
      return FullPushResult(
        outcome: FullPushOutcome.retryableFailure,
        generationId: 'gen-$uid-$count',
      );
    }
    return FullPushResult(
      outcome: FullPushOutcome.activated,
      generationId: 'gen-$uid-$count',
    );
  }

  @override
  Future<FullPullResult> keepMyAccount({
    required String uid,
    required String generationId,
    SyncContinuation? shouldContinue,
  }) async {
    operations.add('pull:$uid:$generationId');
    return const FullPullResult(FullPullOutcome.applied);
  }
}

class _FakeRuntimeEngine implements SyncRuntimeEngine {
  final starts = <String>[];
  int stopCalls = 0;
  int flushCalls = 0;
  bool blockStops = false;
  Completer<void> stopEntered = Completer<void>();
  final Completer<void> _stopRelease = Completer<void>();

  @override
  Future<void> start({
    required String uid,
    required String generationId,
  }) async {
    starts.add('$uid:$generationId');
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    if (!blockStops) return;
    if (!stopEntered.isCompleted) stopEntered.complete();
    await _stopRelease.future;
  }

  @override
  Future<void> forceFlush() async {
    flushCalls += 1;
  }

  void releaseStop() {
    if (!_stopRelease.isCompleted) _stopRelease.complete();
  }
}

Future<void> _waitFor(bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(condition(), isTrue);
}

class _BootstrapClock {
  final timers = <_BootstrapTimer>[];

  Future<void> run(Future<void> Function() operation) {
    return runZoned(
      operation,
      zoneSpecification: ZoneSpecification(
        createTimer: (self, parent, zone, delay, callback) {
          if (delay >= const Duration(minutes: 5)) {
            final timer = _BootstrapTimer(delay, callback);
            timers.add(timer);
            return timer;
          }
          return parent.createTimer(zone, delay, callback);
        },
      ),
    );
  }
}

class _BootstrapTimer implements Timer {
  _BootstrapTimer(this.delay, this.callback);
  final Duration delay;
  final void Function() callback;
  @override
  bool isActive = true;
  @override
  int tick = 0;
  @override
  void cancel() => isActive = false;
  void fire() {
    if (!isActive) return;
    isActive = false;
    tick = 1;
    callback();
  }
}
