import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_observations.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

typedef StudySettingsCapture = Future<StudySettingsPublication> Function({
  String? examId,
});

class StudySettingsPublication {
  StudySettingsPublication(this._publish, {void Function()? cancel})
      : _cancel = cancel;
  final Future<void> Function() _publish;
  final void Function()? _cancel;
  Future<void> call() => _publish();
  Future<T> apply<T>(Future<T> Function() mutation) async {
    try {
      final result = await mutation();
      await _publish();
      return result;
    } catch (_) {
      _cancel?.call();
      rethrow;
    }
  }
}

/// Captured before a local mutation. No settings are sent by opening a page.
/// Offline failures retain the queue's immutable original-owner retry.
final studySettingsCaptureProvider = Provider<StudySettingsCapture>((ref) {
  final telemetry = ref.read(telemetryProvider);
  return ({String? examId}) async {
    final intent = ref.read(studyWritesProvider).beginSettings(
          examId:
              examId ?? ref.read(activeExamFocusProvider).valueOrNull?.exam?.id,
        );
    final captured = await _request(ref, examId: examId)
        .catchError((Object error, StackTrace stack) {
      intent.cancel();
      Error.throwWithStackTrace(error, stack);
    });
    if (captured == null) {
      intent.cancel();
      return StudySettingsPublication(() async {});
    }
    final (request, _) = captured;
    return StudySettingsPublication(
      () async {
        if (!await request.isCurrent()) {
          intent.cancel();
          return;
        }
        final settings =
            await ref.read(settingsRepositoryProvider).readUserSettings();
        final scope = await ref
            .read(customTrackRepositoryProvider)
            .excludedTopicIds(request.examId);
        final assessed = await ref
            .read(assessmentRepositoryProvider)
            .hasCompletedForExam(request.examId);
        if (!await request.isCurrent()) {
          intent.cancel();
          return;
        }
        final date = settings.examDate;
        final payload = <String, Object?>{
          'examDate': date == null
              ? null
              : date.day != null
                  ? {'precision': 'day', 'day': date.storageValue}
                  : {
                      'precision': 'month',
                      'year': date.year,
                      'month': date.month,
                    },
          'studyDays': settings.studyDays.weekdays.toList()..sort(),
          'excludedTopicIds': scope.toList()..sort(),
          'assessmentCompleted': assessed,
        };
        unawaited(
          intent.publish(request, payload).then<void>(
            (_) {
              ref.read(roadmapRevisionProvider.notifier).bump();
            },
            onError: (Object error, StackTrace stack) =>
                unawaited(telemetry.recordError(error, stack)),
          ),
        );
      },
      cancel: intent.cancel,
    );
  };
});

Future<(StudyRequest, String)?> _request(Ref ref, {String? examId}) async {
  var alive = true;
  ref.onDispose(() => alive = false);
  final auth = ref.read(authStateProvider).unwrapPrevious().asData?.value;
  final uid = switch (auth) {
    SignedInAuthState(:final user) => user.uid,
    AnonymousAuthState(:final uid) => uid,
    _ => null,
  };
  // Startup tests and a signed-out shell have no account to publish to.
  if (uid == null) return null;
  final db = ref.read(appDatabaseProvider);
  final prefs = ref.read(appPreferencesRepositoryProvider);
  final preparer = ref.read(todayQuizPreparerProvider);
  final lifetime = preparer.accountLifetimeToken;
  final original = await SyncActiveContextStore(db).readSnapshot();
  if (original?.context != null && original!.context!.uid != uid) return null;
  final target = examId ?? await prefs.selectedExamId();
  if (target == null || target.startsWith('exam_custom_')) return null;
  Future<bool> current() async {
    if (!alive ||
        !identical(ref.read(appDatabaseProvider), db) ||
        ref.read(authStateProvider).unwrapPrevious().asData?.value != auth ||
        preparer.accountLifetimeToken != lifetime) {
      return false;
    }
    final snapshot = await SyncActiveContextStore(db).readSnapshot();
    final selected = await prefs.selectedExamId();
    return snapshot?.token == original?.token &&
        selected == target &&
        ref.read(authStateProvider).unwrapPrevious().asData?.value == auth;
  }

  return (
    StudyRequest(
      api: ref.read(studyApiProvider),
      uid: uid,
      examId: target,
      isCurrent: current,
    ),
    original?.token ?? 'uninitialized'
  );
}

/// Both platforms send measured observations. Mock submission remains owned by
/// the server's existing atomic mock sender, so it is never ingested here.
final studyObservationDeliveryProvider =
    Provider<Future<void> Function()>((ref) {
  return () async {
    final captured = await _request(ref);
    if (captured == null) return;
    final (request, token) = captured;
    await ref.read(studyWritesProvider).retrySettings();
    await StudyObservations(
      ref.read(appDatabaseProvider),
      request: request,
      coreToken: token,
    ).flush();
  };
});

/// Retry stored observations after startup and actual terminal/read boundaries.
/// Settings are sent only by an explicit intent, never by this watcher.
final studyDeliveryLifecycleProvider = Provider<void>((ref) {
  final telemetry = ref.read(telemetryProvider);
  final auth = ref.watch(authStateProvider).unwrapPrevious().asData?.value;
  if (auth is! SignedInAuthState && auth is! AnonymousAuthState) return;
  ref
    ..watch(quizSessionPanelRevisionProvider)
    ..watch(roadmapRevisionProvider);
  unawaited(
    ref.read(studyObservationDeliveryProvider)().then<void>(
          (_) {},
          onError: (Object error, StackTrace stack) =>
              unawaited(telemetry.recordError(error, stack)),
        ),
  );
});
