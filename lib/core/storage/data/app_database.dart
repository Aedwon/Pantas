import 'package:cse_cet_reviewer/core/storage/data/tables/attempts_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/exams_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/lesson_progress_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/lessons_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/questions_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/review_state_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/streak_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/subjects_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/topics_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/assessment_results_local_table.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Exams,
    Subjects,
    Topics,
    Questions,
    Lessons,
    AttemptsLocal,
    ReviewStateLocal,
    StreakLocal,
    LessonProgressLocal,
    QuizNudgeDismissedLocal,
    AssessmentResultsLocal,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

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
        },
      );
}
