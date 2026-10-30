import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/lesson_contents_sheet.dart';

import '../../../helpers/accessibility.dart';

const first = StudyLesson(
  id: 'l1',
  title: 'Lesson 1',
  estimatedMinutes: 10,
  isRead: false,
  isBookmarked: false,
);
const readLesson = StudyLesson(
  id: 'l2',
  title: 'Lesson 2',
  estimatedMinutes: 10,
  isRead: true,
  isBookmarked: false,
);
const unread = StudyLesson(
  id: 'l3',
  title: 'Lesson 3',
  estimatedMinutes: 10,
  isRead: false,
  isBookmarked: false,
);
const other = StudyLesson(
  id: 'l4',
  title: 'Lesson 4',
  estimatedMinutes: 12,
  isRead: false,
  isBookmarked: false,
);
const reader = ReaderContext(
  lesson: Lesson(
    id: 'l1',
    topicId: 't1',
    title: 'Lesson 1',
    summary: '',
    bodyJson: [],
    estimatedMinutes: 10,
  ),
  topicId: 't1',
  topicName: 'Chemistry',
  next: readLesson,
  positionInTopic: 1,
  lessonsInTopic: 3,
  topicLessons: [first, readLesson, unread],
  isRead: false,
  isBookmarked: false,
  examId: 'e1',
);
const map = StudyMap(
  examShortName: 'CSE',
  readCount: 1,
  totalCount: 4,
  minutesLeftToRead: 32,
  subjects: [
    StudySubject(
      id: 's1',
      name: 'Science',
      topics: [
        StudyTopic(
          id: 't1',
          name: 'Chemistry',
          lessons: [first, readLesson, unread],
          readCount: 1,
          hasBookmark: false,
        ),
        StudyTopic(
          id: 't2',
          name: 'Biology',
          lessons: [other],
          readCount: 0,
          hasBookmark: false,
        ),
      ],
    ),
  ],
);

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });

  LessonDayContext day({DateTime? date}) => LessonDayContext(
        date: date ?? DateTime.now(),
        lessonIds: const ['l4', 'l1', 'l2'],
        index: 1,
      );

  Future<void> pumpContents(
    WidgetTester tester, {
    bool dark = false,
    double scale = 1,
    LessonDayContext? dayContext,
    List<Override> overrides = const [],
    void Function(String)? onSelect,
    ReaderContext readerContext = reader,
  }) async {
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [
          if (overrides.isEmpty)
            studyMapProvider.overrideWith((_) async => map),
          ...overrides,
        ],
        child: PantasSheet(
          page: const SizedBox.expand(),
          label: 'Contents',
          readerContents: true,
          open: true,
          onDismiss: () {},
          child: LessonContentsSheet(
            key: const ValueKey('lesson-contents'),
            reader: readerContext,
            dayContext: dayContext,
            onSelectLesson: onSelect ?? (_) {},
          ),
        ),
      ),
      viewportSize: Size(scale == 1 ? 390 : 320, scale == 1 ? 844 : 640),
      textScale: scale,
      brightness: dark ? Brightness.dark : Brightness.light,
      disableAnimations: true,
    );
    await tester.pumpAndSettle();
  }

  void expectRowSeparators(
    WidgetTester tester,
    List<String> ids, {
    required Color color,
    required double gap,
  }) {
    for (var index = 0; index < ids.length; index++) {
      final row = find.byKey(ValueKey('contents-lesson-${ids[index]}'));
      final borders = tester.widgetList<DecoratedBox>(
        find.ancestor(
          of: row,
          matching: find.byWidgetPredicate((widget) {
            if (widget is! DecoratedBox ||
                widget.decoration is! BoxDecoration) {
              return false;
            }
            final border = (widget.decoration as BoxDecoration).border;
            return border is Border && border.top.width > 0;
          }),
        ),
      );
      if (index == 0) {
        expect(borders, isEmpty);
      } else {
        expect(borders, hasLength(1));
        final border =
            (borders.single.decoration as BoxDecoration).border! as Border;
        expect(border.top.width, .5);
        expect(border.top.color, color);
        final previous = find.byKey(
          ValueKey('contents-lesson-${ids[index - 1]}'),
        );
        expect(
          tester.getRect(row).top - tester.getRect(previous).bottom,
          closeTo(gap, .001),
        );
      }
    }
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('topic Contents board dark=$dark scale=$scale',
          (tester) async {
        await pumpContents(tester, dark: dark, scale: scale);
        expect(find.text('Chemistry'), findsOneWidget);
        expect(find.text('Reading'), findsOneWidget);
        expect(find.text('10 min'), findsOneWidget);
        final rows = tester.widgetList<ListRow>(find.byType(ListRow)).toList();
        expect(
          rows.map((row) => row.title),
          ['Lesson 1', 'Lesson 2', 'Lesson 3'],
        );
        final colors = dark ? PantasColors.dark : PantasColors.light;
        expectRowSeparators(
          tester,
          ['l1', 'l2', 'l3'],
          color: colors.separator,
          gap: 0,
        );
        for (final row in rows) {
          final title = row.richTitle! as TextSpan;
          expect(title.style!.fontFamily, 'Geist');
          expect(title.style!.fontSize, 16);
          expect(title.style!.fontWeight, FontWeight.w400);
        }
        expect(
          (rows[1].richTitle! as TextSpan).style!.color,
          colors.secondaryLabel,
        );
        final tick = tester.widget<Icon>(find.byIcon(PantasIcons.check));
        expect(tick.size, 18);
        expect(tick.color, colors.accent);
        if (scale == 1) {
          expect(
            tester
                .getSize(
                  find.byKey(
                    const ValueKey('pantas-sheet-surface'),
                  ),
                )
                .height,
            lessThan(400),
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final dark in [false, true]) {
    testWidgets('chosen topic fade persists for fit and end dark=$dark',
        (tester) async {
      await pumpContents(tester, dark: dark);
      final fade = find.byKey(const ValueKey('contents-fade'));
      expect(fade, findsOneWidget);
      expect(tester.getSize(fade).height, 56);
      final gradient =
          (tester.widget<DecoratedBox>(fade).decoration as BoxDecoration)
              .gradient! as LinearGradient;
      final surface =
          dark ? PantasColors.dark.surface : PantasColors.light.surface;
      expect(gradient.colors, [surface.withValues(alpha: 0), surface]);
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      await tester.drag(
        find.byKey(const ValueKey('contents-topic-list')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(fade, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('topic400px scroll end retains fade and passes last-row taps',
      (tester) async {
    final longReader = ReaderContext(
      lesson: reader.lesson,
      topicId: reader.topicId,
      topicName: reader.topicName,
      next: reader.next,
      positionInTopic: 1,
      lessonsInTopic: 20,
      topicLessons: [
        first,
        readLesson,
        unread,
        for (var i = 4; i <= 20; i++)
          StudyLesson(
            id: 'l$i',
            title: 'Lesson $i',
            estimatedMinutes: 10,
            isRead: false,
            isBookmarked: false,
          ),
      ],
      isRead: false,
      isBookmarked: false,
      examId: reader.examId,
    );
    String? selected;
    await pumpContents(
      tester,
      readerContext: longReader,
      onSelect: (id) => selected = id,
    );
    final list = find.byKey(const ValueKey('contents-topic-list'));
    expect(tester.getSize(list).height, 400);
    await tester.drag(list, const Offset(0, -1400));
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(
      find.descendant(
        of: list,
        matching: find.byType(Scrollable),
      ),
    );
    expect(scroll.position.extentAfter, 0);
    expect(find.byKey(const ValueKey('contents-fade')), findsOneWidget);
    await tester.tap(find.text('Lesson 20'));
    expect(selected, 'l20');
    expect(tester.takeException(), isNull);
  });

  testWidgets('day Contents uses real metadata in the supplied order',
      (tester) async {
    await pumpContents(tester, dayContext: day());
    expect(find.text('Today'), findsOneWidget);
    expect(find.byKey(const ValueKey('contents-fade')), findsNothing);
    final rows = tester.widgetList<ListRow>(find.byType(ListRow)).toList();
    expect(rows.map((row) => row.title), ['Lesson 4', 'Lesson 1', 'Lesson 2']);
    expectRowSeparators(
      tester,
      ['l4', 'l1', 'l2'],
      color: PantasColors.light.separator,
      gap: 6,
    );
    expect(
      rows.map((row) => row.subtitle),
      ['Biology', 'Chemistry', 'Chemistry'],
    );
    expect(find.text('12 min'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Contents selection uses the owning reader callback',
      (tester) async {
    String? selected;
    await pumpContents(tester, onSelect: (id) => selected = id);
    await tester.tap(find.text('Lesson 3'));
    expect(selected, 'l3');
  });

  testWidgets('past day Contents names the actual supplied date',
      (tester) async {
    final date = DateTime.now().subtract(const Duration(days: 2));
    await pumpContents(tester, dayContext: day(date: date));
    expect(find.text(PantasDates.relativeDay(date)), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('day Contents retries its real metadata without raw errors',
      (tester) async {
    var attempts = 0;
    await pumpContents(
      tester,
      dayContext: day(),
      overrides: [
        studyMapProvider.overrideWith((_) async {
          attempts++;
          if (attempts == 1) throw StateError('private fixture details');
          return map;
        }),
      ],
    );
    expect(find.text('Could not load your lessons.'), findsOneWidget);
    expect(find.textContaining('private fixture details'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('day Contents announces loading before shared shapes appear',
      (tester) async {
    final pending = Completer<StudyMap?>();
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [studyMapProvider.overrideWith((_) => pending.future)],
        child: LessonContentsSheet(
          reader: reader,
          dayContext: day(),
          onSelectLesson: (_) {},
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    try {
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      expect(find.byType(SkeletonPulse), findsWidgets);
      final shapes = find.descendant(
        of: find.byType(SkeletonPulse),
        matching: find.byType(DecoratedBox),
      );
      expect(shapes, findsNothing);
      await tester.pump(const Duration(milliseconds: 250));
      expect(shapes, findsNothing);
      await tester.pump(const Duration(milliseconds: 50));
      expect(shapes, findsWidgets);
      pending.complete(map);
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}
