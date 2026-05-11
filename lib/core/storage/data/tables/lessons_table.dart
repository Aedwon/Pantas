import 'package:cse_cet_reviewer/core/storage/data/tables/topics_table.dart';
import 'package:drift/drift.dart';

@DataClassName('LessonRow')
class Lessons extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text().references(Topics, #id)();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get bodyJson => text()();
  IntColumn get estimatedMinutes => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
