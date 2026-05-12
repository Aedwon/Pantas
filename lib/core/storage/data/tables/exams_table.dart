// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('ExamRow')
class Exams extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  TextColumn get language => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
