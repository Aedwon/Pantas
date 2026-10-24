import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';

void main() {
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
