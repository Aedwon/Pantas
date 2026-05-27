import 'package:cse_cet_reviewer/core/auth/auth_repository.dart';
import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';

class SyncLocalStateWiper implements LocalStateWiper {
  SyncLocalStateWiper(
    this._db, {
    NotificationService? notifications,
  }) : _notifications = notifications;

  final AppDatabase _db;
  final NotificationService? _notifications;

  @override
  Future<bool> hasMeaningfulProgress() async {
    final attempts = await (_db.select(_db.attemptsLocal)..limit(1)).get();
    if (attempts.isNotEmpty) return true;

    final lessons = await (_db.select(_db.lessonProgressLocal)..limit(1)).get();
    if (lessons.isNotEmpty) return true;

    final review = await (_db.select(_db.reviewStateLocal)..limit(1)).get();
    return review.isNotEmpty;
  }

  @override
  Future<void> wipeAll() async {
    await _notifications?.cancelAll();
    await _db.transaction(() async {
      await _db.delete(_db.attemptsLocal).go();
      await _db.delete(_db.assessmentResultsLocal).go();
      await _db.delete(_db.reviewStateLocal).go();
      await _db.delete(_db.lessonProgressLocal).go();
      await _db.delete(_db.accountPrefs).go();
      await _db.delete(_db.pendingSync).go();

      final deviceId = await (_db.select(_db.syncMeta)
            ..where((row) => row.key.equals('deviceId')))
          .getSingleOrNull();
      await _db.delete(_db.syncMeta).go();
      if (deviceId != null) {
        await _db.into(_db.syncMeta).insert(deviceId);
      }
    });
  }
}
