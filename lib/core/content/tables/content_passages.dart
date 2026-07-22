import 'package:cse_cet_reviewer/core/content/tables/content_topics.dart';
import 'package:drift/drift.dart';

@DataClassName('ContentPassageRow')
class ContentPassages extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get topicId => text().references(ContentTopics, #id)();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get language => text()();
  IntColumn get wordCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
