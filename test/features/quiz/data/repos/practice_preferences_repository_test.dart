import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/data/repos/practice_preferences_repository.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('last picks and length reopen independently for each exam', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = PracticePreferencesRepository(db);
    await repo.save(
      'e',
      lessonIds: {'a', 'b'},
      mode: PracticeUnitMode.minutes,
      value: 30,
      adjustments: {'lesson:a': 20, 'lesson:b': 13},
    );
    final reopened = await PracticePreferencesRepository(db).read('e');
    expect(reopened.lessonIds, {'a', 'b'});
    expect(reopened.mode, PracticeUnitMode.minutes);
    expect(reopened.value, 30);
    expect(reopened.adjustments, {'lesson:a': 20, 'lesson:b': 13});
    final fresh = await repo.read('other');
    expect(fresh.lessonIds, isEmpty);
    expect(fresh.mode, PracticeUnitMode.questions);
    expect(fresh.value, 10);
    final rows = await db.select(db.devicePrefs).get();
    expect(
      rows.map((r) => r.key).toSet(),
      {'practice_last_picks.e', 'practice_last_length.e'},
    );
  });
}
