import 'dart:ui' show SemanticsRole, Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

import '../../../helpers/ds_matrix.dart';

// Wednesday, October 7, 2026. The strip runs Sunday October 4 to Saturday
// October 10 (the app's week starts on Sunday).
final _today = DateTime(2026, 10, 7);
const _states = [
  WeekDayState.done,
  WeekDayState.partial,
  WeekDayState.missed,
  WeekDayState.today,
  WeekDayState.dayOff,
  WeekDayState.plain,
  WeekDayState.plain,
];

class _Host extends StatefulWidget {
  const _Host({this.log, this.width = 358, this.start});
  final List<DateTime>? log;
  final double width;
  final DateTime? start;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late DateTime? _selected = widget.start ?? _today;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeekStrip(
              today: _today,
              states: _states,
              todayFraction: .5,
              selectedDate: _selected,
              onSelected: (date) {
                widget.log?.add(date);
                setState(() => _selected = date);
              },
            ),
            TextButton(onPressed: () {}, child: const Text('After')),
          ],
        ),
      );
}

DateTime _day(int i) => DateTime(2026, 10, 4 + i);

/// The index of the day with focus, 7 for the control after the strip.
int? _focusedDay(WidgetTester tester) {
  final focus = FocusManager.instance.primaryFocus;
  if (focus?.context == null) return null;
  final at = find.byElementPredicate((e) => e == focus!.context);
  for (var i = 0; i < 7; i++) {
    final day = find.byKey(ValueKey('week-day-$i'));
    if (find.descendant(of: day, matching: at).evaluate().isNotEmpty ||
        find.ancestor(of: at, matching: day).evaluate().isNotEmpty) {
      return i;
    }
  }
  final after = find.byType(TextButton);
  if (find.ancestor(of: at, matching: after).evaluate().isNotEmpty ||
      find.descendant(of: after, matching: at).evaluate().isNotEmpty) {
    return 7;
  }
  return null;
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  // The first frame starts a scroll animation; the second runs it out.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(loadDsFonts);
  tearDown(resetWebKeyboardFocus);

  for (final cell in dsCells) {
    testWidgets('week strip keys: Tab, arrows, Home and End ($cell)',
        (tester) async {
      final log = <DateTime>[];
      await pumpDs(tester, cell, _Host(log: log));
      expect(tester.takeException(), isNull);

      // Tab reaches the selected day (Wednesday) and nothing else.
      await _press(tester, LogicalKeyboardKey.tab);
      expect(_focusedDay(tester), 3);
      await _press(tester, LogicalKeyboardKey.tab);
      expect(_focusedDay(tester), 7);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await _press(tester, LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(_focusedDay(tester), 3);

      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(log.last, _day(4));
      expect(_focusedDay(tester), 4);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      expect(log.last, _day(2));
      expect(_focusedDay(tester), 2);

      // Home and End select the first and the last day shown.
      await _press(tester, LogicalKeyboardKey.end);
      expect(log.last, _day(6));
      expect(_focusedDay(tester), 6);
      // The strip does not wrap.
      final count = log.length;
      await _press(tester, LogicalKeyboardKey.arrowRight);
      expect(log.length, count);
      expect(_focusedDay(tester), 6);
      await _press(tester, LogicalKeyboardKey.home);
      expect(log.last, _day(0));
      expect(_focusedDay(tester), 0);
      await _press(tester, LogicalKeyboardKey.arrowLeft);
      expect(_focusedDay(tester), 0);

      // The chosen day is now the one Tab stop.
      await _press(tester, LogicalKeyboardKey.tab);
      expect(_focusedDay(tester), 7);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await _press(tester, LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(_focusedDay(tester), 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('End scrolls the last day into view when the strip scrolls',
      (tester) async {
    await pumpDs(tester, dsCells.first, const _Host(width: 300));
    await _press(tester, LogicalKeyboardKey.tab);
    await _press(tester, LogicalKeyboardKey.end);
    final strip = tester.getRect(find.byType(WeekStrip));
    final last = tester.getRect(find.byKey(const ValueKey('week-day-6')));
    expect(last.right, lessThanOrEqualTo(strip.right + .5));
    await _press(tester, LogicalKeyboardKey.home);
    final first = tester.getRect(find.byKey(const ValueKey('week-day-0')));
    expect(first.left, greaterThanOrEqualTo(strip.left - .5));
  });

  testWidgets('with no day selected in this week Tab reaches Today',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      _Host(start: DateTime(2026, 9)),
    );
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focusedDay(tester), 3);
  });

  testWidgets('days are tabs with a selected state and full-date names',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, dsCells.first, const _Host());
    final done = tester.getSemantics(
      find.bySemanticsLabel('Sunday, October 4, done'),
    );
    expect(done.role, SemanticsRole.tab);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Wednesday, October 7, today'))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(done.flagsCollection.isSelected, Tristate.isFalse);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Thursday, October 8')),
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  group('tooltip', () {
    Finder tip(String text) => find.text(text);

    Future<TestGesture> mouseAt(WidgetTester tester) async {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: const Offset(5, 600));
      return mouse;
    }

    Offset center(WidgetTester tester, int i) =>
        tester.getCenter(find.byKey(ValueKey('week-day-$i')));

    testWidgets('the pointer crosses the bridge onto the tooltip and it stays',
        (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      final mouse = await mouseAt(tester);
      await mouse.moveTo(center(tester, 0));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tip('Done'), findsNothing);
      await tester.pump(PantasDurations.tooltip);
      await tester.pump(PantasDurations.short2);
      expect(tip('Done'), findsOneWidget);
      final strip = tester.getRect(find.byType(WeekStrip));
      final box = tester.getRect(
        find
            .ancestor(of: tip('Done'), matching: find.byType(DecoratedBox))
            .first,
      );
      // 8 points above the strip, inside it sideways.
      expect(strip.top - box.bottom, closeTo(8, .01));
      expect(box.left, greaterThanOrEqualTo(strip.left - .01));
      // Walk up through the bridge onto the tooltip.
      var at = center(tester, 0);
      for (final y in [strip.top + 2, strip.top - 2, strip.top - 6]) {
        at = Offset(at.dx, y);
        await mouse.moveTo(at);
        await tester.pump(PantasDurations.short2);
        expect(tip('Done'), findsOneWidget);
      }
      await mouse.moveTo(box.center);
      await tester.pump(PantasDurations.tooltip * 4);
      expect(tip('Done'), findsOneWidget);
      // Leaving the strip and the tooltip hides it.
      await mouse.moveTo(const Offset(5, 600));
      await tester.pump(PantasDurations.short2);
      await tester.pump(PantasDurations.short2);
      expect(tip('Done'), findsNothing);
    });

    testWidgets('one tooltip follows the pointer from day to day at once',
        (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      final mouse = await mouseAt(tester);
      await mouse.moveTo(center(tester, 0));
      await tester.pump(PantasDurations.tooltip + PantasDurations.short2);
      await mouse.moveTo(center(tester, 1));
      await tester.pump(PantasDurations.short2);
      expect(tip('Done'), findsNothing);
      expect(tip('Partly done'), findsOneWidget);
      // A day with no status hides it.
      await mouse.moveTo(center(tester, 4));
      await tester.pump(PantasDurations.short2);
      await tester.pump(PantasDurations.short2);
      expect(tip('Partly done'), findsNothing);
    });

    for (final day in [0, 6]) {
      testWidgets('the tooltip over day $day stays inside the strip',
          (tester) async {
        await pumpDs(tester, dsCells.first, const _Host());
        final mouse = await mouseAt(tester);
        await mouse.moveTo(center(tester, day));
        await tester.pump(PantasDurations.tooltip + PantasDurations.short2);
        final text = day == 0 ? 'Done' : 'Planned';
        final strip = tester.getRect(find.byType(WeekStrip));
        final box = tester.getRect(
          find
              .ancestor(of: tip(text), matching: find.byType(DecoratedBox))
              .first,
        );
        expect(box.left, greaterThanOrEqualTo(strip.left - .01));
        expect(box.right, lessThanOrEqualTo(strip.right + .01));
      });
    }

    testWidgets('Esc hides it without moving focus', (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      final mouse = await mouseAt(tester);
      await mouse.moveTo(center(tester, 0));
      await tester.pump(PantasDurations.tooltip + PantasDurations.short2);
      expect(tip('Done'), findsOneWidget);
      await _press(tester, LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(tip('Done'), findsNothing);
    });

    testWidgets(
        'keyboard focus shows it at once and a pointer elsewhere '
        'does not hide it', (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(PantasDurations.short2);
      expect(tip('Today'), findsOneWidget);
      final mouse = await mouseAt(tester);
      await mouse.moveTo(center(tester, 0));
      await tester.pump(PantasDurations.short2);
      await mouse.moveTo(const Offset(5, 600));
      await tester.pump(PantasDurations.tooltip * 2);
      expect(tip('Today'), findsOneWidget);
      // Esc hides it; Tab away from the strip would too.
      await _press(tester, LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(tip('Today'), findsNothing);
    });

    testWidgets('moving focus off the strip hides the tooltip', (tester) async {
      await pumpDs(tester, dsCells.first, const _Host());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(PantasDurations.short2);
      expect(tip('Today'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(tip('Today'), findsNothing);
    });

    testWidgets('touch never shows it and it is hidden from screen readers',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, dsCells.first, const _Host());
      await tester.tap(find.byKey(const ValueKey('week-day-0')));
      await tester.longPress(find.byKey(const ValueKey('week-day-1')));
      await tester.pump(const Duration(seconds: 2));
      expect(tip('Done'), findsNothing);
      expect(tip('Partly done'), findsNothing);
      // With a pointer it shows, but the tooltip has no semantics.
      final mouse = await mouseAt(tester);
      await mouse.moveTo(center(tester, 0));
      await tester.pump(PantasDurations.tooltip + PantasDurations.short2);
      expect(tip('Done'), findsOneWidget);
      expect(find.bySemanticsLabel('Done'), findsNothing);
      handle.dispose();
    });
  });
}
