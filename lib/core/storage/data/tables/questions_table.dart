// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/lessons_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/topics_table.dart';
import 'package:drift/drift.dart';

@DataClassName('QuestionRow')
class Questions extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer()();
  TextColumn get examIdsJson => text()();
  TextColumn get topicId => text().references(Topics, #id)();

  /// Null until the tagging pass lands. Questions carry `topicId` only today,
  /// which is why every lesson in a topic currently hands out the same five.
  TextColumn get lessonId => text().nullable().references(Lessons, #id)();
  TextColumn get language => text()();
  TextColumn get stem => text()();
  TextColumn get choicesJson => text()();
  TextColumn get explanation => text()();
  TextColumn get shortLabel => text().nullable()();

  /// A withdrawn question is never served again by sessions/drills/mocks/pickers,
  /// but remains visible in history.
  BoolColumn get isWithdrawn => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
