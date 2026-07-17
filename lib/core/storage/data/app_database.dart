import 'package:cse_cet_reviewer/core/storage/data/tables/account_prefs_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/app_preferences_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/assessment_results_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/attempts_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/daily_new_card_intro_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/device_prefs_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/exams_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/lesson_bookmarks_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/lesson_progress_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/lessons_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/mock_attempts_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/passages_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/pending_sync_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/question_flags_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/questions_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/quiz_sessions_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/review_logs_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/review_state_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/streak_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/subjects_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/sync_meta_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/topics_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/custom_blueprints_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/track_scope_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/user_metrics_archetypes_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/user_metrics_artifacts_local_table.dart';
import 'package:drift/drift.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 21;

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
        },
      );
}
