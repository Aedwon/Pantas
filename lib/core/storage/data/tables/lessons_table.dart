// coverage:ignore-file
import 'package:pantas/core/storage/data/tables/topics_table.dart';
import 'package:drift/drift.dart';

@DataClassName('LessonRow')
class Lessons extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text().references(Topics, #id)();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get bodyJson => text()();
  IntColumn get estimatedMinutes => integer()();

  /// The authored teaching sequence within a topic. Zero means unplaced, which
  /// every lesson is until the editorial pass over the corpus runs. With the
  /// reader's pull advancing forward only, this is the sole guidance a student
  /// gets about where to begin, so it is load-bearing rather than cosmetic.
  IntColumn get ordering => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
