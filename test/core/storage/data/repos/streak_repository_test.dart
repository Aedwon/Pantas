import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/streak_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late StreakRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = StreakRepository(db);
  });
  tearDown(() => db.close());

  test('read on empty DB returns the zero-state default', () async {
    final s = await repo.read();
    expect(s.current, equals(0));
    expect(s.longest, equals(0));
    expect(s.lastActiveDate, isNull);
  });

  test('writeCurrent persists current and bumps longest when exceeded',
      () async {
    final today = DateTime.utc(2026, 5, 9);
    await repo.writeCurrent(current: 3, lastActiveDate: today);
    var s = await repo.read();
    expect(s.current, equals(3));
    expect(s.longest, equals(3));

    await repo.writeCurrent(current: 5, lastActiveDate: today);
    s = await repo.read();
    expect(s.longest, equals(5));

    await repo.writeCurrent(current: 2, lastActiveDate: today);
    s = await repo.read();
    expect(s.current, equals(2));
    expect(s.longest, equals(5));
  });
}
