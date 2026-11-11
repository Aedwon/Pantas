// coverage:ignore-file
import 'package:drift/drift.dart';

/// One built day of the study plan per exam. Derived from other tables and
/// rebuilt on demand, so it is device-local and never synced.
@DataClassName('RoadmapDayLocalRow')
class RoadmapDayLocal extends Table {
  TextColumn get examId => text().named('exam_id')();

  /// The local day as `YYYY-MM-DD`.
  TextColumn get day => text()();
  TextColumn get planJson => text().named('plan_json')();
  TextColumn get inputsDigest => text().named('inputs_digest')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {examId, day};
}
