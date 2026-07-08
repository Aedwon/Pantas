// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('ReviewLogRow')
class ReviewLogs extends Table {
  TextColumn get id => text()();
  TextColumn get questionId => text().named('question_id')();
  IntColumn get rating => integer()();
  IntColumn get state => integer()();
  DateTimeColumn get due => dateTime()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  RealColumn get elapsedDays => real().named('elapsed_days')();
  RealColumn get lastElapsedDays => real().named('last_elapsed_days')();
  RealColumn get scheduledDays => real().named('scheduled_days')();
  DateTimeColumn get review => dateTime()();
  IntColumn get durationMs => integer().named('duration_ms')();

  /// The heuristic's inputs, kept alongside the rating it produced.
  ///
  /// The rating is derived from correctness, response time and the interval
  /// the card was on. Storing only the rating is the exact mistake this table
  /// exists to correct: a revised heuristic could then never re-rate history.
  BoolColumn get isCorrect => boolean().named('is_correct')();

  /// Which rating heuristic produced this row's rating.
  ///
  /// A fit runs over one version's rows. Without this, changing the heuristic
  /// silently mixes ratings that do not mean the same thing.
  IntColumn get heuristicVersion =>
      integer().named('heuristic_version').withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
