import 'package:cse_cet_reviewer/core/content/tables/content_topics.dart';
import 'package:drift/drift.dart';

@DataClassName('ContentLessonRow')
class ContentLessons extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get topicId => text().references(ContentTopics, #id)();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  IntColumn get estimatedMinutes => integer()();
  TextColumn get bodyJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
