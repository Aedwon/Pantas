import 'package:drift/drift.dart';

@DataClassName('QuizSessionLocalRow')
class QuizSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get examId => text()();
  TextColumn get origin => text()();
  TextColumn get topicId => text().nullable()();
  TextColumn get subtopicId => text().nullable()();
  TextColumn get lessonId => text().nullable()();
  TextColumn get questionIdsJson => text()();
  IntColumn get currentIndex => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastAnsweredAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get quitAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
