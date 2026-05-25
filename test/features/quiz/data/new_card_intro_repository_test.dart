import 'package:cse_cet_reviewer/features/quiz/data/repos/new_card_intro_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('countForDay returns zero when no new cards were introduced', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final count = await NewCardIntroRepository(db).countForDay(
      userId: 'user',
      examId: 'exam',
      day: DateTime(2026, 5, 18, 12),
    );

    expect(count, 0);
  });

  test('incrementForDay adds to the local midnight bucket', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = NewCardIntroRepository(db);

    await repo.incrementForDay(
      userId: 'user',
      examId: 'exam',
      day: DateTime(2026, 5, 18, 12),
      by: 2,
    );
    await repo.incrementForDay(
      userId: 'user',
      examId: 'exam',
      day: DateTime(2026, 5, 18, 23, 59),
      by: 1,
    );

    expect(
      await repo.countForDay(
        userId: 'user',
        examId: 'exam',
        day: DateTime(2026, 5, 18, 8),
      ),
      3,
    );
    final row = await db.select(db.dailyNewCardIntro).getSingle();
    expect(row.day, DateTime(2026, 5, 18));
  });

  test('countForDay is scoped by user exam and day', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = NewCardIntroRepository(db);

    await repo.incrementForDay(
      userId: 'user',
      examId: 'exam',
      day: DateTime(2026, 5, 18),
      by: 1,
    );
    await repo.incrementForDay(
      userId: 'other',
      examId: 'exam',
      day: DateTime(2026, 5, 18),
      by: 2,
    );
    await repo.incrementForDay(
      userId: 'user',
      examId: 'other-exam',
      day: DateTime(2026, 5, 18),
      by: 3,
    );
    await repo.incrementForDay(
      userId: 'user',
      examId: 'exam',
      day: DateTime(2026, 5, 19),
      by: 4,
    );

    expect(
      await repo.countForDay(
        userId: 'user',
        examId: 'exam',
        day: DateTime(2026, 5, 18),
      ),
      1,
    );
  });
}
