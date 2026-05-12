// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/topics_table.dart';
import 'package:drift/drift.dart';

@DataClassName('QuestionRow')
class Questions extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer()();
  TextColumn get examIdsJson => text()();
  TextColumn get topicId => text().references(Topics, #id)();
  TextColumn get language => text()();
  TextColumn get stem => text()();
  TextColumn get choicesJson => text()();
  TextColumn get explanation => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
