import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('past dates stay inactive and photo renders $brightness',
        (tester) async {
      var hits = 0;
      await pumpAccessibilitySurface(
        tester,
        MonthFirstDatePicker(
          value: const MonthFirstDate(year: 2028, month: 2),
          today: DateTime(2028, 2, 23),
          onChanged: (_) => hits++,
        ),
        brightness: brightness,
      );
      final past = find.byKey(const ValueKey('date-day-22'));
      expect(tester.widget<TextButton>(past).onPressed, isNull);
      final month = find.byKey(const ValueKey('date-month-1'));
      expect(tester.widget<TextButton>(month).onPressed, isNull);
      expect(hits, 0);
      final photo = MemoryImage(
        base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
            'AAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg=='),
      );
      await pumpAccessibilitySurface(
        tester,
        Avatar(name: 'Ada', photo: photo),
        brightness: brightness,
      );
      expect(tester.widget<Image>(find.byType(Image)).image, same(photo));
    });
    testWidgets('wheel invalid strike, board metrics and keyboard $brightness',
        (tester) async {
      var selected = 1;
      final wheel = StatefulBuilder(
        builder: (context, setState) => ValueWheel(
          values: const ['5', '10', '15'],
          selectedIndex: selected,
          invalidIndices: const {0},
          label: 'Questions',
          onSelected: (i) => setState(() => selected = i),
        ),
      );
      await pumpAccessibilitySurface(tester, wheel, brightness: brightness);
      final invalid = tester.widget<Text>(find.text('5'));
      expect(invalid.style!.decoration, TextDecoration.lineThrough);
      expect(invalid.style!.fontSize, 20);
      final selectedText = tester.widget<Text>(find.text('10'));
      expect(selectedText.style!.fontWeight, FontWeight.w500);
      expect(selectedText.style!.height, 1.35);
      expectContrast(
        selectedText.style!.color!,
        brightness == Brightness.light ? const Color(0xFFF5F5F7) : Colors.black,
      );
      expect(tester.getSize(find.byType(ValueWheel)).height, 180);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(selected, 2);
      await expectSurvivesTextScale(
        tester,
        wheel,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
    testWidgets(
        'date today, past, month-only, leap and unlimited year $brightness',
        (tester) async {
      var selected = const MonthFirstDate(year: 2028, month: 2);
      final picker = StatefulBuilder(
        builder: (context, setState) => MonthFirstDatePicker(
          value: selected,
          today: DateTime(2028, 2, 20),
          onChanged: (d) => setState(() => selected = d),
        ),
      );
      await pumpAccessibilitySurface(
        tester,
        picker,
        brightness: brightness,
        viewportSize: const Size(390, 844),
      );
      expect(find.text('Today'), findsOneWidget);
      expect(find.byKey(const ValueKey('date-day-29')), findsOneWidget);
      expect(find.byKey(const ValueKey('date-day-30')), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('date-day-29')));
      await tester.tap(find.byKey(const ValueKey('date-day-29')));
      await tester.pump();
      expect(selected.day, 29);
      await tester.tap(find.byKey(const ValueKey('date-month-3')));
      await tester.pump();
      expect(selected.day, isNull);
      expect(selected.month, 3);
      await expectSurvivesTextScale(
        tester,
        picker,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      selected = const MonthFirstDate(year: 10000, month: 2);
      await pumpAccessibilitySurface(
        tester,
        MonthFirstDatePicker(
          value: selected,
          today: DateTime(2026, 10, 11),
          onChanged: (d) => selected = d,
        ),
        brightness: brightness,
      );
      await tester.tap(find.byTooltip('Next year'));
      expect(selected.year, 10001);
      await pumpAccessibilitySurface(
        tester,
        MonthFirstDatePicker(
          value: const MonthFirstDate(year: 2027, month: 2),
          today: DateTime(2027, 2, 20),
          onChanged: (d) {},
        ),
        brightness: brightness,
      );
      expect(find.byKey(const ValueKey('date-day-29')), findsNothing);
    });
    testWidgets('scope marks, last-item shake and keyboard $brightness',
        (tester) async {
      var selection = {'l1'};
      var changes = 0;
      final picker = StatefulBuilder(
        builder: (context, setState) => ScopePicker(
          subjects: const [
            ScopeSubject(
              title: 'Math',
              topics: [
                ScopeTopic(
                  id: 'algebra',
                  title: 'Algebra',
                  lessons: [
                    ScopeLesson(id: 'l1', title: 'Equations'),
                    ScopeLesson(
                      id: 'l2',
                      title: 'Polynomials',
                      unread: true,
                    ),
                  ],
                ),
                ScopeTopic(
                  id: 'empty',
                  title: 'Geometry',
                  hasQuestions: false,
                ),
              ],
            ),
          ],
          selectedIds: selection,
          onChanged: (v) => setState(() {
            changes++;
            selection = v;
          }),
        ),
      );
      await pumpAccessibilitySurface(tester, picker, brightness: brightness);
      expect(
        find.byKey(const ValueKey('scope-partial-algebra')),
        findsOneWidget,
      );
      expect(find.text('No questions yet'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('scope-expand-algebra')));
      await tester.pumpAndSettle();
      expect(find.text('Unread'), findsOneWidget);
      final unread = tester.widget<Text>(find.text('Unread'));
      expect(unread.style!.fontSize, 13);
      expect(unread.style!.fontWeight, FontWeight.w500);
      expectContrast(
        unread.style!.color!,
        brightness == Brightness.light
            ? const Color(0xFFFBFBFC)
            : const Color(0xFF18181A),
      );
      await tester.tap(find.byKey(const ValueKey('scope-select-l1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final transform = tester
          .widget<Transform>(find.byKey(const ValueKey('scope-shake-l1')));
      expect(transform.transform.storage[12], closeTo(-5, .01));
      expect(selection, {'l1'});
      expect(changes, 0);
      await tester.pumpWidget(const SizedBox());
      await pumpAccessibilitySurface(tester, picker, brightness: brightness);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(selection, {'l1', 'l2'});
      expect(changes, 1);
      await expectSurvivesTextScale(
        tester,
        picker,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
    testWidgets('search focus, cancel and approved placeholder $brightness',
        (tester) async {
      var value = '';
      final field = SearchField(
        title: 'Study',
        hint: 'Lessons, topics',
        onChanged: (v) => value = v,
      );
      await pumpAccessibilitySurface(tester, field, brightness: brightness);
      expect(
        tester
            .widget<TextField>(find.byType(TextField))
            .decoration!
            .hintStyle!
            .color,
        const Color(0xFF8E8E93),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('search-fill'))).height,
        38,
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final titleAlign = find
          .ancestor(of: find.text('Study'), matching: find.byType(Align))
          .first;
      expect(
        tester.widget<Align>(titleAlign).heightFactor,
        closeTo(.057725, .002),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Cancel').hitTestable(), findsOneWidget);
      expect(find.text('Study').hitTestable(), findsNothing);
      await tester.enterText(find.byType(TextField), 'math');
      expect(value, 'math');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(value, '');
      expect(find.text('Study').hitTestable(), findsOneWidget);
      await expectSurvivesTextScale(
        tester,
        field,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
    testWidgets(
        'avatar photo, name, emoji grapheme, fallback and scaling $brightness',
        (tester) async {
      for (final name in ['Ada', '👩🏽‍🔬 Scientist', '']) {
        final avatar = Avatar(name: name);
        await pumpAccessibilitySurface(tester, avatar, brightness: brightness);
        expect(tester.getSize(find.byType(Avatar)), const Size(58, 58));
        if (name == 'Ada') {
          expect(tester.widget<Text>(find.text('A')).style!.fontSize, 25);
        }
        if (name.startsWith('👩')) expect(find.text('👩🏽‍🔬'), findsOneWidget);
        if (name.isEmpty) expect(find.byType(Icon), findsOneWidget);
        await expectSurvivesTextScale(
          tester,
          avatar,
          brightness: brightness,
          disableAnimations: true,
        );
      }
    });
  }
}
