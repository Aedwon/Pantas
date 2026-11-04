import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_study_layout.dart';

import '../../../helpers/in_memory_database.dart';
import 'fake_open_topic.dart';

// The wide Study map moves where the phone does, on the phone's numbers:
// the topic rings fill and the done mark pops, the lesson bookmark pops, the
// subjects slide when a topic opens, and the page recedes behind Bookmarks.
// Each surface: part-way differs from the end, it settles, and reduced motion
// is instant.

StudyLesson _lesson(String id, {bool read = false, bool bookmarked = false}) =>
    StudyLesson(
      id: id,
      title: 'Lesson $id',
      estimatedMinutes: 10,
      isRead: read,
      isBookmarked: bookmarked,
    );

StudyMap _map({
  bool mathDone = false,
  bool l2Bookmarked = false,
}) {
  final earth = StudyTopic(
    id: 't1',
    name: 'Earth Science',
    lessons: [
      _lesson('l1', read: true),
      _lesson('l2', bookmarked: l2Bookmarked),
    ],
    readCount: 1,
    hasBookmark: l2Bookmarked,
  );
  final numbers = StudyTopic(
    id: 't2',
    name: 'Number Sense',
    lessons: [_lesson('l3', read: mathDone)],
    readCount: mathDone ? 1 : 0,
    hasBookmark: false,
  );
  return StudyMap(
    examShortName: 'CSE',
    subjects: [
      StudySubject(id: 's1', name: 'Science', topics: [earth]),
      StudySubject(id: 's2', name: 'Mathematics', topics: [numbers]),
    ],
    readCount: 1,
    totalCount: 3,
    minutesLeftToRead: 20,
  );
}

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

  Widget study({
    required StudyMap map,
    String? open,
  }) =>
      WebStudyMap(
        map: map,
        openTopicId: open,
        onTopic: (_) {},
        onBookmark: (_) {},
        onLesson: (_, {required resume}) {},
        onBookmarks: () {},
      );

  Future<void> after(WidgetTester tester, int milliseconds) =>
      tester.pump(Duration(milliseconds: milliseconds));

  /// How far round the topic's ring is drawn, in radians. Zero if no arc yet.
  double sweep(WidgetTester tester, String topic) {
    var angle = 0.0;
    final canvas = tester.renderObject(
      find.descendant(
        of: find.byKey(ValueKey('study-ring-$topic')),
        matching: find.byKey(const ValueKey('progress-ring-paint')),
      ),
    ) as RenderBox;
    expect(
      canvas,
      paints
        ..something((method, args) {
          if (method != #drawArc) return false;
          angle = args[2] as double;
          return true;
        }),
    );
    return angle;
  }

  double markScale(WidgetTester tester) => tester
      .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')))
      .transform
      .entry(0, 0);

  group('the topic ring and done mark', () {
    testWidgets('the ring fills on the phone delay, then stays put',
        (tester) async {
      await pumpApp(tester, study(map: _map()));
      await tester.pump();
      expect(find.byKey(const ValueKey('study-ring-t1')), findsOneWidget);
      // Subject one arrives at 520 ms and its ring fills 300 ms after that.
      await after(tester, 700);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await after(tester, 400);
      final mid = sweep(tester, 't1');
      expect(mid, greaterThan(0));
      expect(mid, lessThan(math.pi));
      // Opening a topic part-way through does not restart it.
      await pumpApp(tester, study(map: _map(), open: 't2'));
      await after(tester, 1);
      expect(sweep(tester, 't1'), greaterThanOrEqualTo(mid));
      expect(sweep(tester, 't1'), lessThan(math.pi));
      await tester.pumpAndSettle();
      expect(sweep(tester, 't1'), closeTo(math.pi, .001));
      // A rebuild of a settled map, or a topic opening, never replays it.
      await pumpApp(tester, study(map: _map()));
      await after(tester, 1);
      expect(sweep(tester, 't1'), closeTo(math.pi, .001));
    });

    testWidgets('reduced motion draws the ring at once', (tester) async {
      await pumpApp(tester, study(map: _map()), reduced: true);
      await tester.pump();
      expect(sweep(tester, 't1'), closeTo(math.pi, .001));
    });

    testWidgets('a topic that becomes done pops its mark, once',
        (tester) async {
      await pumpApp(tester, study(map: _map()));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('check-mark-scale')), findsNothing);
      await pumpApp(tester, study(map: _map(mathDone: true)));
      await tester.pump();
      expect(markScale(tester), lessThan(.5));
      await after(tester, 150);
      final mid = markScale(tester);
      expect(mid, isNot(1));
      await tester.pumpAndSettle();
      expect(markScale(tester), closeTo(1, .001));
      // A later rebuild leaves it standing.
      await pumpApp(tester, study(map: _map(mathDone: true), open: 't1'));
      await tester.pump();
      expect(markScale(tester), closeTo(1, .001));
    });

    testWidgets('a topic already done shows its mark without a pop',
        (tester) async {
      await pumpApp(tester, study(map: _map(mathDone: true)));
      await tester.pump();
      expect(markScale(tester), closeTo(1, .001));
    });

    testWidgets('reduced motion shows the new mark at once', (tester) async {
      await pumpApp(tester, study(map: _map()), reduced: true);
      await tester.pumpAndSettle();
      await pumpApp(
        tester,
        study(map: _map(mathDone: true)),
        reduced: true,
      );
      await tester.pump();
      expect(markScale(tester), closeTo(1, .001));
    });
  });

  group('the lesson bookmark', () {
    double pop(WidgetTester tester) => tester
        .widget<Transform>(
          find.descendant(
            of: find.byKey(const ValueKey('l2')),
            matching: find.byKey(const ValueKey('web-reader-bookmark-pop')),
          ),
        )
        .transform
        .entry(0, 0);

    testWidgets('pops when it is set, over 520 ms', (tester) async {
      await pumpApp(tester, study(map: _map(), open: 't1'));
      await tester.pumpAndSettle();
      expect(pop(tester), 1);
      await pumpApp(
        tester,
        study(map: _map(l2Bookmarked: true), open: 't1'),
      );
      await tester.pump();
      await after(tester, 130);
      final mid = pop(tester);
      expect(mid, isNot(1));
      await tester.pumpAndSettle();
      expect(pop(tester), 1);
    });

    testWidgets('reduced motion sets it at once', (tester) async {
      await pumpApp(tester, study(map: _map(), open: 't1'), reduced: true);
      await tester.pumpAndSettle();
      await pumpApp(
        tester,
        study(map: _map(l2Bookmarked: true), open: 't1'),
        reduced: true,
      );
      await tester.pump();
      expect(pop(tester), 1);
    });
  });

  group('opening and closing a topic', () {
    Offset mathematics(WidgetTester tester) =>
        tester.getTopLeft(find.text('MATHEMATICS'));

    testWidgets('the subjects slide to their new places, 240 ms',
        (tester) async {
      await pumpApp(tester, study(map: _map()));
      await tester.pumpAndSettle();
      final closed = mathematics(tester);
      // Closed, Mathematics is the second column.
      expect(closed.dx, greaterThan(400));
      await pumpApp(tester, study(map: _map(), open: 't1'));
      await tester.pump();
      // The first frame is where it stood.
      expect(mathematics(tester).dx, closeTo(closed.dx, .5));
      await after(tester, 120);
      final mid = mathematics(tester);
      expect(mid.dx, lessThan(closed.dx));
      await tester.pumpAndSettle();
      final open = mathematics(tester);
      expect(open.dx, lessThan(mid.dx));
      expect(open.dx, lessThan(60));
      expect(open.dy, greaterThan(closed.dy));
      // And back again on close.
      await pumpApp(tester, study(map: _map()));
      await tester.pump();
      expect(mathematics(tester).dx, closeTo(open.dx, .5));
      await after(tester, 120);
      expect(mathematics(tester).dx, greaterThan(open.dx));
      await tester.pumpAndSettle();
      expect(mathematics(tester), closed);
    });

    testWidgets('reduced motion moves them at once', (tester) async {
      await pumpApp(tester, study(map: _map()), reduced: true);
      await tester.pumpAndSettle();
      await pumpApp(
        tester,
        study(map: _map(), open: 't1'),
        reduced: true,
      );
      await tester.pump();
      expect(mathematics(tester).dx, lessThan(60));
    });

    testWidgets('the selected chevron fades in over 160 ms', (tester) async {
      await pumpApp(tester, study(map: _map()));
      await tester.pumpAndSettle();
      final chevron = find.byKey(const ValueKey('web-study-selected-chevron'));
      expect(chevron, findsNothing);
      await pumpApp(tester, study(map: _map(), open: 't1'));
      await tester.pump();
      await after(tester, 80);
      final fade = find.ancestor(
        of: chevron,
        matching: find.byType(FadeTransition),
      );
      final mid = tester.widget<FadeTransition>(fade.first).opacity.value;
      expect(mid, greaterThan(0));
      expect(mid, lessThan(1));
      await tester.pumpAndSettle();
      expect(tester.widget<FadeTransition>(fade.first).opacity.value, 1);
    });

    testWidgets('reduced motion shows the chevron at once', (tester) async {
      await pumpApp(tester, study(map: _map()), reduced: true);
      await tester.pumpAndSettle();
      await pumpApp(tester, study(map: _map(), open: 't1'), reduced: true);
      await tester.pump();
      expect(
        find.byKey(const ValueKey('web-study-selected-chevron')),
        findsOneWidget,
      );
    });
  });

  group('the page behind the Bookmarks drawer', () {
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
        studyMapProvider.overrideWith((_) async => _map(l2Bookmarked: true)),
        openTopicProvider.overrideWith(FakeOpenTopic.new),
        lastOpenedLessonProvider.overrideWith((_) async => null),
        studyTodayLessonIdsProvider.overrideWith((_) async => <String>{}),
        activeExamFocusProvider.overrideWith(
          (_) async => const ActiveExamFocus.needsSelection(),
        ),
      ];
    }

    double shift(WidgetTester tester) => tester
        .widget<Transform>(find.byKey(const ValueKey('web-study-page-shift')))
        .transform
        .getTranslation()
        .y;
    double scale(WidgetTester tester) => tester
        .widget<Transform>(find.byKey(const ValueKey('web-study-page-scale')))
        .transform
        .entry(0, 0);

    testWidgets('shifts 10 px and scales to .985 while it is open',
        (tester) async {
      await pumpApp(
        tester,
        const WebStudyLayout(),
        overrides: await overrides(),
      );
      await tester.pumpAndSettle();
      expect(shift(tester), 0);
      expect(scale(tester), 1);
      await tester.tap(find.text('See all'));
      await tester.pump();
      await after(tester, 1);
      await after(tester, 150);
      final mid = shift(tester);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(10));
      expect(scale(tester), lessThan(1));
      expect(scale(tester), greaterThan(.985));
      await tester.pumpAndSettle();
      expect(shift(tester), closeTo(10, .001));
      expect(scale(tester), closeTo(.985, .0001));
      // It comes back as the drawer leaves, over 400 ms.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await after(tester, 100);
      expect(shift(tester), lessThan(10));
      expect(shift(tester), greaterThan(0));
      await tester.pumpAndSettle();
      expect(shift(tester), 0);
      expect(scale(tester), 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion moves the page at once', (tester) async {
      await pumpApp(
        tester,
        const WebStudyLayout(),
        reduced: true,
        overrides: await overrides(),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('See all'));
      await tester.pump();
      await tester.pump();
      expect(shift(tester), closeTo(10, .001));
      expect(scale(tester), closeTo(.985, .0001));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();
      expect(shift(tester), 0);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
