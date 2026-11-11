import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';

void main() {
  _originalDayTests();
  for (final dark in [false, true]) {
    for (final past in [false, true]) {
      testWidgets('day past=$past dark=$dark preserves rows at 200% text',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var opened = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? buildDarkTheme() : buildLightTheme(),
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: PlanDayPage(
                date: DateTime(2026, 10, 6),
                past: past,
                rest: false,
                lessons: const [
                  HomeTodayLesson(
                    id: 'l',
                    title: 'DNA and genes',
                    subject: 'Biology',
                    minutes: 8,
                    read: true,
                  ),
                ],
                reviewsDone: 18,
                reviewsTotal: 18,
                newDone: 7,
                newTotal: 7,
                onBack: () {},
                onLesson: (_) => opened++,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Read'), findsOneWidget);
        await tester.tap(find.text('DNA and genes'));
        expect(opened, 1);
        await tester.scrollUntilVisible(find.text('New questions'), 100);
        expect(find.text('18 of 18'), past ? findsOneWidget : findsNothing);
        expect(find.text('7 of 7'), past ? findsOneWidget : findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('week dark=$dark opens study days and keeps rest days inert',
        (tester) async {
      DateTime? selected;
      var changed = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: PlanWeekPage(
              title: 'Oct 4 – 10',
              days: [
                PlanWeekDay(
                  date: DateTime(2026, 10, 4),
                  rest: true,
                  lessonTitles: const [],
                ),
                PlanWeekDay(
                  date: DateTime(2026, 10, 5),
                  rest: false,
                  lessonTitles: const ['DNA and genes'],
                ),
              ],
              studyDaysLabel: 'You study Monday to Saturday.',
              onBack: () {},
              onDay: (date) => selected = date,
              onChange: () => changed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rest day'));
      expect(selected, isNull);
      await tester.tap(find.text('DNA and genes'));
      expect(selected, DateTime(2026, 10, 5));
      await tester.scrollUntilVisible(find.text('Change'), 100);
      await tester.tap(find.text('Change'));
      expect(changed, 1);
      expect(tester.takeException(), isNull);
    });
  }
}

void _originalDayTests() {
  Widget show({bool past = false, bool rest = false}) => MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PlanDayPage(
            date: DateTime(2026, 10, 6),
            past: past,
            rest: rest,
            lessons: const [
              HomeTodayLesson(
                id: 'l',
                title: 'DNA and genes',
                subject: 'Biology',
                minutes: 8,
                read: true,
              ),
            ],
            reviewsDone: 2,
            reviewsTotal: 3,
            newDone: 1,
            newTotal: 4,
            onBack: () {},
            onLesson: (_) {},
          ),
        ),
      );
  testWidgets('future question rows have no invented counts and no launch',
      (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    expect(find.text('Set that morning'), findsOneWidget);
    expect(find.text("From this day's lessons"), findsOneWidget);
    expect(find.text('2 of 3'), findsNothing);
    expect(
      find.text('Reviews and new questions are counted that morning.'),
      findsOneWidget,
    );
  });
  testWidgets('past day shows only actual completion values', (tester) async {
    await tester.pumpWidget(show(past: true));
    await tester.pumpAndSettle();
    expect(find.text('2 of 3'), findsOneWidget);
    expect(find.text('1 of 4'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
  });
  testWidgets('rest day never exposes a lesson substitute', (tester) async {
    await tester.pumpWidget(show(rest: true));
    await tester.pumpAndSettle();
    expect(find.text('Rest day'), findsOneWidget);
    expect(find.text('DNA and genes'), findsNothing);
  });
}
