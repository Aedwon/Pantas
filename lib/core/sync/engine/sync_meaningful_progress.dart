import 'package:drift/drift.dart' show Selectable;
import 'package:pantas/core/storage/data/app_database.dart';

/// Detects meaningful data that belongs to the Wave 2E cloud snapshot.
///
/// This is intentionally narrower than account/privacy wipe sensitivity. In
/// particular, an in-progress mock attempt remains device-local until it
/// reaches a terminal state and therefore does not participate in B3.
class SyncMeaningfulProgress {
  const SyncMeaningfulProgress(this._db);

  final AppDatabase _db;

  Future<bool> hasMeaningfulData() async {
    if (await _hasAny(_db.select(_db.attemptsLocal))) return true;
    if (await _hasAny(_db.select(_db.assessmentResultsLocal))) return true;
    if (await _hasAny(_db.select(_db.reviewStateLocal))) return true;
    if (await _hasAny(_db.select(_db.lessonProgressLocal))) return true;
    if (await _hasAny(_db.select(_db.lessonBookmarksLocal))) return true;
    if (await _hasAny(_db.select(_db.questionFlagsLocal))) return true;

    final terminalMocks = _db.select(_db.mockAttempts)
      ..where(
        (row) => row.status.isIn(
          const ['completed', 'discarded', 'forfeited'],
        ),
      )
      ..limit(1);
    if ((await terminalMocks.get()).isNotEmpty) return true;

    if (await _hasAny(_db.select(_db.reviewLogs))) return true;
    if (await _hasAny(_db.select(_db.customTrackMetaLocal))) return true;
    if (await _hasAny(_db.select(_db.trackScopeLocal))) return true;
    if (await _hasAny(_db.select(_db.customBlueprintsLocal))) return true;
    return false;
  }

  Future<bool> _hasAny<T>(Selectable<T> query) async {
    return (await query.get()).isNotEmpty;
  }
}
