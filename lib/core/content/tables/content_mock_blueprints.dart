import 'package:drift/drift.dart';
import 'package:pantas/core/content/tables/content_exams.dart';

@DataClassName('ContentMockBlueprintRow')
class ContentMockBlueprints extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get examId => text().references(ContentExams, #id)();
  TextColumn get name => text()();
  IntColumn get durationMinutes => integer()();
  TextColumn get sectionsJson => text()();

  /// The `SectionalTiming` enum's name, or null for an exam that publishes
  /// no timing rule. Never defaulted.
  TextColumn get sectionalTiming => text().nullable()();

  /// `{"passAtPercent": 70, "closeAtPercent": 55}`, or null when the exam
  /// has published no thresholds.
  TextColumn get scoreBandsJson => text().nullable()();

  /// Every item the real exam contains, so the setup screen can say what
  /// this practice run leaves out. Null when the exam publishes no total.
  IntColumn get totalPublishedItems => integer().nullable()();

  /// Where the blueprint's numbers came from: `published`, `reported`,
  /// or `unknown`.
  TextColumn get source => text().nullable()();

  /// Citation or attribution note for the blueprint source.
  TextColumn get sourceNote => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
