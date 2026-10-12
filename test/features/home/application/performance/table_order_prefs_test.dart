import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  TableOrderNotifier getNotifier(ProviderContainer c) {
    c.read(tableOrderProvider);
    return c.read(tableOrderProvider.notifier);
  }

  ProviderContainer createFreshContainer() {
    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  }

  test('the default is Score ascending at Subject level', () async {
    final notifier = getNotifier(container);
    expect(await notifier.load(), TableOrder.defaults);
  });

  test('a chosen order survives a reload', () async {
    final notifier = getNotifier(container);
    await notifier.setSortKey(TableSortKey.time);
    await notifier.setLevel(TableLevel.topic);

    final freshContainer = createFreshContainer();
    addTearDown(freshContainer.dispose);
    final freshNotifier = getNotifier(freshContainer);

    final loaded = await freshNotifier.load();
    expect(loaded.sortKey, TableSortKey.time);
    expect(loaded.level, TableLevel.topic);
  });

  test('with retention off, a reload returns the defaults', () async {
    final settingsRepo = container.read(settingsRepositoryProvider);
    await settingsRepo.updateRetainTableOrder(enabled: false);

    final notifier = getNotifier(container);
    await notifier.setSortKey(TableSortKey.time);

    final freshContainer = createFreshContainer();
    addTearDown(freshContainer.dispose);
    final freshNotifier = getNotifier(freshContainer);

    expect(await freshNotifier.load(), TableOrder.defaults);
  });

  test('with retention off, a change still applies within the visit', () async {
    final settingsRepo = container.read(settingsRepositoryProvider);
    await settingsRepo.updateRetainTableOrder(enabled: false);

    final notifier = getNotifier(container);
    await notifier.setSortKey(TableSortKey.time);

    expect(notifier.state.value?.sortKey, TableSortKey.time);
  });

  test('an unrecognised stored value falls back to the default', () async {
    final prefs = container.read(appPreferencesRepositoryProvider);
    await prefs.setDeviceValue('progress_table_sort', 'wibble');

    final notifier = getNotifier(container);
    expect((await notifier.load()).sortKey, TableSortKey.score);
  });

  test('a subject filter survives a reload', () async {
    final notifier = getNotifier(container);
    await notifier.setLevel(TableLevel.topic);
    await notifier.setSubjectId('sci');

    final freshContainer = createFreshContainer();
    addTearDown(freshContainer.dispose);
    final freshNotifier = getNotifier(freshContainer);

    final loaded = await freshNotifier.load();
    expect(loaded.subjectId, 'sci');
  });

  test('choosing All clears the stored filter', () async {
    final notifier = getNotifier(container);
    await notifier.setLevel(TableLevel.topic);
    await notifier.setSubjectId('sci');
    await notifier.setSubjectId(null);

    final freshContainer = createFreshContainer();
    addTearDown(freshContainer.dispose);
    final freshNotifier = getNotifier(freshContainer);

    expect((await freshNotifier.load()).subjectId, isNull);
  });

  test('going back to Subject level drops the filter', () async {
    final notifier = getNotifier(container);
    await notifier.setLevel(TableLevel.topic);
    await notifier.setSubjectId('sci');
    await notifier.setLevel(TableLevel.subject);

    expect(notifier.state.value?.subjectId, isNull);

    final freshContainer = createFreshContainer();
    addTearDown(freshContainer.dispose);
    final freshNotifier = getNotifier(freshContainer);

    expect((await freshNotifier.load()).subjectId, isNull);
  });
}
