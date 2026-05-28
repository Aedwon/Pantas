// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('UserMetricsArchetypeLocalRow')
class UserMetricsArchetypesLocal extends Table {
  TextColumn get userId => text()();
  TextColumn get examId => text()();
  TextColumn get window => text()();
  TextColumn get archetypeId => text()();
  RealColumn get matchScore => real()();
  TextColumn get synthesizedCopy => text()();
  DateTimeColumn get computedAt => dateTime()();
  DateTimeColumn get validUntil => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId, examId, window, archetypeId};
}
