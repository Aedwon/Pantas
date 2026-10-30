import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  testWidgets(
      'controlled vertical wheel does not echo a selection during build',
      (tester) async {
    var selected = 1;
    var callbacks = 0;
    late StateSetter update;
    await pumpAccessibilitySurface(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return ValueWheel(
            values: const ['One', 'Two', 'Three'],
            selectedIndex: selected,
            label: 'Value',
            onSelected: (index) {
              callbacks++;
              setState(() => selected = index);
            },
          );
        },
      ),
    );
    update(() => selected = 2);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(callbacks, 0);
  });

  testWidgets(
      'checkbox keyboard activation announces selection and pops the mark',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      var selected = false;
      await pumpAccessibilitySurface(
        tester,
        StatefulBuilder(
          builder: (context, update) => ListRow.checkbox(
            title: 'Consent',
            selected: selected,
            onTap: () => update(() => selected = !selected),
          ),
        ),
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Consent'))
            .flagsCollection
            .isChecked,
        CheckedState.isFalse,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selected, isTrue);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Consent'))
            .flagsCollection
            .isChecked,
        CheckedState.isTrue,
      );
      final mark = find.byKey(const ValueKey('selection-mark'));
      final transform =
          find.descendant(of: mark, matching: find.byType(Transform));
      expect(tester.widget<Transform>(transform).transform.storage[0], .5);
      await tester.pump(const Duration(milliseconds: 110));
      expect(
        tester.widget<Transform>(transform).transform.storage[0],
        closeTo(.5 + .5 * PantasCurves.popB.transform(.5), .002),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.widget<Transform>(transform).transform.storage[0], 1);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('vertical keyboard selection emits one change', (tester) async {
    final picks = <int>[];
    await pumpAccessibilitySurface(
      tester,
      ValueWheel.birthYear(
        values: const ['2011', '2012', '2013'],
        selectedIndex: 1,
        label: 'Birth year',
        onSelected: picks.add,
      ),
    );
    Focus.of(
      tester.element(find.byType(ListWheelScrollView)),
      createDependency: false,
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(picks, [2]);
  });

  testWidgets('selected consent mark paints the O_Consent check stroke',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      Builder(
        builder: (context) => ColoredBox(
          color: context.colors.surface,
          child:
              ListRow.checkbox(title: 'Consent', selected: true, onTap: () {}),
        ),
      ),
      disableAnimations: true,
    );
    final colors = tester.element(find.byType(ListRow)).colors;
    expect(
      find.byKey(const ValueKey('selection-mark')),
      paints
        ..path(
          color: colors.onAccent,
          strokeWidth: 2,
          style: PaintingStyle.stroke,
        ),
    );
    expectContrast(colors.onAccent, colors.accentFill, minimum: 3);
    expect(
      tester.getSize(
        find.descendant(
          of: find.byKey(const ValueKey('selection-mark')),
          matching: find.byType(CustomPaint),
        ),
      ),
      const Size(16, 16),
    );
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('onboarding page metrics $brightness $scale', (tester) async {
        await pumpAccessibilitySurface(
          tester,
          PantasPage.onboarding(
            title: 'When were you born?',
            detail: 'We only ask this once and never keep it.',
            progress: 1,
            onBack: () {},
            children: const [Text('Body')],
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final title = tester.widget<Text>(find.text('When were you born?'));
        expect(title.style!.fontSize, 30);
        expect(title.style!.fontWeight, FontWeight.w700);
        expect(title.style!.height, 1.12);
        expect(title.style!.letterSpacing, -.66);
        expect(tester.getTopLeft(find.text('When were you born?')).dx, 20);
        expect(tester.getTopLeft(find.text('When were you born?')).dy, 60);
        final segments = find.byKey(
          const ValueKey('onboarding-segment'),
          skipOffstage: false,
        );
        expect(segments, findsNWidgets(6));
        expect(tester.getSize(segments.first).height, 4);
        final boxes = tester.widgetList<DecoratedBox>(segments).toList();
        final first = boxes.first.decoration as BoxDecoration;
        final second = boxes[1].decoration as BoxDecoration;
        expect(first.borderRadius, BorderRadius.circular(9));
        final bg = tester
            .widget<Scaffold>(find.byType(Scaffold).last)
            .backgroundColor!;
        expectContrast(first.color!, bg, minimum: 3);
        expect(first.color, isNot(second.color));
        expect(tester.takeException(), isNull);
      });

      testWidgets('birth year wheel follows O_Age $brightness $scale',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          Builder(
            builder: (context) => ColoredBox(
              color: context.colors.surface,
              child: ValueWheel.birthYear(
                values: const [
                  '2009',
                  '2010',
                  '2011',
                  '2012',
                  '2013',
                  '2014',
                  '2015',
                ],
                selectedIndex: 3,
                onSelected: (_) {},
                label: 'Birth year',
              ),
            ),
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final selected = tester.widget<Text>(find.text('2012'));
        expect(selected.style!.fontSize, 22);
        expect(selected.style!.fontWeight, FontWeight.w600);
        expect(selected.style!.height, 1.35);
        expect(selected.style!.letterSpacing, -.264);
        expect(
          selected.style!.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
        final neighbor = tester.widget<Text>(find.text('2011'));
        expect(neighbor.style!.fontSize, 19);
        expect(neighbor.style!.fontWeight, FontWeight.w400);
        expect(
          tester
              .widget<ListWheelScrollView>(find.byType(ListWheelScrollView))
              .itemExtent,
          scale == 1 ? 44 : 73.4,
        );
        final selection = tester
            .widget<Container>(find.byKey(const ValueKey('wheel-selection')));
        final selectedBg = (selection.decoration! as BoxDecoration).color!;
        expectContrast(selected.style!.color!, selectedBg);
        final colors = tester.element(find.byType(ValueWheel)).colors;
        expectContrast(neighbor.style!.color!, colors.surface);
        expectContrast(
          tester.widget<Text>(find.text('2015')).style!.color!,
          colors.surface,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('consent checkbox follows O_Consent $brightness $scale',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          Builder(
            builder: (context) => ColoredBox(
              color: context.colors.surface,
              child: ListRow.checkbox(
                title: 'Help improve Pantas by sharing anonymous usage data',
                selected: false,
                onTap: () {},
              ),
            ),
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final mark = tester
            .widget<Container>(find.byKey(const ValueKey('selection-mark')));
        expect(
          tester.getSize(find.byKey(const ValueKey('selection-mark'))),
          const Size(24, 24),
        );
        final decoration = mark.decoration! as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(7));
        expect((decoration.border! as Border).top.width, 1.5);
        final colors = tester.element(find.byType(ListRow)).colors;
        expectContrast(
          (decoration.border! as Border).top.color,
          colors.surface,
          minimum: 3,
        );
        final label = tester.widget<Text>(
          find.text('Help improve Pantas by sharing anonymous usage data'),
        );
        expect(label.maxLines, isNull);
        expect(label.style!.fontSize, 16);
        expect(label.style!.height, 1.4);
        expect(tester.takeException(), isNull);
      });

      testWidgets('blocked age metrics $brightness $scale', (tester) async {
        await pumpAccessibilitySurface(
          tester,
          const StateView.onboardingBlocked(
            message: "Pantas isn't available yet",
            detail: "Sorry, this app isn't available for users under 13.",
            icon: SizedBox(),
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final title =
            tester.widget<Text>(find.text("Pantas isn't available yet"));
        expect(title.style!.fontSize, 26);
        expect(title.style!.fontWeight, FontWeight.w700);
        expect(title.style!.height, 1.35);
        final detail = tester.widget<Text>(
          find.text("Sorry, this app isn't available for users under 13."),
        );
        expect(detail.style!.fontSize, 17);
        expect(
          tester.getSize(find.byKey(const ValueKey('state-mark'))),
          const Size(72, 72),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
