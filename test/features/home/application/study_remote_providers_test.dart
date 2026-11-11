import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/pull_pipeline.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_held_generation.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  // Nov 8 Backup records its time in sync_meta after every backup. That is
  // bookkeeping, and counting it made Home call its server reads again after
  // each answer was backed up.
  // Manager review, Nov 9: ignoring the backup time also dropped the only
  // refresh Your record and the plan got after another device's changes.
  test('a row from another device moves the study core epoch', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyEpochDebounceProvider
            .overrideWithValue(const Duration(milliseconds: 20)),
      ],
    );
    addTearDown(container.dispose);
    final seen = <int>[];
    container.listen<AsyncValue<int>>(
      studyCoreEpochProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    await pumpEventQueue();
    expect(seen, [0]);

    await PullPipeline(
      db: db,
      queue: PendingQueue(db),
      uid: 'user-1',
      generationId: 'g',
      deviceId: 'this-device',
    ).applyCompleteSnapshot(
      generationId: 'g',
      collection: 'lesson_progress',
      documents: [
        SyncDocument(
          id: 'lesson-1',
          data: {
            'lessonId': 'lesson-1',
            'readAt': '2026-11-09T08:00:00.000Z',
            'updatedAt': DateTime.utc(2026, 11, 9, 8),
            'originDeviceId': 'other-device',
            'mutationId': 'other-1',
            'deleted': false,
            'schemaVersion': 1,
          },
        ),
      ],
    );
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(seen.last, greaterThan(0));
  });

  test('the backup time does not move the study core epoch', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final seen = <int>[];
    container.listen<AsyncValue<int>>(
      studyCoreEpochProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    await pumpEventQueue();
    expect(seen, [0]);

    await db.into(db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(
            key: 'last_backup_at:user-1',
            value: '2026-11-09T00:00:00.000Z',
          ),
        );
    await pumpEventQueue();
    expect(seen, [0]);
  });

  // Nov 10: Home showed "Could not load your plan." in the browser journeys
  // and on prod ("Bad state: Study owner changed" in prod reports). Every
  // sync bookkeeping write moved this epoch, which rebuilt the study reader
  // and failed the plan read in flight; a first sync writes such rows for
  // seconds, longer than Home's retries last. Only rows that mean the owner
  // or the data changed may move it.
  test('sync bookkeeping does not move the study core epoch', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final seen = <int>[];
    container.listen<AsyncValue<int>>(
      studyCoreEpochProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    await pumpEventQueue();
    expect(seen, [0]);

    for (final key in [
      'pending_full_pull',
      'pending_full_push',
      'deviceId',
    ]) {
      await db.into(db.syncMeta).insertOnConflictUpdate(
            SyncMetaCompanion.insert(key: key, value: '1'),
          );
    }
    await SyncHeldGeneration(db).markSnapshotComplete(
      generationId: 'g',
      collection: 'lesson_progress',
    );
    await SyncHeldGeneration(db).clearSnapshotMarks();
    await pumpEventQueue();
    expect(seen, [0]);
  });

  test('the sync owner and its generation move the study core epoch', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final seen = <int>[];
    container.listen<AsyncValue<int>>(
      studyCoreEpochProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    await pumpEventQueue();

    // The context token is written with a raw statement the table stream
    // does not see; the read guards catch a token change on their own.
    await db.into(db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(
            key: SyncHeldGeneration.generationKey,
            value: 'g2',
          ),
        );
    await pumpEventQueue();
    final afterGeneration = seen.last;
    expect(afterGeneration, greaterThan(0));

    await db.into(db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(
            key: SyncHeldGeneration.uidKey,
            value: 'user-2',
          ),
        );
    await pumpEventQueue();
    expect(seen.last, greaterThan(afterGeneration));
  });

  test('a changed token fails the read in hand and renews the reader',
      () async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(content.close);
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    await AppPreferencesRepository(db).setSelectedExamId('e');
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'u')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final hold = container.listen(
      studySnapshotReaderProvider('e'),
      (_, __) {},
    );
    addTearDown(hold.close);
    final first = await container.read(studySnapshotReaderProvider('e').future);
    expect(await first.request.isCurrent(), isTrue);

    await SyncActiveContextStore(db).publishStable(
      uid: 'u',
      generationId: 'gen-1',
    );

    expect(await first.request.isCurrent(), isFalse);
    final next = await container.read(studySnapshotReaderProvider('e').future);
    expect(identical(next, first), isFalse);
    expect(await next.request.isCurrent(), isTrue);
  });

  // Beta monitor, prod: a plain Home load on a second device applies the
  // other device's rows collection by collection. Each one moved the combined
  // epoch, which rebuilt the reader, failed the read in flight ("Study owner
  // changed") and fired fresh getRoadmap and getStudyInsights reads, six of
  // each within a second.
  Map<String, Object?> roadmapPayload(String revision) {
    Map<String, Object?> plan(List<String> lessons) => {
          'day': '2026-10-24',
          'lessonIds': lessons,
          'reviewQuestionIds': <String>[],
          'newQuestionIds': <String>[],
          'advancedIds': <String>[],
          'isMockDay': false,
          'isRestDay': false,
        };
    return {
      'examId': 'e',
      'serverNow': 100,
      'accessRecheckAt': null,
      'proCovered': false,
      'revision': revision,
      'state': 'planning',
      'today': plan(['l1']),
      'remaining': plan(['l1']),
      'originalDone': false,
      'canAdvance': false,
      'todayTopicOrder': ['t'],
      'weekDays': [
        for (var i = 0; i < 7; i++) {'state': i == 6 ? 'today' : 'unknown'},
      ],
    };
  }

  Map<String, Object?> insightsPayload(String revision) => {
        'examId': 'e',
        'serverNow': 123,
        'accessRecheckAt': null,
        'proCovered': false,
        'revision': revision,
        'profile': null,
        'performance': {
          'overall': {'correct': 0, 'answered': 0},
          'subjects': <Object?>[],
          'lessonLevelAvailable': false,
        },
      };

  Future<void> bumpRemote(AppDatabase db, int n) =>
      db.into(db.syncMeta).insertOnConflictUpdate(
            SyncMetaCompanion.insert(
              key: PullPipeline.remoteChangeKey,
              value: '$n',
            ),
          );

  Future<void> until(bool Function() done) async {
    for (var i = 0; i < 200 && !done(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  ({
    ProviderContainer container,
    AppDatabase db,
    Map<String, int> calls,
    Completer<void> gate,
    List<Object> errors,
    List<String> revisions,
  }) gatedStudy() {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final calls = <String, int>{};
    final gate = Completer<void>();
    final errors = <Object>[];
    final revisions = <String>[];
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyUsesServerProvider.overrideWithValue(true),
        studyEpochDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 50),
        ),
        trackScopeProvider('e').overrideWith((_) async => {}),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'u')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            final n = calls[name] = (calls[name] ?? 0) + 1;
            // Only the first read of each kind is held open.
            if (n == 1) await gate.future;
            final revision = n == 1 ? 'first' : 'later';
            return name == 'getRoadmap'
                ? roadmapPayload(revision)
                : insightsPayload(revision);
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    return (
      container: container,
      db: db,
      calls: calls,
      gate: gate,
      errors: errors,
      revisions: revisions,
    );
  }

  test(
      'a burst of remote row notices keeps the reader and the read in flight, '
      'and refreshes once', () async {
    final t = gatedStudy();
    await SyncActiveContextStore(t.db).clearStable();
    final container = t.container;
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final subs = [
      container.listen<AsyncValue<StudyRoadmap>>(
        serverStudyRoadmapProvider('e'),
        (_, next) {
          if (next.hasError) t.errors.add(next.error!);
          next.whenData((v) => t.revisions.add(v.revision));
        },
        fireImmediately: true,
      ),
      container.listen<AsyncValue<StudyInsights>>(
        serverStudyInsightsProvider('e'),
        (_, next) {
          if (next.hasError) t.errors.add(next.error!);
        },
        fireImmediately: true,
      ),
    ];
    for (final sub in subs) {
      addTearDown(sub.close);
    }
    await until(
      () => t.calls['getRoadmap'] == 1 && t.calls['getStudyInsights'] == 1,
    );
    final reader =
        await container.read(studySnapshotReaderProvider('e').future);

    for (var i = 1; i <= 6; i++) {
      await bumpRemote(t.db, i);
    }
    t.gate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(t.errors, isEmpty);
    expect(
      identical(
        await container.read(studySnapshotReaderProvider('e').future),
        reader,
      ),
      isTrue,
    );
    expect(t.calls['getRoadmap'], lessThanOrEqualTo(2));
    expect(t.calls['getStudyInsights'], lessThanOrEqualTo(2));
    expect(t.revisions, isNotEmpty);
  });

  test('a burst of remote row notices gives one epoch revision', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyEpochDebounceProvider
            .overrideWithValue(const Duration(milliseconds: 50)),
      ],
    );
    addTearDown(container.dispose);
    final seen = <int>[];
    container.listen<AsyncValue<int>>(
      studyCoreEpochProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    await pumpEventQueue();
    for (var i = 1; i <= 6; i++) {
      await bumpRemote(db, i);
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(seen, [0], reason: 'nothing before the burst settles');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(seen, [0, 1]);
  });

  test('an owner change is immediate and replaces a pending remote revision',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyEpochDebounceProvider
            .overrideWithValue(const Duration(milliseconds: 50)),
      ],
    );
    addTearDown(container.dispose);
    final seen = <int>[];
    container.listen<AsyncValue<int>>(
      studyCoreEpochProvider,
      (_, next) => next.whenData(seen.add),
      fireImmediately: true,
    );
    await pumpEventQueue();
    await bumpRemote(db, 1);
    await db.into(db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(
            key: SyncHeldGeneration.generationKey,
            value: 'g2',
          ),
        );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(seen, [0, 1], reason: 'the owner revision lands at once');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(seen, [0, 1], reason: 'the pending remote revision is dropped');
  });

  test(
      'an owner change during a read rebuilds the reader and the stale read '
      'delivers nothing', () async {
    final t = gatedStudy();
    await SyncActiveContextStore(t.db).clearStable();
    final container = t.container;
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final sub = container.listen<AsyncValue<StudyRoadmap>>(
      serverStudyRoadmapProvider('e'),
      (_, next) => next.whenData((v) => t.revisions.add(v.revision)),
      fireImmediately: true,
    );
    addTearDown(sub.close);
    await until(() => t.calls['getRoadmap'] == 1);
    final reader =
        await container.read(studySnapshotReaderProvider('e').future);

    await t.db.into(t.db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(
            key: SyncHeldGeneration.uidKey,
            value: 'user-2',
          ),
        );
    await until(() => (t.calls['getRoadmap'] ?? 0) >= 2);
    t.gate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(
      identical(
        await container.read(studySnapshotReaderProvider('e').future),
        reader,
      ),
      isFalse,
    );
    expect(await reader.request.isCurrent(), isFalse);
    expect(t.revisions, isNot(contains('first')));
  });

  for (final local in [true, false]) {
    test('missing settings recovers or opens exam onboarding: $local',
        () async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      addTearDown(content.close);
      addTearDown(db.close);
      await SyncActiveContextStore(db).clearStable();
      await AppPreferencesRepository(db).setSelectedExamId('e');
      if (local) {
        await DriftSettingsRepository(db)
            .updateStudyDays(StudyDays(const {1, 3, 5}));
      }
      final names = <String>[];
      var saved = false;
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          authStateProvider.overrideWith(
            (_) => Stream.value(const AuthState.anonymous(uid: 'u')),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          studyApiProvider.overrideWithValue(
            StudyApi((name, data) async {
              names.add(name);
              if (name == 'setExamSettings') {
                expect(data['studyDays'], [1, 3, 5]);
                saved = true;
                return <String, Object?>{};
              }
              if (!saved) {
                throw FirebaseFunctionsException(
                  code: 'failed-precondition',
                  message: 'Set your exam first.',
                );
              }
              return {'examId': 'e'};
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authStateProvider.future);
      await container.read(activeExamFocusProvider.future);
      final reader =
          await container.read(studySnapshotReaderProvider('e').future);
      if (local) {
        expect(await reader.request.read('getRoadmap'), {'examId': 'e'});
        expect(names, ['getRoadmap', 'setExamSettings', 'getRoadmap']);
        saved = false;
        expect(await reader.request.read('getRoadmap'), {'examId': 'e'});
        expect(names.where((name) => name == 'setExamSettings'), hasLength(2));

        expect(container.read(studyNeedsExamSettingsProvider), false);
      } else {
        await expectLater(
          reader.request.read('getRoadmap'),
          throwsA(isA<FirebaseFunctionsException>()),
        );
        expect(names, ['getRoadmap']);
        expect(container.read(studyNeedsExamSettingsProvider), true);
      }
    });
  }
  test(
      'explicit settings send lesson exclusions beside topics '
      'for the original owner', () async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(content.close);
    await SyncActiveContextStore(db).clearStable();
    await AppPreferencesRepository(db).setSelectedExamId('e');
    final sent = Completer<Map<String, Object?>>();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'original')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            if (name == 'setExamSettings') sent.complete(data);
            return <String, Object?>{};
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final captured =
        await container.read(studySettingsCaptureProvider)(examId: 'e');
    await captured.apply(
      () => container
          .read(customTrackRepositoryProvider)
          .setExcluded(examId: 'e', topicIds: {'t'}, lessonIds: {'l2', 'l1'}),
    );
    final payload = await sent.future;
    expect(payload['expectedUid'], 'original');
    expect(payload['examId'], 'e');
    expect(payload['excludedTopicIds'], ['t']);
    expect(payload['excludedLessonIds'], ['l1', 'l2']);
  });

  test('native delivery sends stored observations without opening a web page',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    await AppPreferencesRepository(db).setSelectedExamId('e');
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson',
            readAt: DateTime.utc(2026, 10, 24),
          ),
        );
    final calls = <String>[];
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyUsesServerProvider.overrideWithValue(false),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'original')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            calls.add(name);
            expect(data['expectedUid'], 'original');
            return <String, Object?>{};
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final subscription =
        container.listen(studyDeliveryLifecycleProvider, (_, __) {});
    addTearDown(subscription.close);
    await container.pump();
    for (var i = 0; i < 20 && calls.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(calls, ['recordLessonRead']);
  });

  test('authoritative insight reader sends original account and exact exam',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    final calls = <Map<String, Object?>>[];
    final names = <String>[];
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        trackScopeProvider('e').overrideWith((_) async => {}),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'original')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            calls.add(data);
            names.add(name);
            return {
              'examId': 'e',
              'serverNow': 123,
              'accessRecheckAt': null,
              'proCovered': false,
              'revision': 'v1',
              'profile': null,
              'performance': {
                'overall': {'correct': 1, 'answered': 2},
                'subjects': <Object?>[],
                'lessonLevelAvailable': false,
              },
            };
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    final subscription =
        container.listen(serverStudyInsightsProvider('e'), (_, __) {});
    addTearDown(subscription.close);
    final result =
        await container.read(serverStudyInsightsProvider('e').future);
    expect(result.answered, 2);
    expect(names, ['getStudyInsights']);
    expect(calls.every((c) => c['expectedUid'] == 'original'), isTrue);
    expect(calls.every((c) => c['examId'] == 'e'), isTrue);
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson',
            readAt: DateTime.utc(2026, 10, 24),
          ),
        );
    final refreshed = Completer<void>();
    final refreshSubscription =
        container.listen(serverStudyInsightsProvider('e'), (_, next) {
      if (names.length >= 3 && next.hasValue && !refreshed.isCompleted) {
        refreshed.complete();
      }
    });
    addTearDown(refreshSubscription.close);
    container.read(roadmapRevisionProvider.notifier).bump();
    await container.pump();
    await refreshed.future.timeout(const Duration(seconds: 3));
    expect(names, [
      'getStudyInsights',
      'recordLessonRead',
      'getStudyInsights',
    ]);
  });

  test(
      'a consumer that watches coverage after an await does not refetch '
      'insights in a loop', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    var insightsReads = 0;
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyUsesServerProvider.overrideWithValue(true),
        trackScopeProvider('e').overrideWith((_) async => {}),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'u')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) async {
            if (name == 'getStudyInsights') insightsReads++;
            return {
              'examId': 'e',
              'serverNow': 123 + insightsReads,
              'accessRecheckAt': null,
              'proCovered': true,
              'revision': 'v1',
              'profile': null,
              'performance': {
                'overall': {'correct': 0, 'answered': 0},
                'subjects': <Object?>[],
                'lessonLevelAvailable': false,
              },
            };
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Like the plan and notice providers: coverage is read only after awaits,
    // so between rebuilds nothing listens to it.
    final consumer = FutureProvider.autoDispose<bool>((ref) async {
      await ref.watch(authStateProvider.future);
      await ref.watch(activeExamFocusProvider.future);
      await Future<void>.delayed(Duration.zero);
      return ref.watch(currentStudyCoverageProvider);
    });
    final subscription = container.listen(consumer, (_, __) {});
    addTearDown(subscription.close);
    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
    expect(insightsReads, lessThanOrEqualTo(2));
  });

  for (final change in ['session ingest', 'account switch']) {
    test('kept-alive insights still refetch on $change', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await SyncActiveContextStore(db).clearStable();
      final uids = <Object?>[];
      final auth = StreamController<AuthState>();
      addTearDown(auth.close);
      auth.add(const AuthState.anonymous(uid: 'a'));
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          trackScopeProvider('e').overrideWith((_) async => {}),
          authStateProvider.overrideWith((_) => auth.stream),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          studyApiProvider.overrideWithValue(
            StudyApi((name, data) async {
              if (name == 'getStudyInsights') uids.add(data['expectedUid']);
              return {
                'examId': 'e',
                'serverNow': 1,
                'accessRecheckAt': null,
                'proCovered': false,
                'revision': 'v1',
                'profile': null,
                'performance': {
                  'overall': {'correct': 0, 'answered': 0},
                  'subjects': <Object?>[],
                  'lessonLevelAvailable': false,
                },
              };
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription =
          container.listen(serverStudyInsightsProvider('e'), (_, __) {});
      addTearDown(subscription.close);
      await container.read(serverStudyInsightsProvider('e').future);
      expect(uids, ['a']);
      if (change == 'session ingest') {
        container
            .read(quizSessionPanelRevisionProvider.notifier)
            .publishCompletion();
      } else {
        auth.add(const AuthState.anonymous(uid: 'b'));
      }
      for (var i = 0; i < 40 && uids.length < 2; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(uids.length, greaterThanOrEqualTo(2));
      expect(uids.last, change == 'session ingest' ? 'a' : 'b');
    });
  }
}
