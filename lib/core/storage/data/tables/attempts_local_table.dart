import 'package:drift/drift.dart';

@DataClassName('AttemptLocalRow')
class AttemptsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get examId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get itemsJson => text()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();
  TextColumn get lastSyncError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
