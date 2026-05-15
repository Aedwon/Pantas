// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('QuizNudgeDismissedLocalRow')
class QuizNudgeDismissedLocal extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get dismissedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
