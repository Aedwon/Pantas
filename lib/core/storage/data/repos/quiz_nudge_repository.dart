import 'package:pantas/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';

class QuizNudgeRepository {
  QuizNudgeRepository(this._db);

  final AppDatabase _db;

  Future<bool> hasDismissed() async {
    final row = await (_db.select(_db.quizNudgeDismissedLocal)
          ..where((n) => n.id.equals(1)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> markDismissed() async {
    await _db.into(_db.quizNudgeDismissedLocal).insertOnConflictUpdate(
          QuizNudgeDismissedLocalCompanion.insert(
            id: const Value(1),
            dismissedAt: DateTime.now(),
          ),
        );
  }
}
