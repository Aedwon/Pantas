// coverage:ignore-file
import 'package:pantas/core/storage/data/tables/questions_table.dart';
import 'package:drift/drift.dart';

/// A question the student kept for later, from the reveal or from a mock's
/// review. Durable: unlike `mock_attempt.flagsJson`, which expires with the
/// paper it was set on, a row here outlives every session.
@DataClassName('QuestionFlagLocalRow')
class QuestionFlagsLocal extends Table {
  TextColumn get questionId => text().references(Questions, #id)();
  DateTimeColumn get flaggedAt => dateTime()();

  /// Reserved for Pro custom ordering. Null means "order by flaggedAt".
  IntColumn get sortIndex => integer().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {questionId};
}
