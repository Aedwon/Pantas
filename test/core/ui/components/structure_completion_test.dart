import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'all row variants, board metrics, stacking and keyboard $brightness',
        (tester) async {
      var hits = 0;
      for (final variant in ListRowVariant.values) {
        final row = ListRow(
          title: 'A very long row title that must stay on one line',
          value: 'November 2026',
          variant: variant,
          selected: true,
          onTap: () => hits++,
          editor: const Text('Year wheel'),
        );
        await pumpAccessibilitySurface(tester, row, brightness: brightness);
        final title = tester.widget<Text>(
          find.text('A very long row title that must stay on one line'),
        );
        expect(title.maxLines, 1);
        expect(title.overflow, TextOverflow.ellipsis);
        expect(title.style!.fontSize, 17);
        expect(title.style!.height, 1.35);
        if (variant != ListRowVariant.destructive ||
            brightness == Brightness.light) {
          expectContrast(
            title.style!.color!,
            brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF1C1C1E),
          );
        }
        expect(
          tester.getSize(find.byType(ListRow)).height,
          greaterThanOrEqualTo(44),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(hits, greaterThan(0));
        await expectSurvivesTextScale(
          tester,
          row,
          viewportSize: const Size(390, 844),
          brightness: brightness,
          disableAnimations: true,
        );
        if (variant == ListRowVariant.value) {
          expect(
            tester.getTopLeft(find.text('November 2026')).dy,
            greaterThan(
              tester
                  .getTopLeft(
                    find.text(
                      'A very long row title that must stay on one line',
                    ),
                  )
                  .dy,
            ),
          );
        }
      }
    });
    testWidgets('button variants and states, pairs order $brightness',
        (tester) async {
      var hits = 0;
      for (final variant in PantasButtonVariant.values) {
        for (final busy in [false, true]) {
          final button = PantasButton(
            label: busy ? 'Saving' : 'Save',
            variant: variant,
            busy: busy,
            onPressed: () => hits++,
          );
          await pumpAccessibilitySurface(
            tester,
            button,
            brightness: brightness,
          );
          expect(tester.getSize(find.byType(PantasButton)).height, 52);
          final text = tester.widget<Text>(find.text(busy ? 'Saving' : 'Save'));
          expect(text.style!.fontSize, 17);
          expect(text.style!.fontWeight, FontWeight.w600);
          final buttonStyle =
              tester.widget<TextButton>(find.byType(TextButton)).style!;
          final bg = buttonStyle.backgroundColor!.resolve({})!;
          expectContrast(
            text.style!.color!,
            bg.a == 0
                ? (brightness == Brightness.light
                    ? const Color(0xFFF5F5F7)
                    : Colors.black)
                : bg,
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          if (!busy) expect(hits, greaterThan(0));
          await expectSurvivesTextScale(
            tester,
            button,
            viewportSize: const Size(390, 844),
            brightness: brightness,
            disableAnimations: true,
          );
        }
      }
      await pumpAccessibilitySurface(
        tester,
        const PantasButton(label: 'Save'),
        brightness: brightness,
      );
      expect(
        tester.widget<Text>(find.text('Save')).style!.color,
        brightness == Brightness.light
            ? const Color(0xFFAEAEB2)
            : const Color(0xFF5A5A5E),
      );
      for (final stacked in [true, false]) {
        await pumpAccessibilitySurface(
          tester,
          ButtonPair(
            primary: PantasButton(label: 'Save', onPressed: () {}),
            secondary: PantasButton(
              label: 'Cancel',
              variant: PantasButtonVariant.secondary,
              onPressed: () {},
            ),
            stacked: stacked,
          ),
          brightness: brightness,
        );
        if (stacked) {
          expect(
            tester.getTopLeft(find.text('Save')).dy,
            lessThan(tester.getTopLeft(find.text('Cancel')).dy),
          );
        } else {
          expect(
            tester.getTopLeft(find.text('Save')).dx,
            greaterThan(tester.getTopLeft(find.text('Cancel')).dx),
          );
        }
      }
    });
    testWidgets(
        'large page title scrolls away without collapsed copy $brightness',
        (tester) async {
      final page = PantasPage(
        title: 'Settings',
        backLabel: 'Home',
        onBack: () {},
        children: List.generate(
          30,
          (i) => SizedBox(height: 60, child: Text('Row $i')),
        ),
      );
      await pumpAccessibilitySurface(
        tester,
        page,
        brightness: brightness,
        viewportSize: const Size(390, 844),
      );
      final style = tester.widget<Text>(find.text('Settings')).style!;
      expect(style.fontSize, 34);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.height, 1.12);
      await tester.drag(find.text('Row 5'), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Settings').hitTestable(), findsNothing);
      expect(find.text('Settings'), findsOneWidget);
      await expectSurvivesTextScale(
        tester,
        page,
        viewportSize: const Size(390, 844),
        brightness: brightness,
        disableAnimations: true,
      );
    });
  }
}
