import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_pull_to_advance.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

Map<String, Object?> _block(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'text': text},
      ],
    };

ReaderContext _reader({required int paragraphs}) => ReaderContext(
      lesson: Lesson(
        id: 'l1',
        topicId: 't1',
        title: 'Layers',
        summary: '',
        estimatedMinutes: 11,
        bodyJson: [
          _block('Core Concept', style: 'h2'),
          for (var i = 0; i < paragraphs; i++)
            _block('Paragraph $i of the lesson text, long enough to be read.'),
        ],
      ),
      topicId: 't1',
      topicName: 'Earth Science',
      next: null,
      positionInTopic: 1,
      lessonsInTopic: 2,
      topicLessons: const [],
      isRead: false,
      isBookmarked: false,
      examId: 'e',
    );

/// A wheel event the way the browser reports it: a delta in logical pixels.
PointerScrollEvent _wheel(double dy, {Offset at = const Offset(720, 450)}) =>
    PointerScrollEvent(position: at, scrollDelta: Offset(0, dy));

/// The wheel step that moves the pull by [share] of a full pull.
double _step(double share) => webPullFullAt * share / webPullResistance;

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late AppDatabase db;
  late ScrollController scroll;
  late ValueNotifier<double> offset;
  late ValueNotifier<double> progress;
  late WebPullController pull;
  var commits = 0;
  var advances = 0;
  Object contentKey = 'l1';

  setUp(() {
    db = inMemoryDatabase();
    addTearDown(db.close);
    scroll = ScrollController();
    offset = ValueNotifier<double>(0);
    progress = ValueNotifier<double>(0);
    addTearDown(scroll.dispose);
    addTearDown(offset.dispose);
    addTearDown(progress.dispose);
    commits = 0;
    advances = 0;
    contentKey = 'l1';
  });

  Future<void> pump(
    WidgetTester tester, {
    int paragraphs = 40,
    bool enabled = true,
    bool still = false,
    bool incoming = false,
  }) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    final reader = _reader(paragraphs: paragraphs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: still),
            child: child!,
          ),
          home: Scaffold(
            body: WebPullToAdvance(
              scrollController: scroll,
              enabled: enabled,
              contentKey: contentKey,
              destinationKey: 'l2',
              onCommit: () => commits++,
              onAdvance: () => advances++,
              incomingBuilder: incoming
                  ? (_) => const ColoredBox(
                        key: ValueKey('incoming-sheet'),
                        color: Colors.white,
                        child: Text('Next lesson sheet'),
                      )
                  : null,
              builder: (context, controller) {
                pull = controller;
                return WebReaderLayout(
                  reader: reader,
                  controller: scroll,
                  scrollOffset: offset,
                  progress: progress,
                  onBack: () {},
                  onBookmark: () {},
                  onLesson: (_) {},
                  pull: controller,
                  onNext: enabled ? controller.commit : null,
                  footer: WebReaderNext(
                    label: 'Next in Earth Science',
                    title: 'Plate Tectonics',
                    detail: '12 min',
                    pull: controller,
                    onPressed: controller.commit,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> toEnd(WidgetTester tester) async {
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    // A rest at the end, so the next wheel input is a new gesture.
    await tester.pump(webPullGestureGap * 2);
  }

  /// Lets time pass in 10 ms frames, so a timer that fires early or late
  /// shows. One long pump would run the timer and skip its effect.
  Future<void> elapse(WidgetTester tester, Duration time) async {
    var left = time.inMilliseconds;
    while (left > 0) {
      final step = left < 10 ? left : 10;
      await tester.pump(Duration(milliseconds: step));
      left -= step;
    }
  }

  Future<void> send(WidgetTester tester, double dy, {Offset? at}) async {
    await tester.sendEventToBinding(
      at == null ? _wheel(dy) : _wheel(dy, at: at),
    );
  }

  Future<void> burst(
    WidgetTester tester,
    int count,
    double dy, {
    Duration every = const Duration(milliseconds: 16),
  }) async {
    for (var i = 0; i < count; i++) {
      await send(tester, dy);
      await tester.pump(every);
    }
  }

  group('a wheel or trackpad pull at the end of the lesson', () {
    testWidgets('the named tuning values are the approved ones', (_) async {
      expect(webPullFullAt, 120);
      expect(webPullOpenAfter, const Duration(milliseconds: 280));
      expect(webPullGestureGap, const Duration(milliseconds: 150));
      expect(webPullDropBackAfter, const Duration(milliseconds: 450));
      expect(webPullRise, const Duration(milliseconds: 480));
    });

    testWidgets('one wheel notch at the end does nothing', (tester) async {
      await pump(tester);
      await toEnd(tester);
      await send(tester, 100);
      await tester.pump();
      // 100 px counts as a quarter of a full pull.
      expect(pull.fraction, closeTo(.25, .001));
      expect(pull.armed, isFalse);
      await elapse(
        tester,
        webPullDropBackAfter - const Duration(milliseconds: 10),
      );
      expect(pull.fraction, closeTo(.25, .001));
      await elapse(tester, const Duration(milliseconds: 20));
      const settle = Duration(milliseconds: 20);
      await elapse(tester, webPullSpringBack + settle);
      expect(pull.fraction, 0);
      await tester.pump(const Duration(seconds: 5));
      expect(commits, 0);
      expect(advances, 0);
    });

    testWidgets('momentum from the gesture that reached the end is ignored', (
      tester,
    ) async {
      await pump(tester);
      expect(scroll.offset, 0);
      // One gesture: a fling that decays, event after event, and runs into
      // the end. It never rests for a gap, so it is one gesture.
      var reachedEnd = false;
      for (var i = 0; i < 400; i++) {
        final dy = 90 * (1 - i / 400) + 4;
        await send(tester, dy);
        await tester.pump(const Duration(milliseconds: 16));
        if (scroll.offset >= scroll.position.maxScrollExtent - 1) {
          reachedEnd = true;
        }
        if (reachedEnd) expect(pull.lift, 0, reason: 'event $i');
      }
      expect(reachedEnd, isTrue);
      await tester.pump(const Duration(seconds: 5));
      expect(pull.fraction, 0);
      expect(pull.armed, isFalse);
      expect(commits, 0);
      expect(advances, 0);
    });

    testWidgets('a new gesture after the momentum has stopped can pull', (
      tester,
    ) async {
      await pump(tester);
      for (var i = 0; i < 200; i++) {
        await send(tester, 90);
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(pull.lift, 0);
      await tester.pump(webPullGestureGap * 2);
      await send(tester, 100);
      expect(pull.fraction, greaterThan(0));
    });

    testWidgets('a sustained pull that starts at the end opens once', (
      tester,
    ) async {
      await pump(tester);
      await toEnd(tester);
      var armedAt = -1;
      for (var i = 0; i < 12; i++) {
        await send(tester, _step(1 / 8));
        await tester.pump(const Duration(milliseconds: 16));
        if (pull.armed && armedAt < 0) armedAt = i;
      }
      expect(armedAt, 7, reason: 'the ring is full on the eighth event');
      expect(pull.fraction, 1);
      // The ring is full. It waits for stillness before it opens.
      // 16 ms of the stillness has already passed.
      await elapse(tester, webPullOpenAfter - const Duration(milliseconds: 30));
      expect(commits, 0);
      expect(advances, 0);
      await elapse(tester, const Duration(milliseconds: 30));
      expect(commits, 1, reason: 'the pull has started the move');
      expect(advances, 0, reason: 'the next lesson is still rising');
      await elapse(tester, webPullRise - const Duration(milliseconds: 40));
      expect(advances, 0);
      await elapse(tester, const Duration(milliseconds: 80));
      expect(advances, 1);
      // Nothing more opens, however long the wheel keeps going.
      await burst(tester, 10, 100);
      await tester.pump(const Duration(seconds: 5));
      expect(commits, 1);
      expect(advances, 1);
    });

    testWidgets('four mouse notches arm the ring, and letting go opens it', (
      tester,
    ) async {
      await pump(tester);
      await toEnd(tester);
      for (var i = 0; i < 4; i++) {
        await send(tester, 100);
        await tester.pump(const Duration(milliseconds: 220));
      }
      expect(pull.armed, isTrue);
      await tester.pump(webPullOpenAfter);
      await tester.pumpAndSettle();
      expect(advances, 1);
    });

    testWidgets('it does not open while the wheel keeps moving', (
      tester,
    ) async {
      await pump(tester);
      await toEnd(tester);
      await burst(tester, 10, _step(1 / 8));
      expect(pull.armed, isTrue);
      // A slow spinner: an event every 200 ms, under the 280 ms stillness.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        await send(tester, 10);
      }
      expect(commits, 0);
      await tester.pump(webPullOpenAfter + const Duration(milliseconds: 10));
      expect(commits, 1);
    });

    testWidgets('scrolling back lowers the ring', (tester) async {
      await pump(tester);
      await toEnd(tester);
      await burst(tester, 4, _step(1 / 8));
      final half = pull.fraction;
      expect(half, closeTo(.5, .001));
      await send(tester, -_step(1 / 8));
      expect(pull.fraction, lessThan(half));
    });

    testWidgets('a pull that stops short drops back', (tester) async {
      await pump(tester);
      await toEnd(tester);
      await burst(tester, 6, _step(1 / 8));
      expect(pull.armed, isFalse);
      await tester.pump(webPullDropBackAfter);
      await tester.pumpAndSettle();
      expect(pull.fraction, 0);
      expect(commits, 0);
    });

    testWidgets('wheel input before the end only scrolls the lesson', (
      tester,
    ) async {
      await pump(tester);
      await send(tester, 100);
      await tester.pump();
      expect(scroll.offset, greaterThan(0));
      expect(pull.lift, 0);
    });

    testWidgets('sideways scrolling does nothing', (tester) async {
      await pump(tester);
      await toEnd(tester);
      await tester.sendEventToBinding(
        const PointerScrollEvent(
          position: Offset(720, 450),
          scrollDelta: Offset(200, 20),
        ),
      );
      await tester.pump();
      expect(pull.lift, 0);
    });

    testWidgets('input outside the lesson column does nothing', (
      tester,
    ) async {
      await pump(tester);
      await toEnd(tester);
      // The outline margin, left of the column.
      await send(tester, 100, at: const Offset(60, 450));
      await tester.pump();
      expect(pull.lift, 0);
    });

    testWidgets('with nowhere to go, the wheel does nothing', (tester) async {
      await pump(tester, enabled: false);
      await toEnd(tester);
      await burst(tester, 12, _step(1 / 8));
      expect(pull.lift, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(commits, 0);
      expect(advances, 0);
    });

    testWidgets('a lesson too short to scroll can still be pulled', (
      tester,
    ) async {
      await pump(tester, paragraphs: 1);
      expect(scroll.position.maxScrollExtent, 0);
      await send(tester, 100);
      expect(pull.fraction, closeTo(.25, .001));
    });

    testWidgets('a new lesson clears the pull', (tester) async {
      await pump(tester);
      await toEnd(tester);
      await burst(tester, 4, _step(1 / 8));
      expect(pull.lift, greaterThan(0));
      contentKey = 'l2';
      await pump(tester);
      expect(pull.lift, 0);
      expect(pull.armed, isFalse);
    });
  });

  group('the keyboard and the card still open the next lesson', () {
    testWidgets('the right arrow opens it', (tester) async {
      await pump(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(commits, 1);
      await tester.pump(webPullRise + const Duration(milliseconds: 20));
      expect(advances, 1);
    });

    testWidgets('the Next card opens it with a click', (tester) async {
      await pump(tester);
      await toEnd(tester);
      await tester.tap(find.text('Plate Tectonics'));
      await tester.pump();
      expect(commits, 1);
      await tester.pump(webPullRise + const Duration(milliseconds: 20));
      expect(advances, 1);
    });

    testWidgets('a key or click opens it once, however many come', (
      tester,
    ) async {
      await pump(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.tap(find.text('Plate Tectonics'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(commits, 1);
      expect(advances, 1);
    });
  });

  group('reduced motion', () {
    testWidgets('the ring still follows the wheel, but nothing glides', (
      tester,
    ) async {
      await pump(tester, still: true);
      await toEnd(tester);
      await send(tester, 100);
      await tester.pump();
      expect(pull.fraction, closeTo(.25, .001));
      // It drops back as soon as the stillness ends, with no spring.
      await tester.pump(webPullDropBackAfter);
      expect(pull.fraction, 0);
    });

    testWidgets('an armed pull opens at once when the wheel stops', (
      tester,
    ) async {
      await pump(tester, still: true);
      await toEnd(tester);
      await burst(tester, 8, _step(1 / 8));
      expect(pull.armed, isTrue);
      await tester.pump(webPullOpenAfter);
      await tester.pump();
      expect(commits, 1);
      expect(advances, 1, reason: 'no 480 ms rise');
    });

    testWidgets('the right arrow opens at once', (tester) async {
      await pump(tester, still: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(advances, 1);
    });
  });

  group('the card and the lesson while pulling', () {
    String shown(WidgetTester tester) {
      for (var i = 0; i < 3; i++) {
        final opacity = tester.widget<AnimatedOpacity>(
          find.byKey(ValueKey('web-next-label-$i')),
        );
        if (opacity.opacity == 1) {
          return ['next', 'keep going', 'let go'][i];
        }
      }
      return 'none';
    }

    testWidgets('the card label follows the pull', (tester) async {
      await pump(tester);
      await toEnd(tester);
      expect(shown(tester), 'next');
      expect(find.text('NEXT IN EARTH SCIENCE'), findsOneWidget);
      await send(tester, _step(1 / 8));
      await tester.pump();
      expect(shown(tester), 'keep going');
      await burst(tester, 8, _step(1 / 8));
      expect(shown(tester), 'let go');
      expect(find.text('LET GO TO OPEN'), findsOneWidget);
    });

    testWidgets('the lesson moves up with the pull', (tester) async {
      await pump(tester);
      await toEnd(tester);
      final outgoing = find.byKey(const ValueKey('pull-outgoing'));
      expect(
        tester.widget<Transform>(outgoing).transform.getTranslation().y,
        0,
      );
      await burst(tester, 4, _step(1 / 8));
      expect(
        tester.widget<Transform>(outgoing).transform.getTranslation().y,
        -pull.lift,
      );
      expect(pull.lift, closeTo(webPullFullAt / 2, .001));
    });

    testWidgets('the next lesson rises from below once it opens', (
      tester,
    ) async {
      await pump(tester, incoming: true);
      await toEnd(tester);
      expect(find.byKey(const ValueKey('incoming-sheet')), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      final sheet = find.byKey(const ValueKey('incoming-sheet'));
      expect(sheet, findsOneWidget);
      final start = tester.getTopLeft(sheet).dy;
      expect(start, closeTo(900, 1));
      await tester.pump(webPullRise ~/ 2);
      final middle = tester.getTopLeft(sheet).dy;
      expect(middle, lessThan(start));
      expect(middle, greaterThan(0));
      await tester.pump(webPullRise);
      expect(tester.getTopLeft(sheet).dy, closeTo(0, 1));
      expect(advances, 1);
    });
  });

  testWidgets('the wide lesson page opens the next lesson from a pull', (
    tester,
  ) async {
    final content = openTestContentDatabase();
    await seedContentExam(
      content,
      examId: 'e',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
    );
    await seedContentSubject(
      content,
      subjectId: 's1',
      examId: 'e',
      name: 'Science',
    );
    await seedContentTopic(
      content,
      topicId: 't1',
      subjectId: 's1',
      name: 'Earth Science',
    );
    const first = StudyLesson(
      id: 'l1',
      title: 'Layers',
      estimatedMinutes: 11,
      isRead: true,
      isBookmarked: true,
    );
    const second = StudyLesson(
      id: 'l2',
      title: 'Plate Tectonics',
      estimatedMinutes: 12,
      isRead: false,
      isBookmarked: false,
    );
    for (final lesson in [first, second]) {
      await seedContentLesson(
        content,
        lessonId: lesson.id,
        topicId: 't1',
        title: lesson.title,
        bodyJson: '[]',
      );
    }
    await AppPreferencesRepository(db).setSelectedExamId('e');
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          studyMapProvider.overrideWith(
            (_) async => const StudyMap(
              examShortName: 'CSE',
              subjects: [
                StudySubject(
                  id: 's1',
                  name: 'Science',
                  topics: [
                    StudyTopic(
                      id: 't1',
                      name: 'Earth Science',
                      lessons: [first, second],
                      readCount: 1,
                      hasBookmark: true,
                    ),
                  ],
                ),
              ],
              readCount: 1,
              totalCount: 2,
              minutesLeftToRead: 12,
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: LessonPage(
              lessonId: 'l1',
              origin: ReaderOrigin.home,
              dayContext: LessonDayContext(
                date: DateTime(2026, 10, 30),
                lessonIds: const ['l1', 'l2'],
                index: 0,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 of 2'), findsOneWidget);
    // The lesson is empty, so it is already at its end. One notch does
    // nothing.
    await tester.pump(webPullGestureGap * 2);
    await send(tester, 100);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('1 of 2'), findsOneWidget);
    // Four notches fill the ring, and a rest opens the next lesson.
    for (var i = 0; i < 4; i++) {
      await send(tester, 100);
      await tester.pump(const Duration(milliseconds: 220));
    }
    await tester.pump(webPullOpenAfter);
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
