import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/application/reader_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

class TestClock {
  DateTime now = DateTime(2026, 8, 9, 10);

  DateTime call() => now;

  void advance(Duration duration) {
    now = now.add(duration);
  }
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;
  late LessonProgressRepository progress;
  late AppPreferencesRepository prefs;
  late TestClock clock;
  late ReadMarkingController controller;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    progress = container.read(lessonProgressRepositoryProvider);
    prefs = container.read(appPreferencesRepositoryProvider);
    clock = TestClock();

    controller = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: progress,
      preferencesRepository: prefs,
      clock: clock.call,
    );
  });

  test('reaching the end after the floor marks it read', () async {
    await controller.onOpen();
    clock.advance(readDwellFloor);
    controller.onScroll(offset: 1000, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isTrue);
  });

  test('flicking to the end inside the floor does not mark it', () async {
    await controller.onOpen();
    clock.advance(const Duration(seconds: 2));
    controller.onScroll(offset: 1000, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isFalse);
  });

  test('a flick then waiting still marks it on the next scroll', () async {
    await controller.onOpen();
    controller.onScroll(offset: 1000, maxExtent: 1000);
    clock.advance(readDwellFloor);
    controller.onScroll(offset: 995, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isTrue);
  });

  test('stopping short of the end never marks it', () async {
    await controller.onOpen();
    clock.advance(const Duration(minutes: 5));
    controller.onScroll(offset: 600, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isFalse);
  });

  test('a lesson shorter than the viewport is at its end immediately',
      () async {
    await controller.onOpen();
    clock.advance(readDwellFloor);
    controller.onScroll(offset: 0, maxExtent: 0);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isTrue);
  });

  test('marking happens once, not on every scroll frame', () async {
    await controller.onOpen();
    clock.advance(readDwellFloor);
    controller
      ..onScroll(offset: 1000, maxExtent: 1000)
      ..onScroll(offset: 1000, maxExtent: 1000);
    await pumpEventQueue();

    expect(await progress.isRead('l1'), isTrue);
  });

  test('opening records it as recently opened', () async {
    await controller.onOpen();

    expect(await prefs.lastOpenedLessonId('e1'), 'l1');
  });
}
