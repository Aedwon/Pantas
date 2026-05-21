// coverage:ignore-file
import 'package:drift/drift.dart';

@TableIndex(
  name: 'pending_sync_table_row_idx',
  columns: {#tableType, #rowId},
  unique: true,
)
@TableIndex(name: 'pending_sync_queued_at_idx', columns: {#queuedAt})
@DataClassName('PendingSyncRow')
class PendingSync extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableType => text()();
  TextColumn get rowId => text()();
  TextColumn get op => text()();
  DateTimeColumn get queuedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}
