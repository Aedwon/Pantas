// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('ExamRow')
class Exams extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  TextColumn get language => text()();

  /// A track the student named themselves. Never listed in the exam picker,
  /// and identical to a listed exam everywhere else, because every table in
  /// the app keys on an exam id and none of them care where the row came
  /// from.
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
