import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/platform/account_access.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/pull_pipeline.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

/// Staging, Nov 15: a fresh device with server history read the plan
/// (`getRoadmap`) 17 times in 45 seconds during its first sync, against 3
/// expected. Each pulled batch moved the remote-change marker, the epoch
/// debounce (750 ms) was shorter than the gap between batches, and every
/// move re-read the plan. A Pro plan also made its own second `getRoadmap`
/// read on each rebuild, which synced settings rows triggered.
///
/// Time is scaled down: the debounce is 60 ms and the batches are 150 ms
/// apart, the same 2.5 ratio as 750 ms against batches about 1.9 s apart.
///
/// The read cap per kind for one sync, with the plan on screen (Pro):
///   - 1 read when Home starts,
///   - 1 read when Sync publishes the new account context at its start (the
///     owner changed, so the reader is rebuilt),
///   - 1 read when the sync settles and shows what arrived,
///   - 0 extra for the Pro history: the first read already carries it
///     (the server defaults `historyLimit` to 5, the value the plan asked
///     for, so the second read returned the same payload).
/// So at most 3 `getRoadmap` and at most 3 `getStudyInsights`.
const _debounce = Duration(milliseconds: 60);
const _gap = Duration(milliseconds: 150);
const _readCap = 3;
const _maxHold = Duration(milliseconds: 400);

/// Fake time: the test clock moves only when a test waits, in 10 ms steps so
/// timers and database streams run in order. Nothing waits in real time.
late WidgetTester _tester;

Future<void> wait(Duration total) async {
  for (var left = total;
      left > Duration.zero;
      left -= const Duration(milliseconds: 10)) {
    await _tester.pump(const Duration(milliseconds: 10));
  }
}

