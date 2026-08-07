// coverage:ignore-file
import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/tables/lessons_table.dart';
import 'package:pantas/core/storage/data/tables/passages_table.dart';
import 'package:pantas/core/storage/data/tables/topics_table.dart';

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

  /// How to draw this question's diagram, as JSON. Null when there is none.
  TextColumn get figureSpecJson => text().nullable()();
  TextColumn get passageId => text().nullable().references(Passages, #id)();

  /// A withdrawn question is never served again by sessions/drills/mocks/pickers,
  /// but remains visible in history.
  BoolColumn get isWithdrawn => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
