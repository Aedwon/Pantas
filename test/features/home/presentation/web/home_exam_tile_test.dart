import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';

/// Boards HM_ExamDay, HM_ExamPassed and HM_NoDate: the exam tile in the week
/// card is teal today, gray once passed and a dashed gray tile with no date.
final _now = DateTime(2026, 11, 4, 12);

Future<void> _mount(
  WidgetTester tester,
  ExamDate? date, {
  bool dark = false,
}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeMastheadProvider.overrideWith(
          (ref) async => HomeMastheadData(
            name: 'Aedwon',
            examShortName: 'CSE',
            examDate: date,
          ),
        ),
        weekStripProvider('cse').overrideWith(
          (ref) async => HomeWeekStripData(
            states: List.filled(7, WeekDayState.plain),
            todayFraction: 0,
          ),
        ),
      ],
      child: MaterialApp(
        theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
        home: Scaffold(
          body: SizedBox(
            width: 1080,
            child: HomeMasthead(web: true, examId: 'cse', now: _now),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Color _color(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.color!;

Border _outline(WidgetTester tester) {
  final tile = tester.widget<Container>(
    find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.constraints ==
              const BoxConstraints(
                minWidth: 42,
                maxWidth: 42,
                minHeight: 36,
              ),
    ),
  );
  return (tile.decoration! as BoxDecoration).border! as Border;
}

void main() {
  for (final dark in [false, true]) {
    final t = WebTokens(dark ? Brightness.dark : Brightness.light);

    testWidgets('exam day: teal outline and teal Today, dark=$dark',
        (tester) async {
      await _mount(tester, ExamDate.onDay(DateTime(2026, 11, 4)), dark: dark);
      expect(_outline(tester).top.color, t.colors.accent);
      expect(_color(tester, 'Today'), t.colors.accent);
    });

    testWidgets('exam passed: gray outline, date and Passed, dark=$dark',
        (tester) async {
      await _mount(tester, ExamDate.onDay(DateTime(2026, 10, 28)), dark: dark);
      expect(_outline(tester).top.color, t.colors.textSecondary);
      expect(
        tester.widget<Text>(find.text('28')).style!.color,
        t.colors.textSecondary,
      );
      expect(_color(tester, 'Passed'), t.sm.color);
    });

    testWidgets(
        'no date: dashed gray tile, gray plus, teal Add date, '
        'dark=$dark', (tester) async {
      await _mount(tester, null, dark: dark);
      expect(
        find.byKey(const ValueKey('web-exam-tile-dashed')),
        findsOneWidget,
      );
      expect(_color(tester, '+'), t.colors.textSecondary);
      expect(_color(tester, 'Add date'), t.colors.accent);
    });
  }

  testWidgets('a day to come keeps the label color outline', (tester) async {
    await _mount(tester, ExamDate.onDay(DateTime(2026, 11, 20)));
    const t = WebTokens(Brightness.light);
    expect(_outline(tester).top.color, t.colors.textPrimary);
    expect(find.byKey(const ValueKey('web-exam-tile-dashed')), findsNothing);
  });
}