void main() {
  Map<String, Object?> plan() => {
        'day': '2026-10-24',
        'lessonIds': ['l1'],
        'reviewQuestionIds': <String>[],
        'newQuestionIds': <String>[],
        'advancedIds': <String>[],
        'isMockDay': false,
        'isRestDay': false,
      };

  Map<String, Object?> roadmap(String revision) => {
        'examId': 'e',
        'serverNow': 100,
        'accessRecheckAt': null,
        'proCovered': true,
        'revision': revision,
        'state': 'planning',
        'today': plan(),
        'remaining': plan(),
        'originalDone': false,
        'canAdvance': false,
        'todayTopicOrder': ['t'],
        'weekDays': [
          for (var i = 0; i < 7; i++) {'state': i == 6 ? 'today' : 'unknown'},
        ],
        'comingUp': {
          'examDay': null,
          'reviewOnlyFrom': null,
          'mockDay': null,
          'weeksAhead': <Object?>[],
        },
        'history': {'changes': <Object?>[], 'next': null},
      };

  Map<String, Object?> insights(String revision) => {
        'examId': 'e',
        'serverNow': 123,
        'accessRecheckAt': null,
        'proCovered': true,
        'revision': revision,
        'profile': null,
        'performance': {
          'overall': {'correct': 0, 'answered': 0},
          'subjects': <Object?>[],
          'lessonLevelAvailable': false,
        },
      };

  Future<void> pullBatch(AppDatabase db, int n) => PullPipeline(
        db: db,
        queue: PendingQueue(db),
        uid: 'u',
        generationId: 'g',
        deviceId: 'this-device',
      ).applyCompleteSnapshot(
        generationId: 'g',
        collection: 'lesson_progress',
        documents: [
          SyncDocument(
            id: 'lesson-$n',
            data: {
              'lessonId': 'lesson-$n',
              'readAt': '2026-11-09T08:00:00.000Z',
              'updatedAt': DateTime.utc(2026, 11, 9, 8, n),
              'originDeviceId': 'other-device',
              'mutationId': 'other-$n',
              'deleted': false,
              'schemaVersion': 1,
            },
          ),
        ],
      );

  Future<void> settingsRow(AppDatabase db, int n) =>
      db.into(db.accountPrefs).insertOnConflictUpdate(
            AccountPrefsCompanion.insert(
              key: SettingsPrefKeys.name,
              value: 'Name $n',
            ),
          );

  Future<void> until(bool Function() done) async {
    for (var i = 0; i < 300 && !done(); i++) {
      await wait(const Duration(milliseconds: 10));
    }
  }

  Future<
      ({
        ProviderContainer container,
        AppDatabase db,
        Map<String, int> calls,
        StreamController<SyncStatus> status,
      })> start({
    Future<Object?> Function(Future<Object?> Function() send)? around,
  }) async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(content.close);
    addTearDown(db.close);
    await SyncActiveContextStore(db).clearStable();
    final calls = <String, int>{};
    final status = StreamController<SyncStatus>.broadcast();
    addTearDown(status.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        studyUsesServerProvider.overrideWithValue(true),
        studyEpochDebounceProvider.overrideWithValue(_debounce),
        studyEpochMaxHoldProvider.overrideWithValue(_maxHold),
        trackScopeProvider('e').overrideWith((_) async => {}),
        syncStatusProvider.overrideWith((_) => status.stream),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'u')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        studyApiProvider.overrideWithValue(
          StudyApi((name, data) {
            Future<Object?> send() async {
              final n = calls[name] = (calls[name] ?? 0) + 1;
              final revision = 'r$n';
              return name == 'getRoadmap'
                  ? roadmap(revision)
                  : insights(revision);
            }

            return around == null ? send() : around(send);
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    return (container: container, db: db, calls: calls, status: status);
  }

  /// Home on screen: the plan, the record's insights and Today's roadmap.
  void watchHome(ProviderContainer container) {
    for (final sub in [
      container.listen(serverStudyRoadmapProvider('e'), (_, __) {}),
      container.listen(serverStudyInsightsProvider('e'), (_, __) {}),
      container.listen(planViewProvider(5), (_, __) {}),
      container.listen(roadmapTodayProvider('e'), (_, __) {}),
    ]) {
      addTearDown(sub.close);
    }
  }

  testWidgets(
      'one first sync reads the plan at most three times, any batch count',
      (tester) async {
    _tester = tester;
    final t = await start();
    watchHome(t.container);
    await until(() => (t.calls['getRoadmap'] ?? 0) >= 1);
    await firstReads();
    t.status.add(const Syncing());
    await SyncActiveContextStore(t.db).publishStable(
      uid: 'u',
      generationId: 'gen-1',
    );

    for (var n = 1; n <= 8; n++) {
      await wait(_gap);
      await pullBatch(t.db, n);
      await settingsRow(t.db, n);
    }
    t.status.add(const SyncUpToDate());
    await wait(_gap * 3);

    expect(
      t.calls['getRoadmap'],
      lessThanOrEqualTo(_readCap),
      reason: 'getRoadmap: ${t.calls}',
    );
    expect(
      t.calls['getStudyInsights'],
      lessThanOrEqualTo(_readCap),
      reason: 'getStudyInsights: ${t.calls}',
    );
  });

  testWidgets(
      'what another device wrote still shows once after the sync settles',
      (tester) async {
    _tester = tester;
    final t = await start();
    watchHome(t.container);
    await until(() => (t.calls['getRoadmap'] ?? 0) >= 1);
    await firstReads();
    final before = t.calls['getRoadmap']!;
    t.status.add(const Syncing());
    await wait(const Duration(milliseconds: 20));

    for (var n = 1; n <= 4; n++) {
      await wait(_gap);
      await pullBatch(t.db, n);
    }
    t.status.add(const SyncUpToDate());
    await wait(_gap * 3);

    expect(t.calls['getRoadmap'], before + 1, reason: '${t.calls}');
  });

  testWidgets('a change from another device after the sync still shows, once',
      (tester) async {
    _tester = tester;
    final t = await start();
    watchHome(t.container);
    await until(() => (t.calls['getRoadmap'] ?? 0) >= 1);
    await firstReads();
    final before = t.calls['getRoadmap']!;

    await pullBatch(t.db, 1);
    await wait(_gap * 3);

    expect(t.calls['getRoadmap'], before + 1, reason: '${t.calls}');
  });

  testWidgets('a sync that never reports settled still refreshes the plan',
      (tester) async {
    _tester = tester;
    final t = await start();
    watchHome(t.container);
    await until(() => (t.calls['getRoadmap'] ?? 0) >= 1);
    await firstReads();
    final before = t.calls['getRoadmap']!;
    t.status.add(const Syncing());
    await wait(const Duration(milliseconds: 20));

    await pullBatch(t.db, 1);
    await wait(_maxHold + _gap * 3);

    expect(t.calls['getRoadmap'], greaterThan(before), reason: '${t.calls}');
  });

  // The sign-in token can expire while a tab sits idle. The first call comes
  // back "unauthenticated", the account layer renews the token and sends it
  // once more, and Home must still get its plan from that second call.
  testWidgets('Home still loads its plan after an expired sign-in',
      (tester) async {
    _tester = tester;
    var refused = 0;
    var renewed = 0;
    final access = AccountAccess(
      refreshToken: (_) async {
        renewed++;
        return true;
      },
    );
    final t = await start(
      around: (send) => access.run<Object?>('u', () async {
        if (refused++ == 0) {
          throw FirebaseFunctionsException(
            message: 'expired',
            code: 'unauthenticated',
          );
        }
        return send();
      }),
    );
    final plan = t.container.listen(planViewProvider(5), (_, __) {});
    addTearDown(plan.close);
    watchHome(t.container);
    final view = await t.container.read(planViewProvider(5).future);

    expect(renewed, 1);
    expect(view.state, RoadmapState.planning);
    expect(t.container.read(serverStudyRoadmapProvider('e')).hasError, isFalse);
    expect(t.calls['getRoadmap'], 1, reason: '${t.calls}');
    // Leave no timer behind for the test binding's end-of-test check.
    t.container.dispose();
    await wait(const Duration(milliseconds: 100));
  });

  // The lesson page bumps the roadmap revision when a lesson is marked read.
  // The plan, the record and Today refresh once for that, with no extra
  // Pro history read.
  testWidgets('finishing a lesson refreshes the plan once', (tester) async {
    _tester = tester;
    final t = await start();
    watchHome(t.container);
    await until(() => (t.calls['getRoadmap'] ?? 0) >= 1);
    await firstReads();
    final before = Map<String, int>.of(t.calls);

    t.container.read(roadmapRevisionProvider.notifier).bump();
    await wait(_gap * 3);

    expect(t.calls['getRoadmap'], before['getRoadmap']! + 1);
    expect(t.calls['getStudyInsights'], before['getStudyInsights']! + 1);
    expect(
      (await t.container.read(planViewProvider(5).future)).state,
      RoadmapState.planning,
    );
  });
}

/// Lets the first reads finish before the sync starts.
Future<void> firstReads() => wait(const Duration(milliseconds: 150));
