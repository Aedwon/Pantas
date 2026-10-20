import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';

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
    addTearDown(controller.dispose);
  });

  test('audit stationary short lesson becomes read after dwell floor',
      () async {
    final c = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: progress,
      preferencesRepository: prefs,
    );
    addTearDown(c.dispose);
    await c.onOpen();
    c.onScroll(offset: 0, maxExtent: 0);
    await Future<void>.delayed(readDwellFloor + const Duration(seconds: 1));
    expect(await progress.isRead('l1'), isTrue);
    c.dispose();
  });

  test('audit transient marking failure remains retryable', () async {
    final failing = _AuditFailOnceProgress(db, contentDb);
    final errors = <Object>[];
    final c = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: failing,
      preferencesRepository: prefs,
      clock: clock.call,
    );
    addTearDown(c.dispose);
    await runZonedGuarded(() async {
      await c.onOpen();
      clock.advance(readDwellFloor);
      c.onScroll(offset: 100, maxExtent: 100);
      await pumpEventQueue();
      c.onScroll(offset: 100, maxExtent: 100);
      await pumpEventQueue();
    }, (error, stack) {
      errors.add(error);
    });
    expect(
      errors,
      isEmpty,
      reason: 'The UI never catches this fire-and-forget error.',
    );
    expect(await progress.isRead('l1'), isTrue);
  });

  testWidgets(
      'audit floor check reads current layout instead of old end metrics',
      (tester) async {
    var extent = 0.0;
    var offset = 0.0;
    final c = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: progress,
      preferencesRepository: prefs,
      readMetrics: () => (offset: offset, maxExtent: extent),
    );
    addTearDown(c.dispose);
    await c.onOpen();
    c.onScroll(offset: 0, maxExtent: 0);
    extent = 1000;
    await tester.pump(readDwellFloor);
    await tester.pumpAndSettle();
    expect(await progress.isRead('l1'), isFalse);
    offset = 1000;
    c.onScroll(offset: offset, maxExtent: extent);
    await tester.pumpAndSettle();
    expect(await progress.isRead('l1'), isTrue);
  });
  testWidgets('audit disposal cancels automatic dwell callback',
      (tester) async {
    await controller.onOpen();
    controller
      ..onScroll(offset: 0, maxExtent: 0)
      ..dispose();
    await tester.pump(readDwellFloor);
    await tester.pumpAndSettle();
    expect(await progress.isRead('l1'), isFalse);
  });
  test('audit pending mark suppresses duplicate saves', () async {
    final held = _HeldMarkProgress(db, contentDb);
    final c = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: held,
      preferencesRepository: prefs,
      clock: clock.call,
    );
    addTearDown(c.dispose);
    await c.onOpen();
    clock.advance(readDwellFloor);
    c
      ..onScroll(offset: 0, maxExtent: 0)
      ..onScroll(offset: 0, maxExtent: 0);
    await pumpEventQueue();
    expect(held.calls, 1);
    held.release.complete();
    await pumpEventQueue();
    c.onScroll(offset: 0, maxExtent: 0);
    await pumpEventQueue();
    expect(held.calls, 1);
    expect(await progress.isRead('l1'), isTrue);
  });

  test('audit visibility resumes while rejected mark completion is pending',
      () async {
    final positions = _HeldMarkResult(prefs, database: db);
    final boundary =
        (await positions.captureBoundary('e1', isCurrent: () => true))!;
    final c = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: progress,
      preferencesRepository: prefs,
      clock: clock.call,
      positions: positions,
      boundary: boundary,
    );
    addTearDown(c.dispose);
    await c.onOpen();
    clock.advance(readDwellFloor);
    positions.hold = true;
    c
      ..onScroll(offset: 0, maxExtent: 0)
      ..setVisible(visible: false);
    positions.before.complete();
    await positions.rejected.future;
    c.setVisible(visible: true);
    positions.after.complete();
    await pumpEventQueue();
    expect(await progress.isRead('l1'), isTrue);
  });

  test('audit visibility resume does not automatically retry a storage error',
      () async {
    final failing = _HeldFailureProgress(db, contentDb);
    final c = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: failing,
      preferencesRepository: prefs,
      clock: clock.call,
    );
    addTearDown(c.dispose);
    await c.onOpen();
    clock.advance(readDwellFloor);
    c.onScroll(offset: 0, maxExtent: 0);
    await pumpEventQueue();
    c
      ..setVisible(visible: false)
      ..setVisible(visible: true);
    failing.release.complete();
    await pumpEventQueue();
    expect(failing.calls, 1);
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

  test('marking a lesson read tells whoever is listening, once', () async {
    var marked = 0;
    final listening = ReadMarkingController(
      lessonId: 'l2',
      examId: 'e1',
      progressRepository: progress,
      preferencesRepository: prefs,
      clock: clock.call,
      onMarked: () => marked++,
    );
    await listening.onOpen();
    clock.advance(readDwellFloor);
    listening
      ..onScroll(offset: 1000, maxExtent: 1000)
      ..onScroll(offset: 1000, maxExtent: 1000);
    await pumpEventQueue();

    expect(marked, 1);
  });
  test('a held reader cannot mark or reopen after a real wipe', () async {
    final positions = container.read(readerPositionRepositoryProvider);
    final boundary =
        (await positions.captureBoundary('e1', isCurrent: () => true))!;
    final guarded = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: progress,
      preferencesRepository: prefs,
      clock: clock.call,
      positions: positions,
      boundary: boundary,
    );
    await guarded.onOpen();
    await SyncLocalStateWiper(db).wipeAll();
    clock.advance(readDwellFloor);
    guarded.onScroll(offset: 1000, maxExtent: 1000);
    await pumpEventQueue();
    expect(await progress.isRead('l1'), isFalse);
    expect(await prefs.lastOpenedLessonId('e1'), 'l1');
    await prefs.setDeviceValue('recent_lessons_e1', 'other');
    await guarded.onOpen();
    expect(await prefs.lastOpenedLessonId('e1'), 'other');
  });

  test('disposed marking controller cannot start or complete mutations',
      () async {
    final positions = container.read(readerPositionRepositoryProvider);
    final boundary =
        (await positions.captureBoundary('e1', isCurrent: () => true))!;
    var marked = 0;
    final guarded = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: progress,
      preferencesRepository: prefs,
      clock: clock.call,
      positions: positions,
      boundary: boundary,
      onMarked: () => marked++,
    );
    await guarded.onOpen();
    guarded.dispose();
    clock.advance(readDwellFloor);
    guarded.onScroll(offset: 1000, maxExtent: 1000);
    await guarded.onOpen();
    await pumpEventQueue();
    expect(await progress.isRead('l1'), isFalse);
    expect(marked, 0);
  });
  test('expired page identity blocks marking before its next unmount frame',
      () async {
    final positions = container.read(readerPositionRepositoryProvider);
    final boundary =
        (await positions.captureBoundary('e1', isCurrent: () => true))!;
    var current = true;
    final guarded = ReadMarkingController(
      lessonId: 'l1',
      examId: 'e1',
      progressRepository: progress,
      preferencesRepository: prefs,
      clock: clock.call,
      positions: positions,
      boundary: boundary,
      isCurrent: () => current,
    );
    await guarded.onOpen();
    current = false;
    clock.advance(readDwellFloor);
    guarded.onScroll(offset: 1000, maxExtent: 1000);
    await pumpEventQueue();
    expect(await progress.isRead('l1'), isFalse);
  });
}

