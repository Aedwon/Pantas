import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/metrics/atoms/atom.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/home_atom_provider.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('selects a fallback atom when the first rotated atom has no data',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final contentDb = openTestContentDatabase();
    addTearDown(db.close);
    for (var i = 0; i < 7; i += 1) {
      await db.into(db.quizSessions).insert(
            QuizSessionsCompanion.insert(
              id: 'session_$i',
              userId: 'user_1',
              examId: 'exam_cse',
              origin: 'today_topic',
              questionIdsJson: '[]',
              currentIndex: const Value(10),
              correctCount: const Value(8),
              startedAt: DateTime.utc(2026, 6, 1, 21),
              completedAt: Value(DateTime.utc(2026, 6, 1, 21, 10)),
            ),
          );
    }
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);

    final chip = await container.read(
      homeAtomProvider(
        HomeAtomRequest(
          examId: 'exam_cse',
          userId: 'user_1',
          localDate: DateTime(2026, 6, 10),
          now: DateTime.utc(2026, 6, 10),
          rotationOrderOverride: const [
            AtomKey.coverageBreadth,
            AtomKey.timeOfDay,
          ],
        ),
      ).future,
    );

    expect(chip?.text, 'Sharpest at 9pm');
  });
}
