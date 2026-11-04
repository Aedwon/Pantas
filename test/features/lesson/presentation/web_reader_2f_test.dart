import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

// QA 2F: the title block, the outline, the contents menu and the way the bar
// and the lesson window move, on the wide reader.

const _first = StudyLesson(
  id: 'l1',
  title: 'Layers',
  estimatedMinutes: 11,
  isRead: true,
  isBookmarked: false,
);
const _longName = 'Order of Operations (PEMDAS/GEMDAS) and Other Ways to '
    'Check a Long Computation';
const _second = StudyLesson(
  id: 'l2',
  title: _longName,
  estimatedMinutes: 12,
  isRead: false,
  isBookmarked: false,
);

Map<String, Object?> _text(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

/// A lesson long enough to scroll, with an example whose solution is hidden.
List<Map<String, Object?>> _body({int paragraphs = 14}) => [
      _text('Core Concept', style: 'h2'),
      for (var i = 0; i < paragraphs; i++)
        _text('Paragraph $i. ${'Words that fill a line. ' * 14}'),
      _text('Examples', style: 'h2'),
      _text('#1: Adding', style: 'h3'),
      _text('What is two plus two?'),
      _text('Solution:'),
      {
        ..._text('Add the two numbers.'),
        'listItem': 'number',
        'level': 1,
      },
      for (var i = 0; i < paragraphs; i++)
        _text(
          'Paragraph $i after the example. ${'More words in a line. ' * 14}',
        ),
      _text('Traps to Watch For', style: 'h2'),
      for (var i = 0; i < paragraphs; i++)
        _text('Trap $i. ${'A careful sentence goes here. ' * 14}'),
    ];

ReaderContext _reader({List<Map<String, Object?>>? body}) => ReaderContext(
      lesson: Lesson(
        id: 'l1',
        topicId: 't1',
        title: 'Layers of the Earth',
        summary: '',
        estimatedMinutes: 11,
        bodyJson: body ?? _body(),
      ),
      topicId: 't1',
      topicName: 'Earth Science',
      next: _second,
      positionInTopic: 1,
      lessonsInTopic: 2,
      topicLessons: const [_first, _second],
      isRead: true,
      isBookmarked: false,
      examId: 'e',
    );

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late ScrollController scroll;
  late ValueNotifier<double> offset;
  late ValueNotifier<double> progress;
  var backs = 0;

  Future<void> pumpReader(
    WidgetTester tester, {
    ReaderContext? reader,
    bool reduceMotion = false,
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    scroll = ScrollController();
    offset = ValueNotifier<double>(0);
    progress = ValueNotifier<double>(0);
    scroll.addListener(() => offset.value = scroll.offset);
    addTearDown(scroll.dispose);
    addTearDown(offset.dispose);
    addTearDown(progress.dispose);
    backs = 0;
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildDarkTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reduceMotion,
            ),
            child: child!,
          ),
          home: Scaffold(
            body: WebReaderLayout(
              reader: reader ?? _reader(),
              controller: scroll,
              scrollOffset: offset,
              progress: progress,
              onBack: () => backs++,
              onBookmark: () {},
              onLesson: (_) {},
              footer: const SizedBox(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Offset slide(WidgetTester tester) => tester
      .widget<AnimatedSlide>(
        find.byKey(const ValueKey('web-reader-focus-slide')),
      )
      .offset;

  group('the title block (2F-1, 2F-23)', () {
    testWidgets('matches the design: 46 px title, 8 px and 36 px of space',
        (tester) async {
      await pumpReader(tester);
      // The bar holds the same title, faded out, after the lesson's own.
      final title = find.text('Layers of the Earth').first;
      final style = tester.widget<Text>(title).style!;
      expect(style.fontSize, 46);
      expect(style.height, 1.08);
      expect(style.letterSpacing, -.9);
      final meta = find.text('Earth Science · 11 min');
      expect(
        tester.getTopLeft(title).dy - tester.getBottomLeft(meta).dy,
        closeTo(8, .01),
      );
      expect(
        tester.getTopLeft(find.text('Core Concept').last).dy -
            tester.getBottomLeft(title).dy,
        closeTo(36, .01),
      );
    });
  });

  group('the outline (2F-3, 2F-8)', () {
    testWidgets('rows are 32 px apart and the heading is 38 px above',
        (tester) async {
      await pumpReader(tester);
      final rows = [
        for (final name in ['Core Concept', 'Examples', 'Traps to Watch For'])
          tester.getTopLeft(
            find
                .descendant(
                  of: find.byKey(const ValueKey('web-reader-outline')),
                  matching: find.text(name),
                )
                .first,
          ),
      ];
      expect(rows[1].dy - rows[0].dy, closeTo(32, .01));
      expect(rows[2].dy - rows[1].dy, closeTo(32, .01));
      final heading = tester.getTopLeft(find.text('IN THIS LESSON'));
      expect(rows[0].dy - heading.dy, closeTo(38, .5));
    });

    Finder outlineRow(String name) => find
        .descendant(
          of: find.byKey(const ValueKey('web-reader-outline')),
          matching: find.text(name),
        )
        .first;

    testWidgets('a click scrolls to the section with motion', (tester) async {
      await pumpReader(tester);
      await tester.tap(outlineRow('Traps to Watch For'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final middle = scroll.offset;
      expect(middle, greaterThan(0), reason: 'it has started to move');
      await tester.pumpAndSettle();
      final end = scroll.offset;
      expect(end, greaterThan(middle), reason: 'it was not there yet');
      // The heading lands under the bar, 5 percent into the room below it.
      final heading = tester.getTopLeft(find.text('Traps to Watch For').last);
      expect(heading.dy, closeTo(60 + .05 * 840, 2));
    });

    testWidgets('with reduced motion the page is there at once',
        (tester) async {
      await pumpReader(tester, reduceMotion: true);
      await tester.tap(outlineRow('Traps to Watch For'));
      await tester.pump();
      final end = scroll.offset;
      expect(end, greaterThan(0));
      await tester.pumpAndSettle();
      expect(scroll.offset, end);
    });
  });

  group('the contents menu (2F-6, 2F-7)', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.text('1 of 2'));
      await tester.pumpAndSettle();
    }

    testWidgets('Esc closes it and does not leave the lesson', (tester) async {
      await pumpReader(tester);
      await openMenu(tester);
      expect(find.text(' · 2 LESSONS'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text(' · 2 LESSONS'), findsNothing);
      expect(backs, 0);
      // With the menu shut, Esc goes back as before.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(backs, 1);
    });

    testWidgets('a long lesson name wraps instead of ending in an ellipsis',
        (tester) async {
      await pumpReader(tester);
      await openMenu(tester);
      final name = find.text(_longName);
      expect(name, findsOneWidget);
      final text = tester.widget<Text>(name);
      expect(text.maxLines, isNull);
      expect(text.overflow, isNot(TextOverflow.ellipsis));
      final box = tester.renderObject<RenderBox>(name);
      expect(box.size.height, greaterThan(30), reason: 'two or more lines');
      final short = tester.getSize(find.text('Layers').last);
      expect(short.height, lessThan(24));
    });
  });

  group('the bar and the lesson window (2F-5, 2F-9)', () {
    testWidgets('the window follows the bar and no band is left',
        (tester) async {
      await pumpReader(tester);
      Rect window() => tester.getRect(
            find.byKey(const ValueKey('web-reader-viewport')),
          );
      expect(window().top, 60);
      scroll.jumpTo(600);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(window().top, lessThan(60), reason: 'it is growing up');
      await tester.pumpAndSettle();
      expect(slide(tester), const Offset(0, -1));
      expect(window().top, 0);
      // The text did not move while the window grew: scrolled by 600, the
      // first heading is still 60 + 48 - 600 + 0 above where it began.
      expect(
        tester.getTopLeft(find.text('Layers of the Earth').first).dy,
        closeTo(60 + 48 + 15 * 1.45 + 8 - 600, 1),
      );
      scroll.jumpTo(500);
      await tester.pumpAndSettle();
      expect(slide(tester), Offset.zero);
      expect(window().top, 60);
    });

    testWidgets('opening a solution does not bring the bar back',
        (tester) async {
      await pumpReader(tester);
      // Find a place where the bar is hidden and the button is on screen.
      final button = find.byKey(const ValueKey('reader-solution-button'));
      var found = false;
      for (var y = 400.0; y < scroll.position.maxScrollExtent; y += 40) {
        scroll.jumpTo(y);
        await tester.pumpAndSettle();
        if (button.evaluate().isEmpty) continue;
        final rect = tester.getRect(button);
        if (rect.top > 120 && rect.bottom < 840 && slide(tester).dy == -1) {
          found = true;
          break;
        }
      }
      expect(found, isTrue, reason: 'a place with the bar hidden');
      // A keyboard student, with focus on the button.
      tester.widget<TextButton>(button).focusNode!.requestFocus();
      await tester.pump();
      await tester.tap(button);
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(slide(tester), const Offset(0, -1), reason: 'frame $i');
      }
      await tester.pumpAndSettle();
      expect(find.text('Add the two numbers.'), findsOneWidget);
      expect(slide(tester), const Offset(0, -1));
    });

    testWidgets('Tab onto a bar control brings the bar back', (tester) async {
      await pumpReader(tester);
      scroll.jumpTo(900);
      await tester.pumpAndSettle();
      expect(slide(tester), const Offset(0, -1));
      // The first stops are the outline and the lesson; the bar comes last.
      var shown = -1;
      for (var i = 0; i < 14 && shown < 0; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        if (slide(tester) == Offset.zero) shown = i;
      }
      expect(shown, greaterThan(2), reason: 'not on the first stops');
      expect(shown, greaterThan(-1), reason: 'it came back in the end');
    });
  });
}
