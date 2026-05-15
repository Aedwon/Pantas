import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AttemptsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = AttemptsRepository(db);
  });

  tearDown(() => db.close());

  test('countForExam returns 0 when no attempts exist', () async {
    expect(await repo.countForExam('e1'), equals(0));
  });

  test('countForExam counts only attempts for the given exam', () async {
    final now = DateTime(2026, 1, 1);
    await repo.save(
      Attempt(id: 'a1', examId: 'e1', startedAt: now, completedAt: now, items: []),
    );
    await repo.save(
      Attempt(id: 'a2', examId: 'e1', startedAt: now, completedAt: now, items: []),
    );
    await repo.save(
      Attempt(id: 'a3', examId: 'e2', startedAt: now, completedAt: now, items: []),
    );
    expect(await repo.countForExam('e1'), equals(2));
    expect(await repo.countForExam('e2'), equals(1));
  });
}
