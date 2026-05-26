// coverage:ignore-file
import 'package:drift/drift.dart';

@TableIndex(
  name: 'mock_attempts_active_idx',
  columns: {#userId, #examId, #status},
)
@TableIndex(name: 'mock_attempts_history_idx', columns: {#userId, #submittedAt})
@DataClassName('MockAttemptLocalRow')
class MockAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get examId => text()();
  TextColumn get blueprintId => text()();
  TextColumn get blueprintName => text()();
  IntColumn get durationMinutes => integer()();
  TextColumn get status => text()();
  BoolColumn get strictMode => boolean()();
  TextColumn get sampledQuestionsJson => text()();
  IntColumn get elapsedSeconds => integer().withDefault(const Constant(0))();
  IntColumn get accumulatedPausedSeconds =>
      integer().withDefault(const Constant(0))();
  BoolColumn get pausedAtLastFlush =>
      boolean().withDefault(const Constant(false))();
  TextColumn get answersJson => text().withDefault(const Constant('{}'))();
  TextColumn get flagsJson => text().withDefault(const Constant('[]'))();
  IntColumn get currentIndex => integer().withDefault(const Constant(0))();
  IntColumn get scoreRaw => integer().nullable()();
  IntColumn get scoreTotal => integer().nullable()();
  TextColumn get sectionResultsJson => text().nullable()();
  IntColumn get totalTimeSeconds => integer().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastFlushedAt => dateTime()();
  DateTimeColumn get submittedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
