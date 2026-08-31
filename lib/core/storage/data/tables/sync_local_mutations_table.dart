// coverage:ignore-file
import 'package:drift/drift.dart';

@TableIndex(
  name: 'sync_local_mutations_epoch_idx',
  columns: {#mutationEpoch},
)
@TableIndex(
  name: 'sync_local_mutations_recorded_at_idx',
  columns: {#recordedAt},
)
@DataClassName('SyncLocalMutationRow')
class SyncLocalMutations extends Table {
  TextColumn get collection => text()();
  TextColumn get rowId => text()();
  TextColumn get op => text()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  IntColumn get mutationEpoch => integer()();
  TextColumn get causalUid => text().nullable()();
  TextColumn get causalGenerationId => text().nullable()();
  TextColumn get causalBaseState => text()();
  DateTimeColumn get baseUpdatedAt => dateTime().nullable()();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {collection, rowId};
}
