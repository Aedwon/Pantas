// coverage:ignore-file
import 'package:drift/drift.dart';

/// Lessons and question sets received from the server (web only).
///
/// `tier` records which account tier the copy was built for, so Pro-only
/// fields can be removed when the account signs out or Pro ends.
@DataClassName('CachedContentRow')
class CachedContent extends Table {
  TextColumn get kind => text()();
  TextColumn get id => text()();
  TextColumn get version => text()();
  TextColumn get tier => text()();
  TextColumn get dataJson => text()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {kind, id};
}
