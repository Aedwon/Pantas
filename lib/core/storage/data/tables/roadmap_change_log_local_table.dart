// coverage:ignore-file
import 'package:drift/drift.dart';

/// Why the study plan changed, one row per change. Append-only: a change
/// that happened is a fact.
@DataClassName('RoadmapChangeLogLocalRow')
class RoadmapChangeLogLocal extends Table {
  TextColumn get id => text()();
  TextColumn get examId => text().named('exam_id')();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();

  /// A `RoadmapChangeCause` name.
  TextColumn get cause => text()();
  TextColumn get beforeJson => text().named('before_json').nullable()();
  TextColumn get afterJson => text().named('after_json').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
