import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm, TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/pull_pipeline.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_held_generation.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_observations.dart';
import 'package:pantas/features/home/data/study_read_cache.dart';
import 'package:pantas/features/home/data/study_snapshot_reader.dart';
import 'package:pantas/features/home/data/study_writes.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/quiz/application/quiz_launch_guard.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

/// A no-settings response without locally saved settings needs the exam step.
final studyNeedsExamSettingsProvider = StateProvider<bool>((ref) {
  ref.watch(authStateProvider);
  return false;
});

/// The sync_meta rows that say who owns the local data.
const _studyOwnerKeys = <String>[
  SyncActiveContextStore.metaKey,
  SyncHeldGeneration.generationKey,
  SyncHeldGeneration.uidKey,
];

/// How long a remote-row notice waits for a quieter moment before it moves
/// the combined epoch. A first sync on a second device applies one collection
/// at a time, each with its own notice, in about a second. 750 ms is longer
/// than the gaps inside that burst, so a burst gives one revision, and short
/// enough that Home still refreshes within a blink after the last collection.
const studyEpochDebounce = Duration(milliseconds: 750);

/// Injectable so tests settle in milliseconds.
final studyEpochDebounceProvider =
    Provider<Duration>((ref) => studyEpochDebounce);

Future<String> _metaEnvelope(AppDatabase db, List<String> keys) async {
  final rows = await (db.select(db.syncMeta)
        ..where((meta) => meta.key.isIn(keys))
        ..orderBy([(meta) => OrderingTerm.asc(meta.key)]))
      .get();
  return rows.map((row) => '${row.key}=${row.value}').join('\n');
}

/// Moves only when the owner changes: the active context, the local
/// generation and its owner. A remote data change never moves it, so it never
/// rebuilds the study reader or fails a read in flight.
// Only rows that mean the owner changed count: bookkeeping (snapshot marks,
// the full pull and push markers, the backup time, the device id) does not.
// Counting it rebuilt the study reader on every sync step and failed Home's
// plan read in flight ("Study owner changed"); a first sync writes such rows
// for longer than Home retries (Nov 10). The active context counts: its token
// changes only when the owner changes or a full snapshot replaces the data,
// and a local wipe removes it.
final studyOwnerEpochProvider = StreamProvider.autoDispose<int>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  var revision = 0;
  var last = await _metaEnvelope(db, _studyOwnerKeys);
  yield revision;
  await for (final _
      in db.tableUpdates(TableUpdateQuery.onTable(db.syncMeta))) {
    final next = await _metaEnvelope(db, _studyOwnerKeys);
    if (next == last) continue;
    last = next;
    yield ++revision;
  }
});

/// The combined revision: the owner keys plus the marker Sync moves when
/// another device's rows arrive. Plan, record and how-you-work refresh on it,
/// and so do the server roadmap and insights reads (not the reader).
/// An owner change yields at once and replaces any pending remote revision.
/// A remote change alone waits [studyEpochDebounceProvider] after the last
/// notice, so a burst gives one revision.
final studyCoreEpochProvider = StreamProvider.autoDispose<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final delay = ref.watch(studyEpochDebounceProvider);
  final out = StreamController<int>();
  Timer? pending;
  var closed = false;
  StreamSubscription<void>? updates;
  ref.onDispose(() {
    closed = true;
    pending?.cancel();
    unawaited(updates?.cancel());
    unawaited(out.close());
  });

  Future<void> start() async {
    var revision = 0;
    var lastOwner = await _metaEnvelope(db, _studyOwnerKeys);
    var lastRemote = await _metaEnvelope(db, [PullPipeline.remoteChangeKey]);
    if (closed) return;
    out.add(revision);
    // Notices are handled one at a time, in order.
    var chain = Future<void>.value();
    updates =
        db.tableUpdates(TableUpdateQuery.onTable(db.syncMeta)).listen((_) {
      chain = chain.then((_) async {
        if (closed) return;
        final owner = await _metaEnvelope(db, _studyOwnerKeys);
        final remote = await _metaEnvelope(db, [PullPipeline.remoteChangeKey]);
        if (closed) return;
        if (owner != lastOwner) {
          lastOwner = owner;
          lastRemote = remote;
          pending?.cancel();
          pending = null;
          out.add(++revision);
        } else if (remote != lastRemote) {
          lastRemote = remote;
          pending?.cancel();
          pending = Timer(delay, () {
            pending = null;
            if (!closed) out.add(++revision);
          });
        }
      });
    });
  }

  unawaited(start());
  return out.stream;
});

