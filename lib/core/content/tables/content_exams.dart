import 'package:drift/drift.dart';

@DataClassName('ContentExamRow')
class ContentExams extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  TextColumn get language => text()();
  IntColumn get ordering => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
