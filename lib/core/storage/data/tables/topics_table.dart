// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/subjects_table.dart';
import 'package:drift/drift.dart';

@DataClassName('TopicRow')
class Topics extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().references(Subjects, #id)();
  TextColumn get name => text()();
  IntColumn get ordering => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
