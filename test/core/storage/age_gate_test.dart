import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('returns false when preference is unset', () async {
    expect(await container.read(passedAgeGateProvider.future), isFalse);
  });

  test('returns true after setPassedAgeGate(true)', () async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    container.invalidate(passedAgeGateProvider);

    expect(await container.read(passedAgeGateProvider.future), isTrue);
  });
}