class _AuditFailOnceProgress extends LessonProgressRepository {
  _AuditFailOnceProgress(super.db, super.contentDb);
  bool fail = true;
  @override
  Future<void> markRead(String id) async {
    if (fail) {
      fail = false;
      throw Exception('audit storage failure');
    }
    return super.markRead(id);
  }
}

class _HeldMarkProgress extends LessonProgressRepository {
  _HeldMarkProgress(super.db, super.contentDb);
  final release = Completer<void>();
  int calls = 0;
  @override
  Future<void> markRead(String id) async {
    calls++;
    await release.future;
    await super.markRead(id);
  }
}

class _HeldMarkResult extends ReaderPositionRepository {
  _HeldMarkResult(super.preferences, {required super.database});
  bool hold = false;
  final before = Completer<void>();
  final after = Completer<void>();
  final rejected = Completer<void>();
  @override
  Future<bool> runGuarded(
    ReaderBoundary boundary,
    Future<void> Function() operation, {
    required bool Function() isCurrent,
  }) async {
    final held = hold;
    hold = false;
    if (held) await before.future;
    final saved =
        await super.runGuarded(boundary, operation, isCurrent: isCurrent);
    if (held) {
      rejected.complete();
      await after.future;
    }
    return saved;
  }
}

class _HeldFailureProgress extends LessonProgressRepository {
  _HeldFailureProgress(super.db, super.contentDb);
  final release = Completer<void>();
  int calls = 0;
  @override
  Future<void> markRead(String id) async {
    calls++;
    await release.future;
    throw Exception('storage still unavailable');
  }
}
