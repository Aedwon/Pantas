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
  IntColumn get ordering => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
