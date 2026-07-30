import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/lesson/domain/models/bookmark_order.dart';

/// The chosen bookmark order, in `account_prefs` so it syncs. The hand
/// ordering in `lesson_bookmarks_local.sortIndex` already does, and an order
/// arriving on a second device without the setting that displays it would
/// show the arrangement to nobody.
class BookmarkPrefsRepository {
  BookmarkPrefsRepository(this._db);

  static const orderKey = 'bookmark_order';

  final AppDatabase _db;

  Future<BookmarkOrder> readOrder() async {
    final row = await (_db.select(_db.accountPrefs)
          ..where((pref) => pref.key.equals(orderKey)))
        .getSingleOrNull();
    return BookmarkOrder.fromStorage(row?.value);
  }

  Future<void> saveOrder(BookmarkOrder order) async {
    await _db.into(_db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: orderKey,
            value: order.storageValue,
          ),
        );
  }
}
