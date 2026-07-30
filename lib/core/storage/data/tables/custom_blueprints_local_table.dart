// coverage:ignore-file
import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/tables/exams_table.dart';

/// The paper a student described for their own track.
///
/// Local and never synced through the content pipeline: this is the student's
/// assertion about their exam, not a published blueprint, and it is the only
/// blueprint in Pantas that does not arrive through `assets/seed/content.db`.
@DataClassName('CustomBlueprintRow')
class CustomBlueprintsLocal extends Table {
  TextColumn get examId => text().references(Exams, #id)();
  IntColumn get totalQuestions => integer()();
  IntColumn get totalMinutes => integer()();
  TextColumn get sectionsJson => text()();
  BoolColumn get sectionsTimedSeparately =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {examId};
}
