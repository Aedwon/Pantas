import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_tap_area.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/web/web_components.dart';

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
      PantasTapArea(
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

  testWidgets('a disabled quiz tap area does not wash or take a tap', (
    tester,
  ) async {
    var taps = 0;
    Widget area({required bool enabled}) => PantasTapArea(
          key: const ValueKey('area'),
          onTap: enabled ? () => taps++ : null,
          child: const SizedBox(width: 200, height: 60, child: Text('Row')),
        );
    // The counter is wired: the enabled area counts a tap.
    await pumpDs(tester, _wide, area(enabled: true));
    await tester.tap(find.byKey(const ValueKey('area')));
    expect(taps, 1);
    await pumpDs(tester, _wide, area(enabled: false));
    await expectTapAreaInert(
      tester,
      find.byKey(const ValueKey('area')),
      () => taps,
    );
    expect(taps, 1);
  });

  final disabled = <String, (Widget, Finder Function())>{
    'icon button': (
      PantasIconButton(
        tooltip: 'Close',
        glyph: PantasIcons.close,
        onPressed: null,
      ),
      () => find.byType(IconButton),
    ),
    'tertiary button': (
      const PantasButton(label: 'See more'),
      () => find.descendant(
            of: find.byType(PantasButton),
            matching: find.byType(TextButton),
          ),
    ),
    'secondary button': (
      const WebButton(
        label: 'Notes',
        kind: PantasButtonKind.secondary,
      ),
      () => find.descendant(
            of: find.byType(WebButton),
            matching: find.byType(TextButton),
          ),
    ),
  };
  for (final entry in disabled.entries) {
    testWidgets('a disabled ${entry.key} shows no hover wash and takes no tap',
        (tester) async {
      await pumpDs(tester, _wide, entry.value.$1);
      await expectDisabledInert(tester, entry.value.$2());
    });
  }

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
    expectHitArea(tester, find.byType(PantasIconButton));
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
    expectHitArea(
      tester,
      find.byType(WebTextLink),
      min: const Size(44, 16),
      reason: 'TextLink is inline; only a coarse pointer pads it to 44 '
          '(TextLink README, Accessibility)',
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
    expectHitArea(tester, find.byType(PantasButton));
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
    expectHitArea(
      tester,
      find.byType(WebButton),
      min: const Size(44, 42),
      reason: 'a small button is size-btn-sm (42) high on a fine pointer '
          '(Button README, Accessibility)',
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
    expectHitArea(
      tester,
      find.byType(WebBackLink),
      min: const Size(44, 40),
      reason: 'BackLink is size-back (40) high on a fine pointer',
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
    expectHitArea(
      tester,
      find.byType(WebButton),
      min: const Size(44, 42),
      reason: 'a small button is size-btn-sm (42) high on a fine pointer '
          '(Button README, Accessibility)',
    );
  });

  testWidgets('a number chip hovers as a circle', (tester) async {
    await pumpDs(
      tester,
      _wide,
      PantasTapArea(
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
