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
        expect(
          find.byKey(const ValueKey('onboarding-month-card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('onboarding-day-card')),
          findsOneWidget,
        );
        final month = tester.widget<Text>(find.text('Nov'));
        expect(month.style!.fontSize, 17);
        expect(month.style!.fontWeight, FontWeight.w600);
        expectContrast(month.style!.color!, colors.accentFill);
        final day = find.byKey(const ValueKey('date-day-11'));
        await tester.ensureVisible(day);
        expect(tester.getSize(day).height, greaterThanOrEqualTo(60));
        final weekday = tester
            .widgetList<Text>(
              find.descendant(of: day, matching: find.byType(Text)),
            )
            .first;
        expect(weekday.style!.fontSize, 11);
        expectContrast(weekday.style!.color!, colors.accentFill);
        await tester.tap(find.byKey(const ValueKey('date-month-12')));
        await tester.pumpAndSettle();
        expect(value.day, isNull);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('onboarding year slide and selected-day strip use board timing',
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
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 900));
    final scroll = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const ValueKey('onboarding-day-strip')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scroll.position.pixels, greaterThan(0));
    await tester.tap(find.byTooltip('Next year'));
    await tester.pump();
    final switcher = tester.widget<AnimatedSwitcher>(
      find.byKey(const ValueKey('onboarding-year-motion')),
    );
    expect(switcher.duration, const Duration(milliseconds: 320));
    await tester.pumpAndSettle();
    expect(value.year, 2027);
  });

  testWidgets('the chosen-day note keeps its default and accepts a caller note',
      (tester) async {
    Future<void> pumpPicker({String Function(DateTime)? dayNote}) async {
      await pumpAccessibilitySurface(
        tester,
        SingleChildScrollView(
          child: MonthFirstDatePicker.onboarding(
            value: const MonthFirstDate(year: 2026, month: 11, day: 11),
            today: DateTime(2026, 10, 3),
            onChanged: (_) {},
            dayNote: dayNote,
          ),
        ),
        disableAnimations: true,
        viewportSize: const Size(390, 844),
      );
      await tester.pumpAndSettle();
    }

    await pumpPicker();
    expect(find.text('Wednesday, November 11'), findsOneWidget);
    await pumpPicker(dayNote: (day) => 'Note for ${day.day}');
    expect(find.text('Note for 11'), findsOneWidget);
    expect(find.text('Wednesday, November 11'), findsNothing);
  });
}
