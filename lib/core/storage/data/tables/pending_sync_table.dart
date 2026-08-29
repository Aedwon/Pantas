// coverage:ignore-file
import 'package:drift/drift.dart';

@TableIndex(
  name: 'pending_sync_generation_row_idx',
  columns: {#uid, #generationId, #tableType, #rowId},
  unique: true,
)
@TableIndex(name: 'pending_sync_queued_at_idx', columns: {#queuedAt})
@DataClassName('PendingSyncRow')
class PendingSync extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().withDefault(const Constant(''))();
  TextColumn get generationId => text().withDefault(const Constant(''))();
  TextColumn get tableType => text()();
  TextColumn get rowId => text()();
  TextColumn get op => text()();
  TextColumn get baseState => text().withDefault(const Constant('unbound'))();
  DateTimeColumn get baseUpdatedAt => dateTime().nullable()();
  TextColumn get mutationId => text().withDefault(const Constant(''))();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  DateTimeColumn get queuedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}
