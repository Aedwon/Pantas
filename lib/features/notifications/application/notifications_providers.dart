import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/notifications/application/notification_service.dart';
import 'package:pantas/features/notifications/data/flutter_local_notifications_gateway.dart';
import 'package:pantas/features/notifications/data/inert_notifications_gateway.dart';
import 'package:pantas/features/notifications/data/notifications_gateway.dart';
import 'package:pantas/features/notifications/domain/notification_body_composer.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

const _dailyReminderTimeKey = 'settings.daily_reminder_time';

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

final featureNotificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl(
    gateway: ref.watch(notificationsGatewayProvider),
    settingsReader: () async {
      final db = ref.read(appDatabaseProvider);
      final row = await (db.select(db.accountPrefs)
            ..where((pref) => pref.key.equals(_dailyReminderTimeKey)))
          .getSingleOrNull();
      final reminder = _notificationTimeFromStorage(row?.value);
      if (reminder == null) return const NotificationSettingsSnapshot.none();
      return NotificationSettingsSnapshot.daily(
        hour: reminder.hour,
        minute: reminder.minute,
      );
    },
    planReader: () async {
      final focus = await ref.read(activeExamFocusProvider.future);
      if (focus.needsSelection || focus.exam == null) {
        return const NotificationPlanSnapshot.unavailable();
      }
      final today = await ref.read(roadmapTodayProvider(focus.exam!.id).future);
      if (today.state == RoadmapState.needsAssessment ||
          today.state == RoadmapState.noContent) {
        return const NotificationPlanSnapshot.unavailable();
      }
      return NotificationPlanSnapshot.ready(
        reviewCount: today.remaining.reviewQuestionIds.length,
        route: '/quiz',
        planState: today.remaining.isMockDay
            ? DailyReminderPlanState.mock
            : DailyReminderPlanState.standard,
      );
    },
    streakReader: () async => const NotificationStreakSnapshot.empty(),
    now: DateTime.now,
  );
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

NotificationTime? _notificationTimeFromStorage(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return NotificationTime(hour: hour, minute: minute);
}
