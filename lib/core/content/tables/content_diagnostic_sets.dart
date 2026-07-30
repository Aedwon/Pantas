import 'package:pantas/core/content/tables/content_exams.dart';
import 'package:drift/drift.dart';

@DataClassName('ContentDiagnosticSetRow')
class ContentDiagnosticSets extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get examId => text().references(ContentExams, #id)();
  TextColumn get name => text()();
  TextColumn get questionIdsJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
