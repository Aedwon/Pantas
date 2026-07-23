import 'package:cse_cet_reviewer/core/content/tables/content_topics.dart';
import 'package:drift/drift.dart';

@DataClassName('ContentLessonRow')
class ContentLessons extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get topicId => text().references(ContentTopics, #id)();
  TextColumn get subtopicId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  IntColumn get estimatedMinutes => integer()();

  /// Position within its topic.
  ///
  /// **The app sorts every lesson list by this**, so without it a structured
  /// course is served in whatever order the rows come back. 141 of the 144
  /// authored lessons carry one; the three without are unplaced and fall to 0,
  /// which is what the app's own schema does with them.
  IntColumn get ordering => integer().withDefault(const Constant(0))();
  TextColumn get bodyJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
