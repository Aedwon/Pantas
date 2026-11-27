import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_layout_theme.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';

/// Aedwon, Nov 26, on the live Lessons tab: "10 answered" was cut to "10
/// answerec", the percent and the chevron were off the card, and the bar ran
/// into its edge. Then: "just add (X) as simple as that". Every row now shows
/// a quiet "(N)" and the whole row fits its card at any name and count.
void main() {
  tearDown(() => debugWebPlatformOverride = null);

  const longName = 'Article XI: Public Trust and Impeachable Officers Under '
      'the Constitution of the Republic of the Philippines';
  const subject = PerformanceRow(
    id: 'math',
    title: 'Mathematics',
    subtext: null,
    correct: 10,
    answered: 10,
    secondsPerQuestion: null,
  );
  const topic = PerformanceRow(
    id: 'geo',
    title: longName,
    subtext: 'Philippine Constitution',
    correct: 123,
    answered: 123,
    secondsPerQuestion: null,
  );
  const lesson = PerformanceRow(
    id: 'long',
    title: longName,
    subtext: 'Philippine Constitution and Government',
    correct: 123,
    answered: 123,
    secondsPerQuestion: null,
  );
  const short = PerformanceRow(
    id: 'circles',
    title: 'Markup on Cost',
    subtext: 'Arithmetic & Number Sense',
    correct: 4,
    answered: 10,
    secondsPerQuestion: null,
  );
  const data = PerformanceViewData(
    subjects: [subject],
    topics: [topic],
    lessons: [lesson, short],
    subjectCounts: {'math': 1},
    lessonLevelAvailable: true,
    parentSubjectIds: {'geo': 'math', 'long': 'math', 'circles': 'math'},
  );

  Future<void> show(
    WidgetTester tester, {
    required double width,
    int level = 0,
    bool pro = true,
  }) async {
    final web = width >= 1024;
    tester.view
      ..physicalSize = Size(width, web ? 1000 : 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugWebPlatformOverride = web;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(web: web),
        home: WebLayoutTheme(
          web: web,
          child: PerformancePage(
            data: data,
            pro: pro,
            paused: false,
            initialLevel: level,
            onTopic: (_) {},
            onPro: () {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const tabs = ['Subjects', 'Topics', 'Lessons'];

  for (final width in [1440.0, 390.0]) {
    for (final tab in tabs) {
      testWidgets('no $tab row says "answered" at ${width.toInt()}',
          (tester) async {
        await show(tester, width: width, level: tabs.indexOf(tab));
        expect(tester.takeException(), isNull);
        // The page line says "everything you've answered"; a row would say
        // "10 answered".
        expect(find.textContaining(RegExp(r'\d+ answered')), findsNothing);
        expect(find.text('ANSWERED'), findsNothing);
      });
    }

    testWidgets(
        'a 3 digit count and a long name show the whole "(123)" at '
        '${width.toInt()}', (tester) async {
      await show(tester, width: width, level: 2);
      expect(tester.takeException(), isNull);
      final long = find.textContaining('(123)');
      expect(long, findsOneWidget);
      expect(find.textContaining('(10)'), findsOneWidget);
      // The whole count is laid out inside the screen: it is not cut or
      // pushed past an edge.
      final box = tester.getRect(long);
      expect(box.left, greaterThanOrEqualTo(0));
      expect(box.right, lessThanOrEqualTo(width));
      final paragraph = tester.renderObject<RenderParagraph>(long);
      expect(paragraph.didExceedMaxLines, isFalse);
      // The long name wraps to two lines at least, and wraps whole.
      expect(box.height, greaterThan(40));
    });
  }

  testWidgets('a wide row keeps its bar and percent inside the card',
      (tester) async {
    await show(tester, width: 1440, level: 2);
    expect(tester.takeException(), isNull);
    final card = tester.getRect(find.byKey(const ValueKey('data-table')));
    final percent = tester.getRect(find.text('100%').first);
    final bar = tester.getRect(find.byType(AccuracyBar).first);
    // The percent shows in the card, with the card's 20 inside padding to its
    // right (the chevron sits after it).
    expect(percent.right, lessThan(card.right - 20));
    // The bar ends before the percent and well inside the card, never at its
    // edge.
    expect(bar.right, lessThan(percent.left));
    expect(bar.right, lessThanOrEqualTo(card.right - 20 - 16));
  });

  // Aedwon, Nov 26: "overall as its own column is a waste of space imo".
  // Overall sits above the tabs as on the phone, and the list takes the full
  // content width.
  for (final (label, level, pro) in [
    ('Subjects', 0, true),
    ('Topics', 1, true),
    ('Lessons', 2, true),
    ('Free Subjects', 0, false),
  ]) {
    testWidgets('wide $label: Overall is above the tabs, no second column',
        (tester) async {
      await show(tester, width: 1440, level: level, pro: pro);
      expect(tester.takeException(), isNull);
      // The board's "OVERALL" eyebrow column is gone.
      expect(find.text('OVERALL'), findsNothing);
      final gauge = tester.getRect(find.text('Overall accuracy'));
      final tabs = tester.getRect(find.byType(WebSegmentedControl));
      final table = tester.getRect(find.byKey(const ValueKey('data-table')));
      expect(gauge.bottom, lessThan(tabs.top));
      // The list is not squeezed into a main column beside the gauge.
      expect(table.width, greaterThan(1000));
      // The gauge sits centered over the list, as on the phone.
      expect(gauge.center.dx, closeTo(table.center.dx, 2));
    });
  }

  testWidgets('a phone row shows the percent and the count', (tester) async {
    await show(tester, width: 390, level: 2);
    expect(find.text('100%'), findsWidgets);
    // The subtitle keeps only the parent name.
    expect(find.text('Arithmetic & Number Sense'), findsOneWidget);
  });
}
