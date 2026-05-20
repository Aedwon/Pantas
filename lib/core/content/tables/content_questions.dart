import 'package:cse_cet_reviewer/core/content/tables/content_topics.dart';
import 'package:drift/drift.dart';

@DataClassName('ContentQuestionRow')
class ContentQuestions extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get topicId => text().references(ContentTopics, #id)();
  TextColumn get language => text()();
  TextColumn get stemJson => text()();
  TextColumn get explanationJson => text()();
  IntColumn get version => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
