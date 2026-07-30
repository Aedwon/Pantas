// coverage:ignore-file
import 'package:pantas/core/storage/data/tables/topics_table.dart';
import 'package:drift/drift.dart';

@DataClassName('PassageRow')
class Passages extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text().references(Topics, #id)();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get language => text()();
  IntColumn get wordCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
