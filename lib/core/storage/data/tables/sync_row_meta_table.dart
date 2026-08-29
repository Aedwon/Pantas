// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('SyncRowMetaRow')
class SyncRowMeta extends Table {
  TextColumn get collection => text()();
  TextColumn get rowId => text()();
  TextColumn get state => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get originDeviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {collection, rowId};
}
