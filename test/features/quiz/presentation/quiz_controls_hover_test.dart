import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/quiz/presentation/quiz_tap_area.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/hover_shape.dart';

const _wide = DsCell(1440, 1, dark: false);
const _phone = DsCell(390, 1, dark: false);

void main() {
  testWidgets('a quiz tap area washes a rounded rectangle on hover', (
    tester,
  ) async {
    var taps = 0;
    await pumpDs(
      tester,
      _wide,
      QuizTapArea(
        key: const ValueKey('area'),
        onTap: () => taps++,
        borderRadius: BorderRadius.circular(PantasRadius.md),
        child: const SizedBox(width: 200, height: 60, child: Text('Row')),
      ),
    );
    final area = find.byKey(const ValueKey('area'));
    expect(
      find.descendant(of: area, matching: find.byType(DecoratedBox)),
      findsWidgets,
    );
    await hoverOver(tester, area);
    expectRoundedWash(tester, area);
    await tester.tap(area);
    expect(taps, 1);
  });

  testWidgets('a disabled quiz tap area does not wash', (tester) async {
    await pumpDs(
      tester,
      _wide,
      const QuizTapArea(
        key: ValueKey('area'),
        onTap: null,
        child: SizedBox(width: 200, height: 60, child: Text('Row')),
      ),
    );
    await hoverOver(tester, find.byKey(const ValueKey('area')));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('area')),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.position == DecorationPosition.foreground &&
              (w.decoration as BoxDecoration).color != Colors.transparent,
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('an icon button hovers as a rounded rectangle', (tester) async {
    await pumpDs(
      tester,
      _wide,
      PantasIconButton(
        tooltip: 'Close',
        glyph: PantasIcons.close,
        onPressed: () {},
      ),
    );
    final button = find.byType(IconButton);
    await hoverOver(tester, button);
    expectRoundedButtonHover(
      tester,
      button,
      tester.widget<IconButton>(button).style!,
    );
  });

  testWidgets('a text link hovers as a rounded rectangle', (tester) async {
    await pumpDs(
      tester,
      _wide,
      WebTextLink(label: 'Change', arrow: false, onPressed: () {}),
    );
    final button = find.byType(TextButton);
    await hoverOver(tester, button);
    expectRoundedButtonHover(
      tester,
      button,
      tester.widget<TextButton>(button).style!,
    );
  });

  testWidgets('a phone text button is a rounded rectangle', (tester) async {
    await pumpDs(
      tester,
      _phone,
      PantasButton(
        label: 'See more',
        kind: PantasButtonKind.tertiary,
        tone: PantasButtonTone.accent,
        fullWidth: false,
        onPressed: () {},
      ),
    );
    final button = find.byType(TextButton);
    expectRoundedButtonHover(
      tester,
      button,
      tester.widget<TextButton>(button).style!,
    );
  });

  testWidgets('a wide tertiary button hovers as a rounded rectangle', (
    tester,
  ) async {
    await pumpDs(
      tester,
      _wide,
      WebButton(
        label: 'Discard',
        kind: PantasButtonKind.tertiary,
        size: PantasButtonSize.sm,
        onPressed: () {},
      ),
    );
    final button = find.byType(TextButton);
    await hoverOver(tester, button);
    expectRoundedButtonHover(
      tester,
      button,
      tester.widget<TextButton>(button).style!,
    );
  });

  testWidgets('a notice day tile is a rounded rectangle', (tester) async {
    await pumpDs(
      tester,
      _wide,
      SizedBox(
        width: 44,
        child: SelectableTile.day(
          weekday: 'Tue',
          name: '14',
          selected: false,
          onTap: () {},
        ),
      ),
    );
    expect(find.byType(SelectableTile), findsOneWidget);
    final boxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(SelectableTile),
        matching: find.byType(DecoratedBox),
      ),
    );
    for (final box in boxes) {
      final d = box.decoration;
      if (d is BoxDecoration && d.borderRadius != null) {
        expect(d.shape, BoxShape.rectangle);
      }
    }
  });

  testWidgets('a back link hovers as a rounded rectangle', (tester) async {
    await pumpDs(
      tester,
      _wide,
      WebBackLink(label: 'Session', nudge: false, onPressed: () {}),
    );
    final button = find.byType(TextButton);
    await hoverOver(tester, button);
    expectRoundedButtonHover(
      tester,
      button,
      tester.widget<TextButton>(button).style!,
    );
  });

  testWidgets('a secondary button hovers as a rounded rectangle', (
    tester,
  ) async {
    await pumpDs(
      tester,
      _wide,
      WebButton(
        label: 'Notes',
        kind: PantasButtonKind.secondary,
        size: PantasButtonSize.sm,
        onPressed: () {},
      ),
    );
    final button = find.byType(TextButton);
    await hoverOver(tester, button);
    expectRoundedButtonHover(
      tester,
      button,
      tester.widget<TextButton>(button).style!,
    );
  });

  testWidgets('a number chip hovers as a circle', (tester) async {
    await pumpDs(
      tester,
      _wide,
      QuizTapArea(
        key: const ValueKey('chip'),
        onTap: () {},
        borderRadius: BorderRadius.circular(PantasRadius.full),
        child: const SizedBox.square(dimension: 36, child: Text('3')),
      ),
    );
    final chip = find.byKey(const ValueKey('chip'));
    await hoverOver(tester, chip);
    expectCircleWash(tester, chip);
  });
}
