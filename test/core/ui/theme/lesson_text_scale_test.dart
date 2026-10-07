import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('defaults to 1.0 without a saved preference', () async {
    final db = inMemoryDatabase();
    final prefs = AppPreferencesRepository(db);
    final container = ProviderContainer(
      overrides: [appPreferencesRepositoryProvider.overrideWithValue(prefs)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    expect(container.read(lessonTextScaleProvider), 1.0);
    expect(await prefs.deviceValue('lesson_text_scale'), isNull);
  });

  test('persists through AppPreferencesRepository and reloads', () async {
    final db = inMemoryDatabase();
    final prefs = AppPreferencesRepository(db);
    final first = ProviderContainer(
      overrides: [appPreferencesRepositoryProvider.overrideWithValue(prefs)],
    );
    await first.read(lessonTextScaleProvider.notifier).setScale(1.4);
    expect(first.read(lessonTextScaleProvider), 1.4);
    expect(await prefs.deviceValue('lesson_text_scale'), '1.4');
    first.dispose();
    final second = ProviderContainer(
      overrides: [appPreferencesRepositoryProvider.overrideWithValue(prefs)],
    );
    addTearDown(() async {
      second.dispose();
      await db.close();
    });
    await _waitForScale(second, 1.4);
  });

  test('rapid updates persist the last selected value', () async {
    final db = inMemoryDatabase();
    final prefs = AppPreferencesRepository(db);
    final container = ProviderContainer(
      overrides: [appPreferencesRepositoryProvider.overrideWithValue(prefs)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final controller = container.read(lessonTextScaleProvider.notifier);
    await Future.wait([controller.setScale(1.2), controller.setScale(1.6)]);
    expect(container.read(lessonTextScaleProvider), 1.6);
    expect(await prefs.deviceValue('lesson_text_scale'), '1.6');
  });

  test('rejects invalid scale values without saving them', () async {
    final db = inMemoryDatabase();
    final prefs = AppPreferencesRepository(db);
    final container = ProviderContainer(
      overrides: [appPreferencesRepositoryProvider.overrideWithValue(prefs)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final controller = container.read(lessonTextScaleProvider.notifier);
    for (final scale in [0.0, -1.0, double.nan, double.infinity]) {
      await expectLater(controller.setScale(scale), throwsArgumentError);
    }
    expect(container.read(lessonTextScaleProvider), 1.0);
    expect(await prefs.deviceValue('lesson_text_scale'), isNull);
  });

  testWidgets('multiplies nonlinear phone scaling only inside the subtree',
      (tester) async {
    final db = inMemoryDatabase();
    final prefs = AppPreferencesRepository(db);
    final container = ProviderContainer(
      overrides: [appPreferencesRepositoryProvider.overrideWithValue(prefs)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    await container.read(lessonTextScaleProvider.notifier).setScale(1.25);
    TextScaler? inside;
    TextScaler? outside;
    const phone = _NonlinearPhoneScaler();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: phone),
            child: Column(
              children: [
                LessonTextScale(
                  child: Builder(
                    builder: (context) {
                      inside = MediaQuery.textScalerOf(context);
                      return const Text('Lesson',
                          style: TextStyle(fontSize: 14));
                    },
                  ),
                ),
                Builder(
                  builder: (context) {
                    outside = MediaQuery.textScalerOf(context);
                    return const Text('Control',
                        style: TextStyle(fontSize: 14));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(inside!.scale(10), 25);
    expect(inside!.scale(30), 112.5);
    expect(outside, same(phone));
    expect(outside!.scale(10), 20);
    expect(outside!.scale(30), 90);
  });
}

Future<void> _waitForScale(ProviderContainer container, double value) async {
  final ready = Completer<void>();
  final subscription = container.listen(
    lessonTextScaleProvider,
    (_, next) {
      if (next == value && !ready.isCompleted) ready.complete();
    },
    fireImmediately: true,
  );
  try {
    await ready.future.timeout(const Duration(seconds: 5));
  } finally {
    subscription.close();
  }
}

class _NonlinearPhoneScaler extends TextScaler {
  const _NonlinearPhoneScaler();
  @override
  double scale(double fontSize) => fontSize * (fontSize < 20 ? 2 : 3);
  @override
  double get textScaleFactor => 2;
}
