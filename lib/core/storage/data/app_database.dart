import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/tables/account_prefs_table.dart';
import 'package:pantas/core/storage/data/tables/app_preferences_local_table.dart';
import 'package:pantas/core/storage/data/tables/assessment_results_local_table.dart';
import 'package:pantas/core/storage/data/tables/attempts_local_table.dart';
import 'package:pantas/core/storage/data/tables/cached_content_table.dart';
import 'package:pantas/core/storage/data/tables/custom_blueprints_local_table.dart';
import 'package:pantas/core/storage/data/tables/custom_track_meta_local_table.dart';
import 'package:pantas/core/storage/data/tables/daily_new_card_intro_table.dart';
import 'package:pantas/core/storage/data/tables/device_prefs_table.dart';
import 'package:pantas/core/storage/data/tables/exams_table.dart';
import 'package:pantas/core/storage/data/tables/lesson_bookmarks_local_table.dart';
import 'package:pantas/core/storage/data/tables/lesson_progress_local_table.dart';
import 'package:pantas/core/storage/data/tables/lessons_table.dart';
import 'package:pantas/core/storage/data/tables/mock_attempts_table.dart';
import 'package:pantas/core/storage/data/tables/passages_table.dart';
import 'package:pantas/core/storage/data/tables/pending_sync_table.dart';
import 'package:pantas/core/storage/data/tables/question_flags_local_table.dart';
import 'package:pantas/core/storage/data/tables/questions_table.dart';
import 'package:pantas/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart';
import 'package:pantas/core/storage/data/tables/quiz_sessions_table.dart';
import 'package:pantas/core/storage/data/tables/review_logs_table.dart';
import 'package:pantas/core/storage/data/tables/review_state_local_table.dart';
import 'package:pantas/core/storage/data/tables/roadmap_change_log_local_table.dart';
import 'package:pantas/core/storage/data/tables/roadmap_day_local_table.dart';
import 'package:pantas/core/storage/data/tables/streak_local_table.dart';
import 'package:pantas/core/storage/data/tables/subjects_table.dart';
import 'package:pantas/core/storage/data/tables/sync_local_mutations_table.dart';
import 'package:pantas/core/storage/data/tables/sync_meta_table.dart';
import 'package:pantas/core/storage/data/tables/sync_row_meta_table.dart';
import 'package:pantas/core/storage/data/tables/topics_table.dart';
import 'package:pantas/core/storage/data/tables/track_scope_local_table.dart';
import 'package:pantas/core/storage/data/tables/user_metrics_archetypes_local_table.dart';
import 'package:pantas/core/storage/data/tables/user_metrics_artifacts_local_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Exams,
    Subjects,
    Topics,
    Questions,
    QuestionFlagsLocal,
    Lessons,
    LessonBookmarksLocal,
    AttemptsLocal,
    ReviewStateLocal,
    StreakLocal,
    LessonProgressLocal,
    QuizNudgeDismissedLocal,
    AssessmentResultsLocal,
    AppPreferencesLocal,
    PendingSync,
    SyncMeta,
    SyncRowMeta,
    SyncLocalMutations,
    CustomTrackMetaLocal,
    DevicePrefs,
    AccountPrefs,
    QuizSessions,
    DailyNewCardIntro,
    MockAttempts,
    UserMetricsArchetypesLocal,
    UserMetricsArtifactsLocal,
    Passages,
    ReviewLogs,
    TrackScopeLocal,
    CustomBlueprintsLocal,
    RoadmapDayLocal,
    RoadmapChangeLogLocal,
    CachedContent,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 26;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(lessonProgressLocal);
            await m.createTable(quizNudgeDismissedLocal);
          }
          if (from < 3) {
            await m.createTable(assessmentResultsLocal);
          }
          if (from < 4) {
            await m.createTable(appPreferencesLocal);
          }
          if (from < 5) {
            await m.createTable(pendingSync);
            await m.createTable(syncMeta);
          }
          if (from < 6) {
            await m.createTable(devicePrefs);
            await m.createTable(accountPrefs);
            await customStatement(
              'INSERT OR REPLACE INTO device_prefs (key, value) '
              'SELECT key, value FROM app_preferences_local',
            );
          }
          if (from < 7) {
            await m.createTable(quizSessions);
            await m.createTable(dailyNewCardIntro);
          }
          if (from < 8) {
            await m.addColumn(attemptsLocal, attemptsLocal.origin);
          }
          if (from < 9) {
            await m.createTable(mockAttempts);
          }
          if (from < 10) {
            await m.createTable(userMetricsArchetypesLocal);
          }
          if (from < 11) {
            await m.createTable(userMetricsArtifactsLocal);
          }
          if (from < 12) {
            await m.createTable(questionFlagsLocal);
          }
          if (from < 13) {
            await m.addColumn(questions, questions.lessonId);
          }
          if (from < 14) {
            await m.addColumn(questions, questions.shortLabel);
          }
          if (from < 15) {
            await m.addColumn(lessons, lessons.ordering);
          }
          if (from < 16) {
            await m.createTable(lessonBookmarksLocal);
          }
          if (from < 17) {
            await m.addColumn(questions, questions.isWithdrawn);
          }
          if (from < 18) {
            await m.createTable(passages);
            await m.addColumn(questions, questions.passageId);
          }
          if (from < 19) {
            await m.createTable(reviewLogs);
          }
          if (from < 20) {
            await m.addColumn(exams, exams.isCustom);
            await m.createTable(trackScopeLocal);
          }
          if (from < 21) {
            await m.createTable(customBlueprintsLocal);
          }
          if (from < 22) {
            // How to draw a question's diagram. Null everywhere until the
            // seed carries one.
            await m.addColumn(questions, questions.figureSpecJson);
          }
          if (from < 23) {
            await m.createTable(syncRowMeta);
            await m.createTable(syncLocalMutations);
            await m.createTable(customTrackMetaLocal);

            // The old pending_sync table was only a generation-neutral
            // placeholder. Preserve its user-change facts in the new local
            // mutation journal, explicitly marked unbound, then rebuild the
            // active outbox with its generation-bound schema.
            await customStatement(
              'INSERT INTO sync_local_mutations '
              '(collection, row_id, op, revision, mutation_epoch, '
              'causal_uid, causal_generation_id, causal_base_state, '
              'base_updated_at, recorded_at) '
              "SELECT table_type, row_id, op, 1, 0, NULL, NULL, 'unbound', "
              'NULL, queued_at FROM pending_sync',
            );
            await customStatement('DROP TABLE pending_sync');
            await m.createTable(pendingSync);
            await customStatement(
              'INSERT OR IGNORE INTO sync_meta (key, value) '
              "VALUES ('localMutationEpoch', '0')",
            );
          }
          if (from >= 7 && from < 24) {
            await m.addColumn(quizSessions, quizSessions.outcomesJson);
            // V23 did not store the exact chosen choice for answered active
            // sessions. Preserve their review history, but close those legacy
            // sessions instead of exposing an inaccurate Resume.
            await customStatement(
              'UPDATE quiz_sessions '
              'SET quit_at = COALESCE(quit_at, last_answered_at, started_at) '
              'WHERE completed_at IS NULL AND quit_at IS NULL '
              'AND current_index > 0',
            );
          }
          if (from < 25) {
            await m.createTable(roadmapDayLocal);
            await m.createTable(roadmapChangeLogLocal);
          }
          if (from < 26) {
            await m.createTable(cachedContent);
          }
        },
      );
}