final studyUsesServerProvider = Provider<bool>((ref) => kIsWeb);
final studyApiProvider = Provider<StudyApi>((ref) => StudyApi.firebase());

final studyWritesProvider = Provider<StudyWrites>((ref) {
  ref.watch(appDatabaseProvider);
  return StudyWrites();
});

final studySnapshotReaderProvider = FutureProvider.autoDispose
    .family<StudySnapshotReader, String>((ref, examId) async {
  var alive = true;
  ref.onDispose(() => alive = false);
  await ref.watch(studyOwnerEpochProvider.future);
  final auth = await ref.watch(authStateProvider.future);
  final uid = switch (auth) {
    SignedInAuthState(:final user) => user.uid,
    AnonymousAuthState(:final uid) => uid,
    _ => null,
  };
  if (uid == null) throw StateError('Study account unavailable');
  final focus = await ref.watch(activeExamFocusProvider.future);
  if (focus.exam?.id != examId) throw StateError('Study exam changed');
  final db = ref.watch(appDatabaseProvider);
  final captured =
      await captureQuizLaunchGuard(ref, examId: examId, isAlive: () => alive);
  // The token can change with no write this provider hears of, such as Sync
  // publishing its context. The read in hand still fails, and the next one
  // gets a new guard instead of failing the same way for good.
  Future<bool> guard() async {
    final current = await captured();
    if (!current && alive) ref.invalidateSelf();
    return current;
  }

  final original = await SyncActiveContextStore(db).readSnapshot();
  if (!await guard()) throw StateError('Study owner changed');
  Future<bool>? repair;
  Future<bool> recover() {
    final pending = repair;
    if (pending != null) return pending;
    final result = () async {
      final selected =
          await ref.read(appPreferencesRepositoryProvider).selectedExamId();
      final days = await (db.select(db.accountPrefs)
            ..where((p) => p.key.equals(SettingsPrefKeys.studyDays)))
          .getSingleOrNull();
      if (!await guard()) throw StateError('Study owner changed');
      if (selected != examId || days == null || days.value.isEmpty) {
        ref.read(studyNeedsExamSettingsProvider.notifier).state = true;
        return false;
      }
      final payload = await readStudySettingsPayload(ref, examId);
      final saveRequest = StudyRequest(
        api: ref.read(studyApiProvider),
        uid: uid,
        examId: examId,
        isCurrent: guard,
      );
      await ref.read(studyWritesProvider).settings(saveRequest, payload);
      return true;
    }();
    repair = result;
    unawaited(
      result.then<void>(
        (_) {
          repair = null;
        },
        onError: (Object _, StackTrace __) {
          repair = null;
        },
      ),
    );
    return result;
  }

  final request = StudyRequest(
    api: ref.watch(studyApiProvider),
    uid: uid,
    examId: examId,
    isCurrent: guard,
    recoverMissingSettings: recover,
  );
  final observations = StudyObservations(
    db,
    request: request,
    coreToken: original?.token ?? 'uninitialized',
  );
  return StudySnapshotReader(
    request: request,
    recordError: ref.read(telemetryProvider).recordError,
    // Reads upload actual observations, never a new settings intent. Default
    // local settings on a restored device must not overwrite server settings.
    beforeRead: () async {
      await ref.read(studyWritesProvider).retrySettings();
      await observations.flush();
    },
    cache: StudyReadCache(
      db,
      uid: uid,
      examId: examId,
      coreToken: original?.token ?? 'uninitialized',
      isCurrent: guard,
    ),
  );
});

