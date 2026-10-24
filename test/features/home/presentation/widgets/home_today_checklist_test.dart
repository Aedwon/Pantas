import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';

HomeTodayLesson lesson(
  int n, {
  bool read = false,
  double? fraction,
  bool advanced = false,
}) =>
    HomeTodayLesson(
      id: 'l$n',
      title: n == 0
          ? 'Solving word problems with ratios and proportions'
          : 'Lesson $n',
      subject: 'Mathematics',
      minutes: 8,
      read: read,
      fraction: fraction,
      advanced: advanced,
    );

Widget harness(
  List<HomeTodayLesson> lessons, {
  bool dark = false,
  bool large = false,
  bool advance = false,
  bool mock = false,
}) =>
    MaterialApp(
      theme: dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(large ? 2 : 1),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: HomeTodayChecklist(
              lessons: lessons,
              reviewsDone: 2,
              reviewsTotal: 7,
              newDone: 0,
              newTotal: 4,
              canAdvance: advance,
              isMockDay: mock,
              onLesson: (_) {},
              onLessons: () {},
              onReviews: () {},
              onNew: () {},
              onPlan: () {},
              onAdvance: () {},
              onMock: () {},
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows actual lesson progress and question counts',
      (tester) async {
    await tester
        .pumpWidget(harness([lesson(0, fraction: .3), lesson(1, read: true)]));
    await tester.pumpAndSettle();
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('View full plan'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Resume Lesson'), findsOneWidget);
    expect(find.text('2 of 7'), findsOneWidget);
    expect(
      tester
          .widgetList<ProgressRing>(find.byType(ProgressRing))
          .any((r) => r.fraction == .3),
      isTrue,
    );
  });
  testWidgets('four or more lessons collapse around the next unread lesson',
      (tester) async {
    await tester.pumpWidget(
      harness([lesson(0, read: true), lesson(1), lesson(2), lesson(3)]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('1 of 4 read'), findsOneWidget);
    expect(find.text('Lesson 1'), findsOneWidget);
    expect(find.text('Lesson 2'), findsNothing);
  });
  testWidgets('advanced work preserves the completed original summary',
      (tester) async {
    await tester.pumpWidget(
      harness(
        [lesson(0, read: true), lesson(1, advanced: true)],
        advance: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Today's done"), findsOneWidget);
    expect(find.text('FROM TOMORROW'), findsOneWidget);
    expect(find.text('Lesson 1'), findsOneWidget);
  });
  testWidgets('completion only offers advance when the engine permits it',
      (tester) async {
    await tester.pumpWidget(harness([lesson(0, read: true)], advance: true));
    await tester.pumpAndSettle();
    expect(find.text('I Want to Advance'), findsOneWidget);
    await tester.pumpWidget(harness([lesson(0, read: true)]));
    await tester.pumpAndSettle();
    expect(find.text('I Want to Advance'), findsNothing);
  });
  testWidgets('long lesson titles stay on one line with ellipsis',
      (tester) async {
    await tester.pumpWidget(harness([lesson(0)], large: true));
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(
      find.text('Solving word problems with ratios and proportions'),
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });
  for (final dark in [false, true]) {
    testWidgets(
        'large text and mock row fit in ${dark ? "dark" : "light"} mode',
        (tester) async {
      await tester.pumpWidget(
        harness([lesson(0)], dark: dark, large: true, mock: true),
      );
      await tester.pumpAndSettle();
      expect(find.text('Start Mock Exam'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
