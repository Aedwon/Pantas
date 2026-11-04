import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';

void main() {
  final history = [
    for (var i = 0; i < 17; i++)
      PlanHistoryEntry(id: 'h$i', date: 'Today', text: 'Actual change $i'),
  ];
  Widget show({
    bool pro = true,
    bool paused = false,
    bool motion = false,
    bool dark = false,
    int done = 2,
  }) =>
      MaterialApp(
        theme: dark ? buildDarkTheme() : buildLightTheme(),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: !motion),
          child: PlanPage(
            pro: pro,
            paused: paused,
            done: done,
            total: 4,
            subtitle: '42 days until CSE-P',
            nodes: const [
              PlanNode(
                kind: PlanNodeKind.week,
                title: 'Oct 4 – 10',
                subtitle: 'Actual topic',
                date: 'Next week',
                target: '2026-10-04',
              ),
              PlanNode(
                kind: PlanNodeKind.exam,
                title: 'CSE-P',
                subtitle: 'Exam day',
                date: 'Wed, Nov 11',
              ),
            ],
            history: history,
            onBack: () {},
            onToday: () {},
            onWeek: (_) {},
            onPro: () {},
          ),
        ),
      );
  testWidgets('timeline draws the segment before the next node',
      (tester) async {
    await tester.pumpWidget(show(motion: true));
    await tester.pump(const Duration(milliseconds: 540));
    final line =
        tester.widget<Transform>(find.byKey(const ValueKey('plan-line-0')));
    expect(line.transform.storage[5], closeTo(0.5, 0.02));
    await tester.pumpAndSettle();
  });
  for (final dark in [true, false]) {
    testWidgets('the empty Today ring is visible, dark=$dark (A-1, 2G-17)',
        (tester) async {
      await tester.pumpWidget(show(dark: dark, done: 0));
      await tester.pumpAndSettle();
      final colors = dark ? PantasColors.dark : PantasColors.light;
      final ring = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.size == const Size.square(34),
        ),
      );
      // ignore: avoid_dynamic_calls
      final track = (ring.painter! as dynamic).track as Color;
      // Dark takes the 3:1 gray, light keeps the board's pale fill.
      expect(track, dark ? colors.chevron : colors.fill);
    });
  }
  testWidgets('only week rows drill down', (tester) async {
    await tester.pumpWidget(show());
    final today = tester.widget<ListRow>(
      find.byWidgetPredicate((w) => w is ListRow && w.title == '2 of 4 done'),
    );
    expect(today.onTap, isNull);
    expect(find.byType(PantasLogo), findsOneWidget);
  });
  testWidgets('history starts at five, adds ten, and ends honestly',
      (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    expect(find.text('2 of 4 done'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('See more'), 200);
    await tester.tap(find.text('See more'));
    await tester.pumpAndSettle();
    expect(find.text('Actual change 14'), findsOneWidget);
    expect(find.text('Actual change 15'), findsNothing);
    await tester.scrollUntilVisible(find.text('See more'), 200);
    await tester.tap(find.text('See more'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text("That's everything since you started."),
      200,
    );
    expect(find.text('See more'), findsNothing);
  });
  testWidgets('Free shows approved invitation without future topics or history',
      (tester) async {
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    expect(find.text('Actual topic'), findsNothing);
    expect(find.text('Actual change 0'), findsNothing);
    expect(find.text('CSE-P'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Unlock with Pro'), 200);
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });
  testWidgets('paused future access uses existing paused line', (tester) async {
    await tester.pumpWidget(show(pro: false, paused: true));
    await tester.pumpAndSettle();
    expect(find.text('Connect once to keep using Pro.'), findsOneWidget);
    expect(find.text('Unlock with Pro'), findsNothing);
  });
}
