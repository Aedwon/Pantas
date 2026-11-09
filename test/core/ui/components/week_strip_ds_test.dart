import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/line_breaks.dart';

WeekStrip _strip({DateTime? selected, ValueChanged<DateTime>? onSelected}) =>
    WeekStrip(
      today: DateTime(2026, 10, 7),
      states: const [
        WeekDayState.done,
        WeekDayState.partial,
        WeekDayState.missed,
        WeekDayState.today,
        WeekDayState.dayOff,
        WeekDayState.plain,
        WeekDayState.plain,
      ],
      todayFraction: .5,
      selectedDate: selected,
      onSelected: onSelected ?? (_) {},
    );

void main() {
  setUpAll(loadDsFonts);

  dsMatrix(
    'week strip: 44 columns, shrinking gap, Today disc, no overflow',
    (context) => SizedBox(width: 358, child: _strip()),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final wide = cell.width >= 1024;
      final days = [
        for (var i = 0; i < 7; i++)
          tester.getRect(find.byKey(ValueKey('week-day-$i'))),
      ];
      if (cell.scale == 1) {
        for (final day in days) {
          expect(day.width, closeTo(44, .001));
        }
        // The gap shrinks from 10 toward 4: 358 leaves (358 - 308) / 6.
        for (var i = 1; i < 7; i++) {
          expect(days[i].left - days[i - 1].right, closeTo(50 / 6, .01));
        }
      } else {
        // At 2.0 the column is Today's ring grown by 1.7 (the text beyond
        // 1.3x) plus 4 clear on each side: 34 x 1.7 + 8. Seven do not fit in
        // 358, so the gap is the 4 minimum and the strip scrolls.
        for (final day in days) {
          expect(day.width, closeTo(34 * 1.7 + 8, .01));
        }
        for (var i = 1; i < 7; i++) {
          expect(days[i].left - days[i - 1].right, closeTo(4, .01));
        }
      }
      // Today: accent weekday at 700, number on an accent-fill disc.
      final weekday = tester.widget<Text>(find.text('Wed'));
      expect(weekday.style!.color, palette.accent);
      expect(weekday.style!.fontWeight, FontWeight.w700);
      expect(weekday.style!.fontSize, wide ? 11 : 10);
      final digit = tester.widget<Text>(find.text('7'));
      expect(digit.style!.color, palette.onAccent);
      expect(digit.style!.fontWeight, FontWeight.w700);
      // A past day with no study is secondary and never red.
      final off = tester.widget<Text>(find.text('Thu'));
      expect(off.style!.color, palette.textSecondary);
      expect(off.style!.fontWeight, FontWeight.w400);
    },
  );

  testWidgets('under 332 px the strip scrolls sideways', (tester) async {
    await pumpDs(tester, dsCells.first, SizedBox(width: 300, child: _strip()));
    final scroller = find.descendant(
      of: find.byType(WeekStrip),
      matching: find.byType(SingleChildScrollView),
    );
    final before = tester.getRect(find.byKey(const ValueKey('week-day-6')));
    expect(before.width, closeTo(44, .001));
    expect(tester.takeException(), isNull);
    await tester.drag(scroller, const Offset(-60, 0));
    await tester.pump();
    final after = tester.getRect(find.byKey(const ValueKey('week-day-6')));
    expect(after.left, lessThan(before.left));
  });

  testWidgets('a selected day has a 2 px accent ring', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      SizedBox(width: 358, child: _strip(selected: DateTime(2026, 10, 4))),
    );
    final cell = find.descendant(
      of: find.byKey(const ValueKey('week-day-0')),
      matching: find.byType(Container),
    );
    final deco = tester.widget<Container>(cell.first).foregroundDecoration!
        as BoxDecoration;
    final border = deco.border! as Border;
    expect(border.top.width, 2);
    expect(border.top.color, PantasColors.light.accent);
  });

  testWidgets('the status tooltip shows after 500 ms of hover, not before',
      (tester) async {
    await pumpDs(
      tester,
      dsCells[4],
      SizedBox(width: 358, child: _strip()),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse
        .moveTo(tester.getCenter(find.byKey(const ValueKey('week-day-0'))));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Done'), findsNothing);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Done'), findsOneWidget);
    // Today always shows "Today".
    await mouse
        .moveTo(tester.getCenter(find.byKey(const ValueKey('week-day-3'))));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Today'), findsOneWidget);
    // The accessible name ends with the status, so the tooltip adds nothing.
    final handle = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel('Sunday, October 4, done'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('no tooltip on a day with no status', (tester) async {
    await pumpDs(tester, dsCells[4], SizedBox(width: 358, child: _strip()));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse
        .moveTo(tester.getCenter(find.byKey(const ValueKey('week-day-4'))));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(Tooltip), findsWidgets);
    expect(find.text('Planned'), findsNothing);
    expect(find.text('No study'), findsNothing);
  });

  for (final cell in const [
    DsCell(390, 2, dark: false),
    DsCell(390, 2, dark: true),
  ]) {
    testWidgets('at 200% Today keeps its ring and number whole ($cell)',
        (tester) async {
      await pumpDs(tester, cell, SizedBox(width: 358, child: _strip()));
      expect(tester.takeException(), isNull);
      final day = tester.getRect(find.byKey(const ValueKey('week-day-3')));
      final ring = tester.getRect(find.byType(ProgressRing));
      // The ring sits inside its column with room on both sides.
      expect(ring.left, greaterThanOrEqualTo(day.left));
      expect(ring.right, lessThanOrEqualTo(day.right));
      // The number is not squeezed by the disc.
      final digit = tester.getRect(find.text('7'));
      expect(digit.height, lessThanOrEqualTo(ring.height - 8));
      // The weekday does not split and does not touch the number.
      for (final label in ['Sun', 'Wed', 'Thu']) {
        expect(splitsAWord(tester, find.text(label)), isFalse);
      }
      final weekday = tester.getRect(find.text('Wed'));
      expect(weekday.bottom, lessThanOrEqualTo(digit.top));
    });
  }

  for (final scale in [1.2, 1.3]) {
    testWidgets('on a 390 phone the strip keeps 44 cells and fits at $scale',
        (tester) async {
      await pumpDs(
        tester,
        DsCell(390, scale, dark: false),
        SizedBox(width: 358, child: _strip()),
      );
      for (var i = 0; i < 7; i++) {
        expect(
          tester.getRect(find.byKey(ValueKey('week-day-$i'))).width,
          closeTo(44, .001),
        );
      }
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(WeekStrip),
          matching: find.byType(Scrollable),
        ),
      );
      expect(scrollable.position.maxScrollExtent, 0);
    });
  }
}
