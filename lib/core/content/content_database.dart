import 'package:cse_cet_reviewer/core/content/tables/content_choices.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_diagnostic_sets.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_exams.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_lessons.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_meta.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_mock_blueprints.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_mock_exams.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_passages.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_question_exams.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_questions.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_subjects.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_topics.dart';
import 'package:drift/drift.dart';

part 'content_database.g.dart';

@DriftDatabase(
  tables: [
    ContentExams,
    ContentSubjects,
    ContentTopics,
    ContentQuestions,
    ContentChoices,
    ContentQuestionExams,
    ContentLessons,
    ContentPassages,
    ContentMockBlueprints,
    ContentMockExams,
    ContentDiagnosticSets,
    ContentMeta,
  ],
)
class ContentDatabase extends _$ContentDatabase {
  ContentDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            // Both are nullable, and null is the honest state for an exam
            // that has published neither.
            await m.addColumn(
              contentMockBlueprints,
              contentMockBlueprints.sectionalTiming,
            );
            await m.addColumn(
              contentMockBlueprints,
              contentMockBlueprints.scoreBandsJson,
            );
            await m.addColumn(
              contentMockBlueprints,
              contentMockBlueprints.totalPublishedItems,
            );
          }
          if (from < 4) {
            // await m.createTable(contentPassages);
            // await m.addColumn(
            //   contentQuestions,
            //   contentQuestions.lessonId,
            // );
            // await m.addColumn(
            //   contentQuestions,
            //   contentQuestions.passageId,
            // );
            // await m.addColumn(
            //   contentQuestions,
            //   contentQuestions.shortLabel,
            // );
            // await m.addColumn(
            //   contentExams,
            //   contentExams.isCustom,
            // );
          }
        },
      );
}
