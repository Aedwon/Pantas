// coverage:ignore-file
import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/tables/exams_table.dart';

@DataClassName('SubjectRow')
class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get examId => text().references(Exams, #id)();
  TextColumn get name => text()();
  IntColumn get ordering => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
