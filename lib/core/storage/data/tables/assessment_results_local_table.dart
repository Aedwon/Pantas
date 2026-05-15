// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('AssessmentResultLocalRow')
class AssessmentResultsLocal extends Table {
  TextColumn get examId => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get topicScoresJson => text()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {examId};
}
