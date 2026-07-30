// coverage:ignore-file
import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/tables/subjects_table.dart';

@DataClassName('TopicRow')
class Topics extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().references(Subjects, #id)();
  TextColumn get name => text()();
  IntColumn get ordering => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
