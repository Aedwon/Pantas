// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('DevicePrefRow')
class DevicePrefs extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
