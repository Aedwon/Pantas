import 'package:pantas/core/storage/data/app_database.dart';

/// Clears the student's local study tables.
///
/// [clearPrefs] also clears the preference tables. [keepSyncMeta] leaves the
/// sync tables alone, which a running app needs: the sign-in step has already
/// stored its active account there.
Future<void> resetLocalStudyData(
  AppDatabase db, {
  bool clearPrefs = true,
  bool keepSyncMeta = false,
}) async {
  await db.transaction(() async {
    if (clearPrefs) {
      await db.delete(db.accountPrefs).go();
      await db.delete(db.appPreferencesLocal).go();
      await db.delete(db.devicePrefs).go();
    }
    await db.delete(db.assessmentResultsLocal).go();
    await db.delete(db.attemptsLocal).go();
    await db.delete(db.customBlueprintsLocal).go();
    await db.delete(db.dailyNewCardIntro).go();
    await db.delete(db.roadmapDayLocal).go();
    await db.delete(db.roadmapChangeLogLocal).go();
    await db.delete(db.lessonBookmarksLocal).go();
    await db.delete(db.lessonProgressLocal).go();
    await db.delete(db.mockAttempts).go();
    await db.delete(db.pendingSync).go();
    await db.delete(db.questionFlagsLocal).go();
    await db.delete(db.quizNudgeDismissedLocal).go();
    await db.delete(db.quizSessions).go();
    await db.delete(db.reviewLogs).go();
    await db.delete(db.reviewStateLocal).go();
    await db.delete(db.streakLocal).go();
    if (!keepSyncMeta) await db.delete(db.syncMeta).go();
    await db.delete(db.trackScopeLocal).go();
    await db.delete(db.userMetricsArchetypesLocal).go();
    await db.delete(db.userMetricsArtifactsLocal).go();
  });
}
