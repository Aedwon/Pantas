// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/lessons_table.dart';
import 'package:drift/drift.dart';

@DataClassName('LessonProgressLocalRow')
class LessonProgressLocal extends Table {
  TextColumn get lessonId => text().references(Lessons, #id)();
  DateTimeColumn get readAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {lessonId};
}
