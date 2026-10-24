import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_read_cache.dart';
import 'package:pantas/features/home/data/study_snapshot_reader.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/quiz/application/quiz_launch_guard.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

final studyUsesServerProvider = Provider<bool>((ref) => kIsWeb);
final studyApiProvider = Provider<StudyApi>((ref) => StudyApi.firebase());

final studySnapshotReaderProvider = FutureProvider.autoDispose
    .family<StudySnapshotReader, String>((ref, examId) async {
  var alive = true;
  ref.onDispose(() => alive = false);
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
  return StudySnapshotReader(
    request: StudyRequest(
      api: ref.watch(studyApiProvider),
      uid: uid,
      examId: examId,
      isCurrent: guard,
    ),
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
  ref.watch(quizSessionPanelRevisionProvider);
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
  ref.watch(quizSessionPanelRevisionProvider);
  final reader = await ref.watch(studySnapshotReaderProvider(examId).future);
  final elapsed = Stopwatch()..start();
  await for (final raw in reader.read('getRoadmap')) {
    final value = StudyRoadmap.decode(raw, examId: examId);
    _expiry(ref, value, elapsed.elapsed);
    yield value;
  }
});
