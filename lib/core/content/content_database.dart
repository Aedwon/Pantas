import 'package:cse_cet_reviewer/core/content/tables/content_choices.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_diagnostic_sets.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_exams.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_lessons.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_meta.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_mock_blueprints.dart';
import 'package:cse_cet_reviewer/core/content/tables/content_mock_exams.dart';
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
    ContentMockBlueprints,
    ContentMockExams,
    ContentDiagnosticSets,
    ContentMeta,
  ],
)
class ContentDatabase extends _$ContentDatabase {
  ContentDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
      );
}
