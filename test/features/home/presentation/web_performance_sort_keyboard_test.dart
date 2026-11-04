import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_layout_theme.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';

/// A-24 and 2G-13. Flutter on the web sends the arrow keys to page scrolling
/// and Enter to buttons only, so a stock popup menu ignores ArrowDown and
/// Enter in a browser. The sort menu keeps its own highlighted row.
void main() {
  const topic = PerformanceRow(
    id: 'geo',
    title: 'Geometry',
    subtext: 'Mathematics',
    correct: 2,
    answered: 5,
    secondsPerQuestion: null,
  );
  const data = PerformanceViewData(
    subjects: [],
    topics: [topic],
    lessons: [],
    subjectCounts: {},
    lessonLevelAvailable: true,
    parentSubjectIds: {'geo': 'math'},
  );
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> openSortMenu(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: WebLayoutTheme(
          web: true,
          child: PerformancePage(
            data: data,
            pro: true,
            paused: false,
            onTopic: (_) {},
            onPro: () {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weakest first'));
    await tester.pumpAndSettle();
  }

  testWidgets('arrow keys move the highlight and Enter picks it',
      (tester) async {
    await openSortMenu(tester);
    expect(find.text('A to Z'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('A to Z'), findsOneWidget);
    expect(find.text('Strongest first'), findsNothing);
    expect(find.textContaining('A TO Z'), findsOneWidget);
  });

  testWidgets('ArrowUp, Home and Space work and Esc closes', (tester) async {
    await openSortMenu(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('Strongest first'), findsOneWidget);
    expect(find.text('A to Z'), findsNothing);

    await tester.tap(find.text('Strongest first'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('A to Z'), findsNothing);
    expect(find.text('Strongest first'), findsOneWidget);
  });

  testWidgets(
      'the sort button tints inside its rounded pill and shows no tooltip '
      '(3K-5)', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: WebLayoutTheme(
          web: true,
          child: PerformancePage(
            data: data,
            pro: true,
            paused: false,
            onTopic: (_) {},
            onPro: () {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(
      location: tester.getCenter(find.text('All subjects')),
    );
    await mouse.moveTo(tester.getCenter(find.text('Weakest first')));
    await tester.pump(const Duration(seconds: 2));
    // A tooltip would repeat the button's own text.
    expect(find.text('Weakest first'), findsOneWidget);
    final ink = tester.widget<InkWell>(
      find
          .ancestor(
            of: find.text('Weakest first'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    expect(ink.borderRadius, BorderRadius.circular(12));
  });
}
