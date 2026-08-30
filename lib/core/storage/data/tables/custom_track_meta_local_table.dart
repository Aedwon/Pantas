// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('CustomTrackMetaLocalRow')
class CustomTrackMetaLocal extends Table {
  TextColumn get examId => text()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {examId};
}
