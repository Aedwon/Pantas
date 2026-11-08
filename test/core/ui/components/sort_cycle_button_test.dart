import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final order in SortCycleOrder.values) {
      testWidgets('sort $order metrics and keyboard in $brightness',
          (tester) async {
        SortCycleOrder? result;
        final widget =
            SortCycleButton(value: order, onChanged: (next) => result = next);
        await pumpAccessibilitySurface(
          tester,
          widget,
          brightness: brightness,
          disableAnimations: true,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('sort-square'))),
          const Size(36, 36),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(result, SortCycleOrder.values[(order.index + 1) % 3]);
        final surface = tester
            .widget<DecoratedBox>(find.byKey(const ValueKey('sort-square')))
            .decoration as BoxDecoration;
        final alphabet = tester.widget<Text>(find.text('A–Z'));
        expect(alphabet.style!.fontSize, 13);
        expect(alphabet.style!.fontWeight, FontWeight.w700);
        expect(alphabet.style!.height, 1.35);
        final luminances = [
          alphabet.style!.color!.computeLuminance(),
          surface.color!.computeLuminance(),
        ]..sort();
        expect(
          (luminances.last + .05) / (luminances.first + .05),
          greaterThanOrEqualTo(4.5),
        );
        if (order != SortCycleOrder.alphabetical) {
          expect(
            tester.getSize(find.byKey(const ValueKey('sort-bar-0'))).width,
            order == SortCycleOrder.weakest ? 6 : 14,
          );
          expect(
            tester.getSize(find.byKey(const ValueKey('sort-bar-1'))),
            const Size(10, 2.4),
          );
        }
        await expectSurvivesTextScale(
          tester,
          widget,
          viewportSize: const Size(390, 844),
          brightness: brightness,
          disableAnimations: true,
        );
      });
    }
    testWidgets('sort morph at 260ms and delayed alphabet in $brightness',
        (tester) async {
      var order = SortCycleOrder.weakest;
      late StateSetter change;
      await pumpAccessibilitySurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            change = setState;
            return SortCycleButton(
              value: order,
              onChanged: (next) => setState(() => order = next),
            );
          },
        ),
        brightness: brightness,
      );
      change(() => order = SortCycleOrder.strongest);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 260));
      // House CSS curve at half time is .942275, giving 13.5382px.
      expect(
        tester.getSize(find.byKey(const ValueKey('sort-bar-0'))).width,
        closeTo(13.5382, .01),
      );
      await tester.pump(const Duration(milliseconds: 260));
      expect(
        tester.getSize(find.byKey(const ValueKey('sort-bar-0'))).width,
        14,
      );
      change(() => order = SortCycleOrder.alphabetical);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const ValueKey('sort-alphabet-opacity')),
            )
            .opacity,
        0,
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        tester
            .widget<Opacity>(
              find.byKey(const ValueKey('sort-alphabet-opacity')),
            )
            .opacity,
        1,
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }

  dsMatrix(
    'the sort button is a 44 px target on a 36 px square, radius-sm',
    (context) => SortCycleButton(
      value: SortCycleOrder.weakest,
      onChanged: (_) {},
    ),
    check: (tester, cell) async {
      final colors = cell.dark ? PantasColors.dark : PantasColors.light;
      expect(
        tester.getSize(find.byKey(const ValueKey('sort-square'))),
        const Size(36, 36),
      );
      expect(
        tester.getSize(find.byType(SortCycleButton)).height,
        greaterThanOrEqualTo(44),
      );
      final box = tester
          .widget<DecoratedBox>(find.byKey(const ValueKey('sort-square')))
          .decoration as BoxDecoration;
      expect(box.color, colors.fill);
      expect(box.borderRadius, BorderRadius.circular(8));
    },
  );

  testWidgets('keyboard focus rings the sort button, pressing scales it',
      (tester) async {
    resetWebKeyboardFocus();
    await pumpDs(
      tester,
      dsCells[4],
      SortCycleButton(value: SortCycleOrder.weakest, onChanged: (_) {}),
    );
    expect(find.byKey(const ValueKey('focus-ring')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.byKey(const ValueKey('focus-ring')), findsOneWidget);
    final press = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('sort-square'))),
    );
    await tester.pump();
    await tester.pump(PantasDurations.short1 * 2);
    // The shared PressScale shrinks it to .97 (Button README, Pressed).
    expect(
      tester
          .widget<Transform>(
            find
                .ancestor(
                  of: find.byKey(const ValueKey('sort-square')),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .storage[0],
      closeTo(.97, .001),
    );
    await press.up();
    await tester.pumpAndSettle();
  });
}