void _expiry(Ref ref, StudyEnvelope value, Duration elapsed) {
  final deadline = value.accessRecheckAt;
  if (deadline == null) return;
  final remaining = deadline - value.serverNow - elapsed.inMilliseconds;
  final timer = Timer(
    Duration(milliseconds: remaining.clamp(1, 0x7fffffff)),
    ref.invalidateSelf,
  );
  ref.onDispose(timer.cancel);
}

/// Reads one study kind for [serverStudyInsightsProvider] and
/// [serverStudyRoadmapProvider]. The caller watches the reader and the epoch
/// in its own body, not here: a generator body starts after the old
/// dependencies are dropped, which would dispose the reader between rebuilds.
Stream<T> _serverStudyRead<T extends StudyEnvelope>(
  Ref ref, {
  required Future<StudySnapshotReader> reader,
  required Future<int> epoch,
  required String kind,
  required T Function(Object? raw) decode,
}) async* {
  var alive = true;
  ref.onDispose(() => alive = false);
  await epoch;
  final snapshot = await reader;
  final elapsed = Stopwatch()..start();
  try {
    await for (final raw in snapshot.read(kind)) {
      final value = decode(raw);
      _expiry(ref, value, elapsed.elapsed);
      yield value;
    }
  } catch (_) {
    // A read this provider has already replaced (owner change, refresh) has
    // nobody to tell and delivers nothing. A live read still reports.
    if (alive) rethrow;
  }
}

final serverStudyInsightsProvider =
    StreamProvider.autoDispose.family<StudyInsights, String>((ref, examId) {
  // Kept alive so a consumer that re-watches coverage after an await cannot
  // drop it and trigger a fetch loop. Refreshes still come from the session
  // and roadmap revisions, the epoch (another device's rows), the reader
  // (account, exam, owner), the access deadline and explicit invalidation.
  ref
    ..keepAlive()
    ..watch(quizSessionPanelRevisionProvider)
    ..watch(roadmapRevisionProvider);
  return _serverStudyRead(
    ref,
    reader: ref.watch(studySnapshotReaderProvider(examId).future),
    epoch: ref.watch(studyCoreEpochProvider.future),
    kind: 'getStudyInsights',
    decode: (raw) => StudyInsights.decode(raw, examId: examId),
  );
});

final serverStudyRoadmapProvider =
    StreamProvider.autoDispose.family<StudyRoadmap, String>((ref, examId) {
  // Same keep-alive and refresh sources as the insights provider.
  ref
    ..keepAlive()
    ..watch(quizSessionPanelRevisionProvider)
    ..watch(roadmapRevisionProvider);
  return _serverStudyRead(
    ref,
    reader: ref.watch(studySnapshotReaderProvider(examId).future),
    epoch: ref.watch(studyCoreEpochProvider.future),
    kind: 'getRoadmap',
    decode: (raw) => StudyRoadmap.decode(raw, examId: examId),
  );
});

/// Web depth follows current server coverage. Loading/expired reads cannot
/// reuse a retained paid value from a previous state.
final currentStudyCoverageProvider = Provider.autoDispose<bool>((ref) {
  if (!ref.watch(studyUsesServerProvider)) {
    // Native entitlement keeps its accepted value during offline refresh.
    return ref.watch(proForActiveExamProvider).valueOrNull ?? false;
  }
  final exam = ref
      .watch(activeExamFocusProvider)
      .unwrapPrevious()
      .asData
      ?.value
      .exam
      ?.id;
  if (exam == null) return false;
  return ref
          .watch(serverStudyInsightsProvider(exam))
          .unwrapPrevious()
          .asData
          ?.value
          .proCovered ??
      false;
});

/// Retained paid values cannot turn an unresolved coverage check into Free.
final studyCoverageLoadingProvider = Provider.autoDispose<bool>((ref) {
  if (!ref.watch(studyUsesServerProvider)) {
    final coverage = ref.watch(proForActiveExamProvider);
    return coverage.isLoading && !coverage.hasValue;
  }
  final focus = ref.watch(activeExamFocusProvider);
  final exam = focus.valueOrNull?.exam;
  if (exam == null) return focus.isLoading;
  return ref.watch(serverStudyInsightsProvider(exam.id)).isLoading;
});
