import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/notifications/application/reminder_service.dart';
import 'package:pantas/features/notifications/data/flutter_local_notifications_gateway.dart';
import 'package:pantas/features/notifications/data/inert_notifications_gateway.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/data/reminder_activity_reader.dart';
import 'package:pantas/features/notifications/domain/notification_body_composer.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/application/trial_ending_notifier.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

const _studyDaysKey = 'settings.study_days';

final notificationStudyDaysReaderProvider =
    Provider<Future<StudyDays> Function()>((ref) {
  return () async {
    final db = ref.read(appDatabaseProvider);
    final row = await (db.select(db.accountPrefs)
          ..where((pref) => pref.key.equals(_studyDaysKey)))
        .getSingleOrNull();
    return StudyDays.fromStorage(row?.value);
  };
});

/// Local wall-clock time for scheduling. A provider so tests can fix the
/// hour: whether a reminder fires today or on a later day depends on it.
final notificationClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

/// Inert by default, and overridden in `bootstrap` with the real plugin.
///
/// The same seam `telemetrySinkProvider` uses. Before 12 August this built the
/// live gateway everywhere, which was safe only because the old plugin stayed
/// quiet with no platform behind it. Version 22 throws instead.
final notificationsGatewayProvider = Provider<NotificationsGateway>((ref) {
  return InertNotificationsGateway();
});

/// The real one. `bootstrap` points [notificationsGatewayProvider] at this.
final liveNotificationsGatewayProvider = Provider<NotificationsGateway>((ref) {
  return FlutterLocalNotificationsGateway();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final settings = DriftSettingsRepository(db);
  Future<ComeBackReservation?> readReservation() async {
    final row = await (db.select(db.devicePrefs)
          ..where((p) => p.key.equals('notifications.come_back')))
        .getSingleOrNull();
    if (row == null) return null;
    final parts = row.value.split('|');
    if (parts.length != 2) return null;
    final last = DateTime.tryParse(parts[0]);
    final fire = DateTime.tryParse(parts[1]);
    return last == null || fire == null
        ? null
        : ComeBackReservation(lastSessionAt: last, fireAt: fire);
  }

  final service = ReminderService(
    gateway: ref.watch(notificationsGatewayProvider),
    now: () => ref.read(notificationClockProvider)(),
    prefsReader: settings.readReminderPrefs,
    studyDaysReader: () => ref.read(notificationStudyDaysReaderProvider)(),
    reservationReader: readReservation,
    reservationWriter: (value) => db
        .into(db.devicePrefs)
        .insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: 'notifications.come_back',
            value: '${value.lastSessionAt.toIso8601String()}|'
                '${value.fireAt.toIso8601String()}',
          ),
        )
        .then((_) {}),
    examReader: () async {
      final focus = await ref.read(activeExamFocusProvider.future);
      final exam = focus.exam;
      if (exam == null) return const ReminderExamSnapshot();
      final prefs = await settings.readUserSettings();
      final flags = await db.select(db.questionFlagsLocal).get();
      final content = ref.read(contentRepositoryProvider);
      final topics = {
        for (final topic in await content.topicsByExam(exam.id)) topic.id,
      };
      final questions =
          await content.questionsByIds(flags.map((flag) => flag.questionId));
      final flaggedCount = questions.values
          .where((question) => topics.contains(question.topicId))
          .length;
      return ReminderExamSnapshot(
        date: prefs.examDate,
        name: exam.shortName,
        flaggedCount: flaggedCount,
      );
    },
    activityReader: () async {
      final focus = await ref.read(activeExamFocusProvider.future);
      if (focus.exam == null) return const ReminderActivitySnapshot();
      return ReminderActivityReader(db, ref.read(contentRepositoryProvider))
          .read(focus.exam!);
    },
    planReader: () async {
      final focus = await ref.read(activeExamFocusProvider.future);
      if (focus.exam == null) return const ReminderPlanSnapshot();
      final started =
          await ReminderActivityReader(db, ref.read(contentRepositoryProvider))
              .todayStarted(
        focus.exam!.id,
        ref.read(notificationClockProvider)(),
      );
      final subscription =
          ref.listen(roadmapTodayProvider(focus.exam!.id).future, (_, __) {});
      final RoadmapToday today;
      try {
        today = await subscription.read();
      } finally {
        subscription.close();
      }
      if (today.state == RoadmapState.needsAssessment ||
          today.state == RoadmapState.noContent) {
        return ReminderPlanSnapshot(todayStarted: started);
      }
      return ReminderPlanSnapshot(
        reviewCount: today.remaining.reviewQuestionIds.length,
        todayStarted: started || today.originalDone,
        planState: today.remaining.isMockDay
            ? DailyReminderPlanState.mock
            : DailyReminderPlanState.standard,
      );
    },
  );
  // Persisted starts cancel Follow up while the app stays in the foreground.
  final activity = db
      .customSelect(
        'SELECT exam_id, MAX(started_at, '
        'COALESCE(last_answered_at, started_at), '
        'COALESCE(completed_at, started_at)) AS started_at FROM quiz_sessions '
        'UNION ALL SELECT exam_id, MAX(started_at, COALESCE(completed_at, '
        'started_at)) AS started_at FROM attempts_local '
        'UNION ALL SELECT exam_id, MAX(started_at, last_flushed_at) '
        'AS started_at FROM mock_attempts',
        readsFrom: {db.quizSessions, db.attemptsLocal, db.mockAttempts},
      )
      .watch()
      .listen((rows) {
        final now = ref.read(notificationClockProvider)();
        final examId = ref.read(activeExamFocusProvider).valueOrNull?.exam?.id;
        if (rows.any(
          (row) =>
              row.read<String>('exam_id') == examId &&
              localDay(row.read<DateTime>('started_at')) == localDay(now),
        )) {
          unawaited(service.onSessionStarted());
        }
      });
  ref.onDispose(() => unawaited(activity.cancel()));
  return service;
});

