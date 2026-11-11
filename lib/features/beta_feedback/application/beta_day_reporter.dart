import 'dart:async';

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, ComparableExpr;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

/// The beta runs in the browser; the phone apps have no testers to report.
final betaDayReporterEnabledProvider = Provider<bool>((ref) => kIsWeb);

/// Local dates on which a day is reported. The server decides the real
/// Philippine date, so the window is a day wider on each side of Nov 9 to 15.
bool _inReportWindow(DateTime now) =>
    now.year == 2026 && now.month == 11 && now.day >= 8 && now.day <= 16;

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Tells the server when a selected tester finishes a day, once per local
/// date: the whole Today plan, or on a rest day a finished Today topic,
/// interleaved or new-questions session. The date is remembered on this
/// device only after the server accepts it. A failure stays silent and the
/// next app open or finished session tries again.
///
/// Limit: a tab left open from before Nov 8 never starts watching. The day
/// counts once the page is reloaded.
final betaDayReporterProvider = Provider<void>((ref) {
  if (!ref.watch(betaDayReporterEnabledProvider)) return;
  final clock = ref.watch(betaFeedbackClockProvider);
  // Check the window first so no one outside it is asked about beta access.
  if (!_inReportWindow(clock())) return;
  if (!ref.watch(betaFeedbackVisibleProvider)) return;
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  final examId = ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id;
  if (uid == null || examId == null) return;

  var alive = true;
  ref.onDispose(() => alive = false);
  RoadmapToday? latest;
  var busy = false;
  final key = 'beta_day_reported_$uid';

  Future<void> report(BetaDayKind kind) async {
    if (busy) return;
    busy = true;
    try {
      final now = clock();
      final prefs = ref.read(appPreferencesRepositoryProvider);
      if (await prefs.deviceValue(key) == _dateKey(now)) return;
      await ref.read(betaFeedbackApiProvider).recordDay(kind);
      await prefs.setDeviceValue(key, _dateKey(now));
      if (alive) ref.invalidate(betaRewardProvider);
    } on Object {
      // Silent by design. Nothing is stored, so the next trigger retries.
    } finally {
      busy = false;
    }
  }

  Future<void> evaluate() async {
    final today = latest;
    final now = clock();
    // A plan kept in memory from yesterday says nothing about today.
    if (today == null || !_sameDay(today.snapshot.plan.day, now)) return;
    if (!_inReportWindow(now)) return;
    if (!today.snapshot.plan.isRestDay) {
      if (today.originalDone) await report(BetaDayKind.plan);
    } else if (await _finishedStreakSession(ref, now)) {
      await report(BetaDayKind.restDay);
    }
  }

  ref
    ..listen(
      roadmapTodayProvider(examId),
      (_, next) {
        // A reload in progress still holds the old value, which is not news.
        if (next case AsyncData(:final value)) {
          latest = value;
          unawaited(evaluate());
        }
      },
      fireImmediately: true,
    )
    ..listen(quizSessionPanelRevisionProvider, (_, __) {
      unawaited(evaluate());
    });
});

/// Whether a streak-eligible session was completed on [day], local time.
/// A completed attempt has every question answered.
Future<bool> _finishedStreakSession(Ref ref, DateTime day) async {
  final db = ref.read(appDatabaseProvider);
  final start = DateTime(day.year, day.month, day.day);
  final end = DateTime(day.year, day.month, day.day + 1);
  final rows = await (db.select(db.attemptsLocal)
        ..where(
          (a) =>
              a.completedAt.isBiggerOrEqualValue(start) &
              a.completedAt.isSmallerThanValue(end),
        ))
      .get();
  return rows
      .any((row) => SessionOrigin.fromStorage(row.origin).isStreakEligible);
}
