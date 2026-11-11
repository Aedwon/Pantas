import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'onboarding calendar measurements and contrast $brightness $scale',
          (tester) async {
        var value = const MonthFirstDate(year: 2026, month: 11, day: 11);
        await pumpAccessibilitySurface(
          tester,
          SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) => MonthFirstDatePicker.onboarding(
                value: value,
                today: DateTime(2026, 10, 3),
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
          brightness: brightness,
          textScale: scale,
          disableAnimations: true,
          viewportSize: const Size(390, 844),
        );
        await tester.pumpAndSettle();
        final picker = find.byType(MonthFirstDatePicker);
        final colors = tester.element(picker).colors;
        expect(find.text('November 2026'), findsOneWidget);
        // One calendar on the page: no cards, no month tiles, no day strip.
        expect(
          find.byKey(const ValueKey('onboarding-month-card')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('onboarding-day-card')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('onboarding-day-strip')),
          findsNothing,
        );
        expect(find.text('Nov'), findsNothing);
        final day = find.byKey(const ValueKey('date-day-11'));
        await tester.ensureVisible(day);
        final cell = tester.widget<Text>(
          find.descendant(of: day, matching: find.byType(Text)),
        );
        expect(cell.style!.fontSize, 15);
        expect(cell.style!.fontWeight, FontWeight.w700);
        expectContrast(cell.style!.color!, colors.accentFill);
        expect(tester.getSize(day).height, greaterThanOrEqualTo(46));
        final weekday = tester.widget<Text>(find.textContaining('S').first);
        expect(weekday.style!.fontSize, 11);
        expectContrast(weekday.style!.color!, colors.bgPage);
        await tester.tap(find.byTooltip('Next month'));
        await tester.pumpAndSettle();
        expect(find.text('December 2026'), findsOneWidget);
        expect(value.month, 12);
        expect(value.day, isNull);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('the calendar has no year slide and no day strip',
      (tester) async {
    var value = const MonthFirstDate(year: 2026, month: 11, day: 11);
    await pumpAccessibilitySurface(
      tester,
      StatefulBuilder(
        builder: (context, setState) => MonthFirstDatePicker.onboarding(
          value: value,
          today: DateTime(2026, 10, 3),
          onChanged: (next) => setState(() => value = next),
        ),
      ),
      viewportSize: const Size(390, 844),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(AnimatedSwitcher), findsNothing);
    expect(find.byKey(const ValueKey('onboarding-day-strip')), findsNothing);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(value.month, 12);
  });

  testWidgets('a chosen day has no line under the calendar', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      SingleChildScrollView(
        child: MonthFirstDatePicker.onboarding(
          value: const MonthFirstDate(year: 2026, month: 11, day: 11),
          today: DateTime(2026, 10, 3),
          onChanged: (_) {},
        ),
      ),
      disableAnimations: true,
      viewportSize: const Size(390, 844),
    );
    await tester.pumpAndSettle();
    expect(find.text('Wednesday, November 11'), findsNothing);
    expect(find.textContaining('No day yet?'), findsNothing);
  });
}
