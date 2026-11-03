import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/reader_full_width.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppPreferencesRepository prefs;
  late ProviderContainer container;

  ProviderContainer open() => ProviderContainer(
        overrides: [appPreferencesRepositoryProvider.overrideWithValue(prefs)],
      );

  setUp(() {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    prefs = AppPreferencesRepository(db);
    container = open();
    addTearDown(() => container.dispose());
  });

  test('starts at the standard width without a saved choice', () async {
    expect(container.read(readerFullWidthProvider), isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(readerFullWidthProvider), isFalse);
    expect(await prefs.deviceValue('reader_full_width'), isNull);
  });

  test('the column is 680 px, or at most 800 px at full width', () {
    expect(readerStandardWidth, 680);
    expect(readerFullWidthMax, 800);
  });

  test('remembers the choice on this device and reloads it', () async {
    await container
        .read(readerFullWidthProvider.notifier)
        .setFullWidth(fullWidth: true);
    expect(container.read(readerFullWidthProvider), isTrue);
    expect(await prefs.deviceValue('reader_full_width'), '1');
    container.dispose();

    container = open();
    addTearDown(() => container.dispose());
    container.read(readerFullWidthProvider);
    await _waitFor(container, true);

    await container
        .read(readerFullWidthProvider.notifier)
        .setFullWidth(fullWidth: false);
    expect(await prefs.deviceValue('reader_full_width'), '0');
  });

  test('an unreadable saved value keeps the standard width', () async {
    await prefs.setDeviceValue('reader_full_width', 'wide');
    container.read(readerFullWidthProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(container.read(readerFullWidthProvider), isFalse);
  });

  test('rapid changes save the last one', () async {
    final controller = container.read(readerFullWidthProvider.notifier);
    await Future.wait([
      controller.setFullWidth(fullWidth: true),
      controller.setFullWidth(fullWidth: false),
      controller.setFullWidth(fullWidth: true),
    ]);
    expect(container.read(readerFullWidthProvider), isTrue);
    expect(await prefs.deviceValue('reader_full_width'), '1');
  });
}

Future<void> _waitFor(ProviderContainer container, bool expected) async {
  for (var i = 0; i < 100; i++) {
    if (container.read(readerFullWidthProvider) == expected) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(container.read(readerFullWidthProvider), expected);
}
