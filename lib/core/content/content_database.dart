import 'package:drift/drift.dart';
import 'package:pantas/core/content/tables/content_choices.dart';
import 'package:pantas/core/content/tables/content_diagnostic_sets.dart';
import 'package:pantas/core/content/tables/content_exams.dart';
import 'package:pantas/core/content/tables/content_lessons.dart';
import 'package:pantas/core/content/tables/content_meta.dart';
import 'package:pantas/core/content/tables/content_mock_blueprints.dart';
import 'package:pantas/core/content/tables/content_mock_exams.dart';
import 'package:pantas/core/content/tables/content_passages.dart';
import 'package:pantas/core/content/tables/content_question_exams.dart';
import 'package:pantas/core/content/tables/content_questions.dart';
import 'package:pantas/core/content/tables/content_subjects.dart';
import 'package:pantas/core/content/tables/content_topics.dart';

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
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          if (schemaVersion >= 9) {
            await _createE05Indexes();
          }
        },
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
          if (from < 6) {
            await m.addColumn(
              contentMockBlueprints,
              contentMockBlueprints.source,
            );
            await m.addColumn(
              contentMockBlueprints,
              contentMockBlueprints.sourceNote,
            );
          }
          if (from < 7) {
            // Note B, the reveal's Pro note. Nullable, and null everywhere
            // until the corpus carries one.
            await m.addColumn(contentChoices, contentChoices.rationale);
          }
          if (from < 8) {
            await m.addColumn(
              contentQuestions,
              contentQuestions.figureSpecJson,
            );
          }
          if (from < 9) {
            await _createE05Indexes();
          }
          if (from < 10) {
            // Nullable: null is the honest state for an exam that states no
            // unscored items.
            await m.addColumn(
              contentMockBlueprints,
              contentMockBlueprints.unscoredItems,
            );
          }
        },
      );

  Future<void> _createE05Indexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS content_questions_topic_active_idx '
      'ON content_questions (topic_id, is_active)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS content_question_exams_exam_question_idx '
      'ON content_question_exams (exam_id, question_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS content_choices_question_active_order_idx '
      'ON content_choices (question_id, is_active, ordering)',
    );
  }
}
