import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_ending_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_study_layout.dart';

import '../../../helpers/in_memory_database.dart';
import 'fake_open_topic.dart';

// The wide Study, search and reader pages move wherever the phone does, on
// the phone's own numbers. Each surface: part-way differs from the end, it
// settles, and reduced motion is instant with nothing left running.

const _l1 = StudyLesson(
  id: 'l1',
  title: 'Layers',
  estimatedMinutes: 11,
  isRead: true,
  isBookmarked: true,
);
const _l2 = StudyLesson(
  id: 'l2',
  title: 'Plate Tectonics',
  estimatedMinutes: 12,
  isRead: false,
  isBookmarked: false,
);
const _l3 = StudyLesson(
  id: 'l3',
  title: 'Fractions',
  estimatedMinutes: 9,
  isRead: false,
  isBookmarked: false,
);
const _earth = StudyTopic(
  id: 't1',
  name: 'Earth Science',
  lessons: [_l1, _l2],
  readCount: 1,
  hasBookmark: true,
);
const _numbers = StudyTopic(
  id: 't2',
  name: 'Number Sense',
  lessons: [_l3],
  readCount: 0,
  hasBookmark: false,
);
const _map = StudyMap(
  examShortName: 'CSE',
  subjects: [
    StudySubject(id: 's1', name: 'Science', topics: [_earth]),
    StudySubject(id: 's2', name: 'Mathematics', topics: [_numbers]),
  ],
  readCount: 1,
  totalCount: 3,
  minutesLeftToRead: 21,
);

