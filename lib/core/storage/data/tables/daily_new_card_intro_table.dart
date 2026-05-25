import 'package:drift/drift.dart';

@DataClassName('DailyNewCardIntroRow')
class DailyNewCardIntro extends Table {
  TextColumn get userId => text()();
  TextColumn get examId => text()();
  DateTimeColumn get day => dateTime()();
  IntColumn get newCardsIntroduced =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {userId, examId, day};
}
