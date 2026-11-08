import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_select.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

const _options = [
  PantasSelectOption('abra', 'Abra'),
  PantasSelectOption('batangas', 'Batangas'),
  PantasSelectOption('cebu', 'Cebu'),
  PantasSelectOption('davao', 'Davao'),
  PantasSelectOption('ilocos', 'Ilocos Norte'),
  PantasSelectOption('laguna', 'Laguna'),
];

Widget _select({
  String? value,
  ValueChanged<String>? onChanged,
  String? errorText,
  bool large = false,
  bool enabled = true,
}) =>
    SizedBox(
      width: 340,
      child: PantasSelect<String>(
        label: 'Province',
        placeholder: 'Choose a province',
        options: _options,
        value: value,
        onChanged: onChanged ?? (_) {},
        errorText: errorText,
        large: large,
        enabled: enabled,
      ),
    );

void main() {
  dsMatrix(
    'select: 48 button, ring, placeholder, large is 56',
    (context) => Column(
      children: [
        _select(),
        const SizedBox(height: 8),
        _select(large: true, value: 'cebu'),
      ],
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final buttons = find.byKey(const ValueKey('select-button'));
      expect(tester.getSize(buttons.first).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(buttons.last).height, greaterThanOrEqualTo(56));
      final placeholder = tester.widget<Text>(find.text('Choose a province'));
      expect(placeholder.style!.color, palette.textSecondary);
      final ring = tester.widget<Container>(buttons.first).foregroundDecoration!
          as BoxDecoration;
      expect((ring.border! as Border).top.color, palette.borderControl);
      expect(ring.borderRadius, BorderRadius.circular(12));
      // The large box has radius 14.
      final large = tester.widget<Container>(buttons.last).foregroundDecoration!
          as BoxDecoration;
      expect(large.borderRadius, BorderRadius.circular(14));
    },
  );

  testWidgets('opens on tap, shows the selected check, picks and closes',
      (tester) async {
    String? picked;
    await pumpDs(
      tester,
      dsCells.first,
      _select(value: 'batangas', onChanged: (v) => picked = v),
    );
    await tester.tap(find.byKey(const ValueKey('select-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsOneWidget);
    // Open: a 2 px accent ring.
    final ring = tester
        .widget<Container>(find.byKey(const ValueKey('select-button')))
        .foregroundDecoration! as BoxDecoration;
    expect((ring.border! as Border).top.width, 2);
    expect((ring.border! as Border).top.color, PantasColors.light.accent);
    await tester.tap(find.text('Laguna'));
    await tester.pumpAndSettle();
    expect(picked, 'laguna');
    expect(find.byKey(const ValueKey('select-list')), findsNothing);
  });

  testWidgets('keyboard: arrows move, Enter picks, Esc closes', (tester) async {
    String? picked;
    await pumpDs(
      tester,
      dsCells.first,
      _select(value: 'abra', onChanged: (v) => picked = v),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(picked, 'batangas');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsNothing);
  });

  testWidgets('invalid draws a 2 px danger ring and the message',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      _select(errorText: 'Choose your province.'),
    );
    final ring = tester
        .widget<Container>(find.byKey(const ValueKey('select-button')))
        .foregroundDecoration! as BoxDecoration;
    expect((ring.border! as Border).top.color, PantasColors.light.danger);
    expect((ring.border! as Border).top.width, 2);
    expect(find.text('Choose your province.'), findsOneWidget);
  });

  testWidgets('disabled is a fill well with no ring and does not open',
      (tester) async {
    await pumpDs(tester, dsCells.first, _select(enabled: false));
    final button = tester.widget<Container>(
      find.byKey(const ValueKey('select-button')),
    );
    expect(button.foregroundDecoration, isNull);
    expect(
      (button.decoration! as BoxDecoration).color,
      PantasColors.light.fill,
    );
    await tester.tap(find.byKey(const ValueKey('select-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('select-list')), findsNothing);
  });
}