final featureNotificationServiceProvider = Provider<NotificationService>((ref) {
  final service = ref.watch(reminderServiceProvider);
  // W3 owns trial eligibility and store pricing. W4f binds local delivery.
  void syncTrial() {
    final entitlement = ref.read(entitlementProvider).valueOrNull;
    if (entitlement == null) return;
    final packages =
        ref.read(paywallOfferingProvider).valueOrNull?.recognizedPackages;
    final scheduler = TrialEndingScheduler(
      service,
      priceTextFor: (entitlement) => packages
          ?.where(
            (p) =>
                p.productId.split(':').first ==
                entitlement.productId?.split(':').first,
          )
          .firstOrNull
          ?.priceString,
    );
    unawaited(scheduler.sync(entitlement));
  }

  ref
    ..listen(
      entitlementProvider,
      (_, __) => syncTrial(),
      fireImmediately: true,
    )
    ..listen(paywallOfferingProvider, (_, __) => syncTrial())
    ..listen(featurePermissionStatusProvider, (_, __) => syncTrial());
  return service;
});

final featurePermissionStatusStreamProvider =
    Provider<Stream<NotificationPermission>>((ref) {
  return ref.watch(notificationsGatewayProvider).watchPermissionStatus();
});

final featurePermissionStatusProvider =
    StreamProvider<NotificationPermission>((ref) {
  return ref.watch(featurePermissionStatusStreamProvider);
});

final notificationRationaleRepositoryProvider =
    Provider<NotificationRationaleRepository>((ref) {
  return NotificationRationaleRepository(ref.watch(appDatabaseProvider));
});

final notificationRationaleShownProvider = FutureProvider<bool>((ref) {
  return ref.watch(notificationRationaleRepositoryProvider).hasShown();
});

class NotificationRationaleRepository {
  NotificationRationaleRepository(this._db);

  static const key = 'notifications.rationale_shown';

  final AppDatabase _db;

  Future<bool> hasShown() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((pref) => pref.key.equals(key)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> markShown() async {
    await _db.into(_db.devicePrefs).insert(
          DevicePrefsCompanion.insert(key: key, value: 'true'),
          mode: InsertMode.insertOrReplace,
        );
  }
}
