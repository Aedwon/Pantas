import 'package:drift/drift.dart';
import 'package:pantas/core/content/tables/content_subjects.dart';

@DataClassName('ContentTopicRow')
class ContentTopics extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get subjectId => text().references(ContentSubjects, #id)();
  TextColumn get name => text()();
  IntColumn get ordering => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
