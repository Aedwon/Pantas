import 'package:pantas/core/content/tables/content_lessons.dart';
import 'package:pantas/core/content/tables/content_passages.dart';
import 'package:pantas/core/content/tables/content_topics.dart';
import 'package:drift/drift.dart';

@DataClassName('ContentQuestionRow')
class ContentQuestions extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get topicId => text().references(ContentTopics, #id)();
  TextColumn get subtopicId => text().nullable()();
  TextColumn get language => text()();
  TextColumn get stemJson => text()();
  TextColumn get explanationJson => text()();
  IntColumn get version => integer()();
  TextColumn get lessonId =>
      text().nullable().references(ContentLessons, #id)();
  TextColumn get passageId =>
      text().nullable().references(ContentPassages, #id)();
  TextColumn get shortLabel => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
