import 'package:drift/drift.dart';
import 'package:pantas/core/content/tables/content_lessons.dart';
import 'package:pantas/core/content/tables/content_passages.dart';
import 'package:pantas/core/content/tables/content_topics.dart';

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

  /// How to draw this question's diagram, as JSON.
  ///
  /// Null for a question with no figure, and for the ones still waiting on a
  /// hand-drawn picture. `2026-08-13-drawn-figures-design.md` has the
  /// families and what each one carries.
  TextColumn get figureSpecJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
