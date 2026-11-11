import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';

/// The viewer retains its original boundary across load and save retries.
class QuizNoteBoundary {
  QuizNoteBoundary._(this._db, this._token, this._isCurrent, this.ownerUid);
  final AppDatabase _db;
  final String? _token;
  final String? ownerUid;
  final bool Function() _isCurrent;

  static Future<QuizNoteBoundary?> capture(
    AppDatabase db, {
    required bool Function() isCurrent,
  }) async {
    if (!isCurrent()) return null;
    final snapshot = await SyncActiveContextStore(db).readSnapshot();
    if (!isCurrent()) return null;
    return QuizNoteBoundary._(
      db,
      snapshot?.token,
      isCurrent,
      snapshot?.context?.uid,
    );
  }

  Future<bool> allows() async {
    if (!_isCurrent()) return false;
    final snapshot = await SyncActiveContextStore(_db).readSnapshot();
    return _isCurrent() && snapshot?.token == _token;
  }
}
