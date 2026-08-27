import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';

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

    final assessments =
        await (_db.select(_db.assessmentResultsLocal)..limit(1)).get();
    if (assessments.isNotEmpty) return true;

    final review = await (_db.select(_db.reviewStateLocal)..limit(1)).get();
    if (review.isNotEmpty) return true;

    final streak = await (_db.select(_db.streakLocal)..limit(1)).get();
    if (streak.isNotEmpty) return true;

    final lessons = await (_db.select(_db.lessonProgressLocal)..limit(1)).get();
    if (lessons.isNotEmpty) return true;

    final bookmarks =
        await (_db.select(_db.lessonBookmarksLocal)..limit(1)).get();
    if (bookmarks.isNotEmpty) return true;

    final flags = await (_db.select(_db.questionFlagsLocal)..limit(1)).get();
    if (flags.isNotEmpty) return true;

    final mockAttempts = await (_db.select(_db.mockAttempts)..limit(1)).get();
    if (mockAttempts.isNotEmpty) return true;

    final reviewLogs = await (_db.select(_db.reviewLogs)..limit(1)).get();
    if (reviewLogs.isNotEmpty) return true;

    final trackScope = await (_db.select(_db.trackScopeLocal)..limit(1)).get();
    if (trackScope.isNotEmpty) return true;

    final customBlueprints =
        await (_db.select(_db.customBlueprintsLocal)..limit(1)).get();
    return customBlueprints.isNotEmpty;
  }

  @override
  Future<void> wipeAll() async {
    await _notifications?.cancelAll();
    await _db.transaction(() async {
      await _db.delete(_db.attemptsLocal).go();
      await _db.delete(_db.assessmentResultsLocal).go();
      await _db.delete(_db.reviewStateLocal).go();
      await _db.delete(_db.streakLocal).go();
      await _db.delete(_db.lessonProgressLocal).go();
      await _db.delete(_db.lessonBookmarksLocal).go();
      await _db.delete(_db.questionFlagsLocal).go();
      await _db.delete(_db.accountPrefs).go();
      await _db.delete(_db.pendingSync).go();
      await _db.delete(_db.quizSessions).go();
      await _db.delete(_db.dailyNewCardIntro).go();
      await _db.delete(_db.mockAttempts).go();
      await _db.delete(_db.userMetricsArchetypesLocal).go();
      await _db.delete(_db.userMetricsArtifactsLocal).go();
      await _db.delete(_db.reviewLogs).go();
      await _db.delete(_db.trackScopeLocal).go();
      await _db.delete(_db.customBlueprintsLocal).go();

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
