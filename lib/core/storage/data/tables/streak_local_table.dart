import 'package:drift/drift.dart';

@DataClassName('StreakLocalRow')
class StreakLocal extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get current => integer().withDefault(const Constant(0))();
  IntColumn get longest => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveDate => dateTime().nullable()();
  IntColumn get freezesRemaining => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastServerReconcileAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
