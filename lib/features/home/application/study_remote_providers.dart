import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
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

/// Watch the existing data-boundary envelope. No second owner/cache is stored.
final studyCoreEpochProvider = StreamProvider.autoDispose<int>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  var revision = 0;
  yield revision;
  await for (final _
      in db.tableUpdates(TableUpdateQuery.onTable(db.syncMeta))) {
    yield ++revision;
  }
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
  await ref.watch(studyCoreEpochProvider.future);
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
  final guard =
      await captureQuizLaunchGuard(ref, examId: examId, isAlive: () => alive);
  final original = await SyncActiveContextStore(db).readSnapshot();
  if (!await guard()) throw StateError('Study owner changed');
  final request = StudyRequest(
    api: ref.watch(studyApiProvider),
    uid: uid,
    examId: examId,
    isCurrent: guard,
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

final serverStudyInsightsProvider = StreamProvider.autoDispose
    .family<StudyInsights, String>((ref, examId) async* {
  ref
    ..watch(quizSessionPanelRevisionProvider)
    ..watch(roadmapRevisionProvider);
  final reader = await ref.watch(studySnapshotReaderProvider(examId).future);
  final elapsed = Stopwatch()..start();
  await for (final raw in reader.read('getStudyInsights')) {
    final value = StudyInsights.decode(raw, examId: examId);
    _expiry(ref, value, elapsed.elapsed);
    yield value;
  }
});

final serverStudyRoadmapProvider = StreamProvider.autoDispose
    .family<StudyRoadmap, String>((ref, examId) async* {
  ref
    ..watch(quizSessionPanelRevisionProvider)
    ..watch(roadmapRevisionProvider);
  final reader = await ref.watch(studySnapshotReaderProvider(examId).future);
  final elapsed = Stopwatch()..start();
  await for (final raw in reader.read('getRoadmap')) {
    final value = StudyRoadmap.decode(raw, examId: examId);
    _expiry(ref, value, elapsed.elapsed);
    yield value;
  }
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
