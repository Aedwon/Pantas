import 'package:drift/drift.dart';

@DataClassName('ReviewStateLocalRow')
class ReviewStateLocal extends Table {
  TextColumn get questionId => text()();
  IntColumn get questionVersion => integer()();
  TextColumn get stage => text()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  DateTimeColumn get due => dateTime()();
  DateTimeColumn get lastReview => dateTime()();
  IntColumn get reps => integer()();
  IntColumn get lapses => integer()();
  RealColumn get elapsedDays => real()();
  RealColumn get scheduledDays => real()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {questionId};
}
