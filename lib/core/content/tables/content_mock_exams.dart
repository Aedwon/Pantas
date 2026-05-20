import 'package:cse_cet_reviewer/core/content/tables/content_mock_blueprints.dart';
import 'package:drift/drift.dart';

@DataClassName('ContentMockExamRow')
class ContentMockExams extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get blueprintId => text().references(ContentMockBlueprints, #id)();
  TextColumn get name => text()();
  DateTimeColumn get publishedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
