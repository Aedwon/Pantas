import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/quiz_nudge_repository.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late QuizNudgeRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = QuizNudgeRepository(db);
  });

  tearDown(() => db.close());

  test('hasDismissed returns false before any dismissal', () async {
    expect(await repo.hasDismissed(), isFalse);
  });

  test('hasDismissed returns true after markDismissed', () async {
    await repo.markDismissed();
    expect(await repo.hasDismissed(), isTrue);
  });

  test('markDismissed is idempotent', () async {
    await repo.markDismissed();
    await repo.markDismissed();
    final rows = await db.select(db.quizNudgeDismissedLocal).get();
    expect(rows, hasLength(1));
  });
}
