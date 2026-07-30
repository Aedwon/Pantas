// coverage:ignore-file
import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/tables/lessons_table.dart';

@DataClassName('LessonProgressLocalRow')
class LessonProgressLocal extends Table {
  TextColumn get lessonId => text().references(Lessons, #id)();
  DateTimeColumn get readAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {lessonId};
}
