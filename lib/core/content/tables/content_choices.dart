import 'package:drift/drift.dart';
import 'package:pantas/core/content/tables/content_questions.dart';

@DataClassName('ContentChoiceRow')
class ContentChoices extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get questionId => text().references(ContentQuestions, #id)();
  TextColumn get label => text()();
  TextColumn get textValue => text().named('text')();
  BoolColumn get isCorrect => boolean()();

  /// Note B: the reveal's second note, addressed to the student who picked
  /// this choice. Pro sees it, and only on a miss.
  ///
  /// Nullable because the corpus has none yet. **A question with no
  /// rationale gives a Pro subscriber exactly what a free one gets**, which
  /// is the state every one of them was in on 13 August 2026.
  TextColumn get rationale => text().nullable()();
  IntColumn get ordering => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