ReaderContext _reader({required bool bookmarked}) => ReaderContext(
      lesson: const Lesson(
        id: 'l1',
        topicId: 't1',
        title: 'Layers',
        summary: '',
        estimatedMinutes: 11,
        bodyJson: [
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {'text': 'Earth has several layers.'},
            ],
          },
        ],
      ),
      topicId: 't1',
      topicName: 'Earth Science',
      next: _l2,
      positionInTopic: 1,
      lessonsInTopic: 2,
      topicLessons: const [_l1, _l2],
      isRead: true,
      isBookmarked: bookmarked,
      examId: 'e',
    );

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pumpApp(
    WidgetTester tester,
    Widget child, {
    bool reduced = false,
    List<Override> overrides = const [],
  }) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  /// The opacity of the nearest fade above [of]. A part that has finished
  /// entering has no fade left above it, and counts as 1.
  double fade(WidgetTester tester, Finder of) {
    final fades = find.ancestor(of: of, matching: find.byType(Opacity));
    return fades.evaluate().isEmpty
        ? 1
        : tester.widget<Opacity>(fades.first).opacity;
  }

  /// Drift closes its streams on a timer once the tree is gone.
  Future<void> closeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  }

  bool between(double value) => value > 0 && value < 1;

  Future<void> after(WidgetTester tester, int milliseconds) =>
      tester.pump(Duration(milliseconds: milliseconds));

  group('L1 the Study map comes in', () {
    Widget study({String? open, Set<String> today = const {}}) => WebStudyMap(
          map: _map,
          openTopicId: open,
          today: today,
          lastLessonId: 'l1',
          lastTitle: 'Layers',
          onTopic: (_) {},
          onLesson: (_, {required resume}) {},
          onBookmarks: () {},
        );

    testWidgets('each part follows the phone delays and settles',
        (tester) async {
      await pumpApp(tester, study());
      await tester.pump();
      // The Last opened card starts 180 ms in and the first subject 520 ms.
      expect(fade(tester, find.text('LAST OPENED')), 0);
      expect(fade(tester, find.text('SCIENCE')), 0);
      await after(tester, 300);
      expect(between(fade(tester, find.text('LAST OPENED'))), isTrue);
      expect(fade(tester, find.text('SCIENCE')), 0);
      await after(tester, 400);
      expect(between(fade(tester, find.text('SCIENCE'))), isTrue);
      // The second subject is 120 ms behind the first.
      expect(
        fade(tester, find.text('MATHEMATICS')),
        lessThan(fade(tester, find.text('SCIENCE'))),
      );
      await tester.pumpAndSettle();
      for (final label in ['LAST OPENED', 'BOOKMARKS', 'SCIENCE']) {
        expect(fade(tester, find.text(label)), 1, reason: label);
      }
    });

    testWidgets('opening a topic or a rebuild does not replay it',
        (tester) async {
      await pumpApp(tester, study());
      await tester.pumpAndSettle();
      await pumpApp(tester, study(open: 't1'));
      await tester.pump();
      expect(fade(tester, find.text('SCIENCE').first), 1);
      expect(fade(tester, find.text('MATHEMATICS')), 1);
      expect(fade(tester, find.text('LAST OPENED')), 1);
      await pumpApp(tester, study(open: 't1', today: {'l2'}));
      await tester.pump();
      expect(fade(tester, find.text('MATHEMATICS')), 1);
    });

    testWidgets('a topic opened part-way keeps its place in the entrance',
        (tester) async {
      await pumpApp(tester, study());
      await tester.pump();
      await after(tester, 700);
      final before = fade(tester, find.text('MATHEMATICS'));
      await pumpApp(tester, study(open: 't1'));
      await tester.pump();
      expect(fade(tester, find.text('MATHEMATICS')), before);
    });

    testWidgets('reduced motion shows everything at once', (tester) async {
      await pumpApp(tester, study(), reduced: true);
      await tester.pump();
      expect(fade(tester, find.text('SCIENCE')), 1);
      expect(fade(tester, find.text('LAST OPENED')), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('L2 the topic card', () {
    Widget study(String? open, {Set<String> today = const {}}) => WebStudyMap(
          map: _map,
          openTopicId: open,
          today: today,
          onTopic: (_) {},
          onLesson: (_, {required resume}) {},
          onBookmarks: () {},
        );
    const opacity = ValueKey('web-study-topic-opacity');

    testWidgets('rises and fades on a new topic only', (tester) async {
      await pumpApp(tester, study('t1'));
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.byKey(opacity)).opacity, 1);
      final home = tester.getTopLeft(find.text('Plate Tectonics')).dy;
      // The same topic again, with other data, does nothing.
      await pumpApp(tester, study('t1', today: {'l2'}));
      await tester.pump();
      expect(tester.widget<Opacity>(find.byKey(opacity)).opacity, 1);
      // Another topic starts from nothing, 8 px low, and settles in 240 ms.
      await pumpApp(tester, study('t2'));
      await tester.pump();
      expect(tester.widget<Opacity>(find.byKey(opacity)).opacity, 0);
      final low = tester.getTopLeft(find.text('Fractions')).dy;
      await after(tester, 120);
      expect(
        between(tester.widget<Opacity>(find.byKey(opacity)).opacity),
        isTrue,
      );
      final middle = tester.getTopLeft(find.text('Fractions')).dy;
      expect(middle, lessThan(low));
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.byKey(opacity)).opacity, 1);
      expect(tester.getTopLeft(find.text('Fractions')).dy, lessThan(middle));
      expect(low - tester.getTopLeft(find.text('Fractions')).dy, 8);
      expect(home, isNonZero);
    });

    testWidgets('reduced motion shows the card at once', (tester) async {
      await pumpApp(tester, study('t1'), reduced: true);
      await tester.pump();
      expect(tester.widget<Opacity>(find.byKey(opacity)).opacity, 1);
      expect(tester.hasRunningAnimations, isFalse);
      // Another topic is there at once. Only the row tint still fades.
      await pumpApp(tester, study('t2'), reduced: true);
      await tester.pump();
      expect(tester.widget<Opacity>(find.byKey(opacity)).opacity, 1);
    });
  });

  group('L3 and L4 the search dialog', () {
    final overrides = [
      studyMapProvider.overrideWith((_) async => _map),
      recentlyOpenedLessonsProvider.overrideWith((_) async => [_l1]),
      searchResultsProvider.overrideWith(
        (ref) async => const [
          LessonSearchHit(
            lessonId: 'l2',
            title: 'Plate Tectonics',
            topicName: 'Earth Science',
            estimatedMinutes: 12,
          ),
          LessonSearchHit(
            lessonId: 'l3',
            title: 'Core',
            topicName: 'Earth Science',
            estimatedMinutes: 10,
          ),
        ],
      ),
    ];

    Future<void> openSearch(WidgetTester tester, {bool reduced = false}) async {
      await pumpApp(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showWebLessonSearch(context),
            child: const Text('Search'),
          ),
        ),
        reduced: reduced,
        overrides: overrides,
      );
      await tester.tap(find.text('Search'));
    }

    testWidgets('opens with the popover motion and closes the old ways',
        (tester) async {
      await openSearch(tester);
      await tester.pump();
      final field = find.byType(TextField);
      expect(fade(tester, field), 0);
      final low = tester.getTopLeft(field).dy;
      await after(tester, 100);
      expect(between(fade(tester, field)), isTrue);
      expect(tester.getTopLeft(field).dy, lessThan(low));
      await tester.pumpAndSettle();
      expect(fade(tester, field), 1);
      expect(tester.getTopLeft(field).dy, closeTo(low - 8, .01));
      // The scrim keeps its colour, and Esc closes the dialog.
      expect(
        tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).color,
        const Color(0x381D1D1F),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await after(tester, 100);
      expect(find.byType(TextField), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      // So does a tap on the scrim.
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('typing fades the results in, the recent list a beat later',
        (tester) async {
      await openSearch(tester);
      await tester.pumpAndSettle();
      expect(find.text('Recently Opened'), findsOneWidget);
      expect(fade(tester, find.text('Recently Opened')), 1);
      await tester.enterText(find.byType(TextField), 'plate');
      for (var i = 0; i < 5 && find.text('2 Lessons').evaluate().isEmpty; i++) {
        await tester.pump();
      }
      final results = find.text('2 Lessons');
      expect(fade(tester, results), 0);
      await after(tester, 100);
      expect(between(fade(tester, results)), isTrue);
      await tester.pumpAndSettle();
      expect(fade(tester, results), 1);
    });

    testWidgets('the recent list waits 100 ms', (tester) async {
      await openSearch(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      final recent = find.text('Recently Opened');
      expect(recent, findsOneWidget);
      await after(tester, 60);
      expect(fade(tester, recent), 0);
      await after(tester, 300);
      expect(between(fade(tester, recent)), isTrue);
      await tester.pumpAndSettle();
      expect(fade(tester, recent), 1);
    });

    // Rule R2 (Dialog README): reduced motion fades in place over 150 ms.
    testWidgets('reduced motion fades the dialog and results in place',
        (tester) async {
      await openSearch(tester, reduced: true);
      await tester.pump();
      await tester.pump();
      expect(find.text('Recently Opened'), findsOneWidget);
      await after(tester, 75);
      expect(between(fade(tester, find.byType(TextField))), isTrue);
      final resting = tester.getTopLeft(find.byType(TextField)).dy;
      await after(tester, 75);
      await tester.pump();
      expect(fade(tester, find.byType(TextField)), 1);
      expect(fade(tester, find.text('Recently Opened')), 1);
      expect(tester.getTopLeft(find.byType(TextField)).dy, resting);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await after(tester, 200);
      await tester.pump();
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('L5 the Bookmarks drawer', () {
    Future<List<Override>> overrides() async {
      final db = inMemoryDatabase();
      final content = openTestContentDatabase();
      addTearDown(db.close);
      addTearDown(content.close);
      await seedContentExam(
        content,
        examId: 'e',
        code: 'CSE',
        name: 'CSE',
        shortName: 'CSE',
      );
      return [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        studyMapProvider.overrideWith((_) async => _map),
        openTopicProvider.overrideWith(FakeOpenTopic.new),
        lastOpenedLessonProvider.overrideWith((_) async => null),
        studyTodayLessonIdsProvider.overrideWith((_) async => <String>{}),
        activeExamFocusProvider.overrideWith(
          (_) async => const ActiveExamFocus.needsSelection(),
        ),
      ];
    }

    for (final reduced in [false, true]) {
      testWidgets('slides in from the right and leaves, reduced=$reduced',
          (tester) async {
        await pumpApp(
          tester,
          const WebStudyLayout(),
          reduced: reduced,
          overrides: await overrides(),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('See all'));
        await tester.pump();
        final sheet = find.byType(BookmarksSheet);
        if (reduced) {
          // Rule R2 (Drawer README): a 150 ms fade in place, no slide.
          expect(tester.getTopLeft(sheet).dx, 1000);
          await after(tester, 75);
          expect(tester.getTopLeft(sheet).dx, 1000);
          expect(between(fade(tester, sheet)), isTrue);
          await after(tester, 75);
          await tester.pump();
          expect(fade(tester, sheet), 1);
          await tester.pump(const Duration(milliseconds: 20));
          expect(tester.hasRunningAnimations, isFalse);
        } else {
          expect(tester.getTopLeft(sheet).dx, greaterThan(1440));
          await after(tester, 100);
          expect(tester.getTopLeft(sheet).dx, greaterThan(1000));
          expect(tester.getTopLeft(sheet).dx, lessThan(1440 * 2));
          await tester.pumpAndSettle();
        }
        expect(tester.getTopLeft(sheet).dx, 1000);
        expect(
          tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).color,
          PantasColors.light.scrim,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await after(tester, 100);
        if (reduced) {
          // It fades out in place over 150 ms, then is gone.
          expect(sheet, findsOneWidget);
          expect(tester.getTopLeft(sheet).dx, 1000);
          await after(tester, 100);
          await tester.pump();
          expect(sheet, findsNothing);
        } else {
          // 400 ms out: still on its way at 100 ms.
          expect(sheet, findsOneWidget);
          expect(tester.getTopLeft(sheet).dx, greaterThan(1000));
          await tester.pumpAndSettle();
        }
        expect(sheet, findsNothing);
        await closeTree(tester);
      });
    }
  });

  group('L6 and L7 the wide reader', () {
    late AppDatabase db;
    late ScrollController scroll;
    late ValueNotifier<double> offset;
    late ValueNotifier<double> progress;
    setUp(() {
      db = inMemoryDatabase();
      scroll = ScrollController();
      offset = ValueNotifier(0);
      progress = ValueNotifier(0);
      addTearDown(db.close);
      addTearDown(scroll.dispose);
      addTearDown(offset.dispose);
      addTearDown(progress.dispose);
    });

    Future<void> pumpReader(
      WidgetTester tester, {
      required bool bookmarked,
      bool reduced = false,
    }) =>
        pumpApp(
          tester,
          WebReaderLayout(
            reader: _reader(bookmarked: bookmarked),
            controller: scroll,
            scrollOffset: offset,
            progress: progress,
            onBack: () {},
            onBookmark: () {},
            onLesson: (_) {},
            footer: const SizedBox(),
          ),
          reduced: reduced,
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );

    const title = 'EARTH SCIENCE';

    testWidgets('the contents list drops in and lifts out on slideC',
        (tester) async {
      await pumpReader(tester, bookmarked: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 of 2'));
      await tester.pump();
      final heading = find.text(title);
      expect(fade(tester, heading), 0);
      final high = tester.getTopLeft(heading).dy;
      await after(tester, 100);
      expect(between(fade(tester, heading)), isTrue);
      expect(tester.getTopLeft(heading).dy, greaterThan(high));
      await tester.pumpAndSettle();
      expect(fade(tester, heading), 1);
      expect(tester.getTopLeft(heading).dy, closeTo(high + 24, .01));
      // It has no scrim, and Esc closes it over 400 ms.
      expect(
        tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).color?.a ??
            0,
        0,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await after(tester, 100);
      expect(heading, findsOneWidget);
      expect(fade(tester, heading), lessThan(1));
      await tester.pumpAndSettle();
      expect(heading, findsNothing);
      await closeTree(tester);
    });

    // Rule R2 (Popover README): reduced motion fades in place over 150 ms.
    testWidgets('reduced motion fades the list in and out in place',
        (tester) async {
      await pumpReader(tester, bookmarked: false, reduced: true);
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 of 2'));
      await tester.pump();
      await after(tester, 75);
      expect(between(fade(tester, find.text(title))), isTrue);
      final resting = tester.getTopLeft(find.text(title)).dy;
      await after(tester, 75);
      await tester.pump();
      expect(fade(tester, find.text(title)), 1);
      expect(tester.getTopLeft(find.text(title)).dy, resting);
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await after(tester, 200);
      await tester.pump();
      expect(find.text(title), findsNothing);
    });

    final mark = find.byKey(const ValueKey('web-reader-bookmark-pop'));
    double markScale(WidgetTester tester) =>
        tester.widget<Transform>(mark).transform.storage[0];

    testWidgets('the bookmark pops for 520 ms when it is set', (tester) async {
      await pumpReader(tester, bookmarked: false);
      await tester.pumpAndSettle();
      expect(markScale(tester), 1);
      await pumpReader(tester, bookmarked: true);
      await tester.pump();
      expect(markScale(tester), closeTo(.6, .001));
      await after(tester, 130);
      expect(markScale(tester), greaterThan(1.05));
      await after(tester, 300);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(markScale(tester), 1);
      // Taking it away resets the mark and starts nothing.
      await pumpReader(tester, bookmarked: false);
      await tester.pump();
      expect(markScale(tester), 1);
    });

    testWidgets('a lesson that opens bookmarked does not pop', (tester) async {
      await pumpReader(tester, bookmarked: true);
      await tester.pumpAndSettle();
      expect(markScale(tester), 1);
    });

    testWidgets('reduced motion sets the bookmark at once', (tester) async {
      await pumpReader(tester, bookmarked: false, reduced: true);
      await tester.pumpAndSettle();
      await pumpReader(tester, bookmarked: true, reduced: true);
      await tester.pump();
      expect(markScale(tester), 1);
    });
  });

  group('L8 the Read line', () {
    const gap = Center(
      child: SizedBox(
        width: 680,
        child: ReaderGap(isRead: true, examId: 'e', lessonId: 'l1'),
      ),
    );
    final check = find.byKey(const ValueKey('reader-read-check'));
    double scale(WidgetTester tester) => tester
        .widget<Transform>(
          find.ancestor(of: check, matching: find.byType(Transform)).first,
        )
        .transform
        .storage[0];

    testWidgets('pops in over 350 ms', (tester) async {
      await pumpApp(tester, gap);
      await tester.pump();
      expect(fade(tester, check), 0);
      expect(scale(tester), closeTo(.6, .001));
      await after(tester, 40);
      expect(between(fade(tester, check)), isTrue);
      expect(scale(tester), greaterThan(.6));
      await after(tester, 200);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(fade(tester, check), 1);
      expect(scale(tester), 1);
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('reduced motion shows it at once', (tester) async {
      await pumpApp(tester, gap, reduced: true);
      await tester.pump();
      expect(fade(tester, check), 1);
      expect(scale(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('L9 the lesson ending', () {
    const stopped = TopicStoppedShort(
      studentName: null,
      topicName: 'Earth Science',
      examAndSubject: 'CSE · Science',
      footing: '1 of 2 lessons read',
      dateLine: 'October 30, 2026',
      unread: [_l2],
    );
    Widget ending(LessonEnding value) =>
        WebEndingLayout(ending: value, onLesson: (_) {}, onHome: () {});

    testWidgets('the plate comes first and the list 500 ms in', (tester) async {
      await pumpApp(tester, ending(stopped));
      await tester.pump();
      final plate = find.text('1 of 2 lessons read');
      final list = find.text('STILL UNREAD');
      expect(fade(tester, plate), 0);
      expect(fade(tester, list), 0);
      final low = tester.getTopLeft(list).dy;
      await after(tester, 400);
      expect(between(fade(tester, plate)), isTrue);
      expect(fade(tester, list), 0);
      await after(tester, 300);
      expect(fade(tester, plate), 1);
      expect(between(fade(tester, list)), isTrue);
      expect(tester.getTopLeft(list).dy, lessThan(low));
      await tester.pumpAndSettle();
      expect(fade(tester, list), 1);
      expect(tester.getTopLeft(list).dy, closeTo(low - 8, .01));
    });

    testWidgets('a finished day reveals its line 200 ms in', (tester) async {
      await pumpApp(tester, ending(const DayFinished()));
      await tester.pump();
      final line = find.text('That’s enough for today.');
      await after(tester, 100);
      expect(fade(tester, line), 0);
      await after(tester, 300);
      expect(between(fade(tester, line)), isTrue);
      await tester.pumpAndSettle();
      expect(fade(tester, line), 1);
    });

    testWidgets('reduced motion shows the ending at once', (tester) async {
      await pumpApp(tester, ending(stopped), reduced: true);
      await tester.pump();
      expect(find.text('STILL UNREAD'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('STILL UNREAD'),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
