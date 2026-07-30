import 'package:pantas/core/content/tables/content_exams.dart';
import 'package:drift/drift.dart';

@DataClassName('ContentSubjectRow')
class ContentSubjects extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get examId => text().references(ContentExams, #id)();
  TextColumn get name => text()();
  IntColumn get ordering => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
