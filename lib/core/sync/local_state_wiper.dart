import 'package:drift/drift.dart' show StringExpressionOperators;
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart'
    show customExamIdPrefix;

/// Device-prefs key of an open first run; the first-run store uses it too.
const firstRunDeviceKey = 'first_run_open_v1';

class SyncLocalStateWiper implements LocalStateWiper {
  SyncLocalStateWiper(
    this._db, {
    NotificationService? notifications,
    Future<void> Function()? clearCustomExams,
  })  : _notifications = notifications,
        _clearCustomExams = clearCustomExams;

  static const _selectedExamKey = 'selected_exam_id';
  static const _guardianKeys = [
    'guardian_contact_name',
    'guardian_contact_email',
    'guardian_status',
    'guardian_sharing_applied',
  ];

  final AppDatabase _db;
  final NotificationService? _notifications;

  /// Removes custom exams from the content database. On web a sign-out does
  /// not reload, so nothing else clears them. Sync does not import content.
  final Future<void> Function()? _clearCustomExams;

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
      // Payment evidence belongs to the account. Trusted clock and pending
      // markers belong to the device and must survive this wipe.
      await (_db.delete(_db.devicePrefs)
            ..where(
              (row) => row.key.equals('payment_last_confirmed_entitlement_v1'),
            ))
          .go();
      // A guardian's name and email belong to a third party and sit here in
      // plain text. The server keeps only a hash and a masked address, so
      // nothing here is worth keeping for the next account. The closed-account
      // marker stays: it belongs to the device.
      await (_db.delete(_db.devicePrefs)
            ..where((row) => row.key.isIn(_guardianKeys)))
          .go();
      // Question reports are the student's own words and are sent under the
      // account that wrote them. Sign-out first sends this account's pending
      // reports and refuses if any cannot go; whatever is left here (refused
      // ones, a report filed in another tab) must not reach the next account.
      await (_db.delete(_db.devicePrefs)
            ..where((row) => row.key.equals(ReportQueue.storageKey)))
          .go();
      // A saved assessment in progress is the account's own answers. They sit
      // in device prefs, keyed by account, so the wipe clears them by prefix.
      await (_db.delete(_db.devicePrefs)
            ..where(
              (row) => row.key.like(
                '${AppPreferencesRepository.assessmentProgressKeyPrefix}%',
              ),
            ))
          .go();
      // An open first run belongs to the account that started it.
      await (_db.delete(_db.devicePrefs)
            ..where((row) => row.key.equals(firstRunDeviceKey)))
          .go();
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
      await _db.delete(_db.roadmapDayLocal).go();
      await _db.delete(_db.roadmapChangeLogLocal).go();
      await _db.delete(_db.mockAttempts).go();
      await _db.delete(_db.userMetricsArchetypesLocal).go();
      await _db.delete(_db.userMetricsArtifactsLocal).go();
      await _db.delete(_db.reviewLogs).go();
      await _db.delete(_db.trackScopeLocal).go();
      await _db.delete(_db.customBlueprintsLocal).go();
      // The next account on a shared browser must not see this track's name.
      await _db.delete(_db.customTrackMetaLocal).go();
      // Change records and accepted versions for the rows deleted above.
      await _db.delete(_db.syncLocalMutations).go();
      await _db.delete(_db.syncRowMeta).go();

      // A custom exam belongs to the account. A listed exam's selection is
      // device state and stays.
      final selected = await (_db.select(_db.devicePrefs)
            ..where((row) => row.key.equals(_selectedExamKey)))
          .getSingleOrNull();
      if (selected != null && selected.value.startsWith(customExamIdPrefix)) {
        await (_db.delete(_db.devicePrefs)
              ..where((row) => row.key.equals(_selectedExamKey)))
            .go();
      }
      final legacySelected = await (_db.select(_db.appPreferencesLocal)
            ..where((row) => row.key.equals(_selectedExamKey)))
          .getSingleOrNull();
      if (legacySelected != null &&
          legacySelected.value.startsWith(customExamIdPrefix)) {
        await (_db.delete(_db.appPreferencesLocal)
              ..where((row) => row.key.equals(_selectedExamKey)))
            .go();
      }

      final deviceId = await (_db.select(_db.syncMeta)
            ..where((row) => row.key.equals('deviceId')))
          .getSingleOrNull();
      await _db.delete(_db.syncMeta).go();
      if (deviceId != null) {
        await _db.into(_db.syncMeta).insert(deviceId);
      }
    });

    await _clearCustomExams?.call();
  }
}
