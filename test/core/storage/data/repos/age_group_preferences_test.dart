import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AppPreferencesRepository repo;
  setUp(() {
    db = inMemoryDatabase();
    repo = AppPreferencesRepository(db);
  });
  tearDown(() => db.close());

  test('the age group is stored, and no birth year is', () async {
    expect(await repo.ageGroup(), isNull);
    await repo.setAgeGroup('minor');
    expect(await repo.ageGroup(), 'minor');
    await repo.setAgeGroup('adult');
    expect(await repo.ageGroup(), 'adult');
    final rows = await db.select(db.devicePrefs).get();
    expect(
      rows.map((r) => r.value),
      isNot(contains(matches(r'^(19|20)\d\d$'))),
    );
  });

  test('the under-minimum block remembers the minimum it was set against',
      () async {
    expect(await repo.blockedMinimumAge(), isNull);
    await repo.setBlockedMinimumAge(13);
    expect(await repo.blockedMinimumAge(), 13);
  });

  test('guardian contact is kept for Resend and can be cleared', () async {
    expect(await repo.guardianContact(), isNull);
    await repo.setGuardianContact(name: 'Maria', email: 'maria@gmail.com');
    final saved = await repo.guardianContact();
    expect(saved?.name, 'Maria');
    expect(saved?.email, 'maria@gmail.com');
    await repo.clearGuardianContact();
    expect(await repo.guardianContact(), isNull);
  });

  test('the status cache is only a fallback for an offline start', () async {
    expect(await repo.guardianStatusCache(), isNull);
    await repo.setGuardianStatusCache('pending');
    expect(await repo.guardianStatusCache(), 'pending');
  });
}
