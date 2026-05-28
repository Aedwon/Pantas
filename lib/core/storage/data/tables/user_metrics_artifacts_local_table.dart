// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('UserMetricsArtifactLocalRow')
class UserMetricsArtifactsLocal extends Table {
  TextColumn get userId => text()();
  TextColumn get examId => text()();
  TextColumn get artifactId => text()();
  TextColumn get shareId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get firedAt => dateTime()();
  DateTimeColumn get sharedAt => dateTime().nullable()();
  TextColumn get sharePlatform => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {userId, examId, artifactId};
}
