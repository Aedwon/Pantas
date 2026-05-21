// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('AccountPrefRow')
class AccountPrefs extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
