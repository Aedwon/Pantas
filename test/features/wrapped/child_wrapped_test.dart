import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/wrapped/application/wrapped_providers.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('a child cannot load Wrapped artifacts or shared cards', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setAgeGroup('child');
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        userMetricsArtifactRepositoryProvider.overrideWith(
          (_) => throw StateError('Wrapped must not access the repository'),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(wrappedArtifactProvider('test').future),
      isNull,
    );
    expect(await container.read(sharedWrappedCardsProvider.future), isEmpty);
  });
}
