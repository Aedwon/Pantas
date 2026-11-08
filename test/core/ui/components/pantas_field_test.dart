import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

PantasColors _palette(DsCell cell) =>
    cell.dark ? PantasColors.dark : PantasColors.light;

BoxDecoration _ring(WidgetTester tester) => tester
    .widget<Container>(find.byKey(const ValueKey('field-well')))
    .foregroundDecoration! as BoxDecoration;

void main() {
  dsMatrix(
    'field: label above, 48 well, border-control ring',
    (context) => const SizedBox(
      width: 340,
      child: Column(
        children: [
          PantasField(label: 'Nickname', hint: 'What should we call you?'),
          SizedBox(height: 8),
          PantasField(
            label: 'Notes',
            multiline: true,
            optional: true,
            helpText: 'Only you see this.',
          ),
        ],
      ),
    ),
    check: (tester, cell) async {
      final palette = _palette(cell);
      final wells = find.byKey(const ValueKey('field-well'));
      expect(wells, findsNWidgets(2));
      expect(tester.getSize(wells.first).height, greaterThanOrEqualTo(48));
      // A textarea is at least 92 high.
      expect(tester.getSize(wells.last).height, greaterThanOrEqualTo(92));
      final ring = tester.widget<Container>(wells.first).foregroundDecoration!
          as BoxDecoration;
      expect((ring.border! as Border).top.color, palette.borderControl);
      expect((ring.border! as Border).top.width, 1);
      expect(ring.borderRadius, BorderRadius.circular(12));
      final well =
          tester.widget<Container>(wells.first).decoration! as BoxDecoration;
      expect(well.color, palette.surfaceCard);
      expect(find.text('Nickname'), findsOneWidget);
      expect(
        find.textContaining('(optional)', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Only you see this.'), findsOneWidget);
    },
  );

  testWidgets('focus draws a 2 px accent ring; a tap in the well focuses',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const SizedBox(width: 340, child: PantasField(label: 'Nickname')),
    );
    expect((_ring(tester).border! as Border).top.width, 1);
    // A tap anywhere in the visible well focuses the input.
    await tester.tapAt(
      tester.getTopLeft(find.byKey(const ValueKey('field-well'))) +
          const Offset(4, 4),
    );
    await tester.pumpAndSettle();
    final border = _ring(tester).border! as Border;
    expect(border.top.width, 2);
    expect(border.top.color, PantasColors.light.accent);
  });

  for (final cell in [dsCells[0], dsCells[1]]) {
    testWidgets('invalid: 2 px danger ring, icon and a sentence ($cell)',
        (tester) async {
      await pumpDs(
        tester,
        cell,
        const SizedBox(
          width: 340,
          child: PantasField(
            label: 'Email',
            errorText: 'Enter an email like name@example.com.',
          ),
        ),
      );
      final palette = _palette(cell);
      final border = _ring(tester).border! as Border;
      expect(border.top.width, 2);
      expect(border.top.color, palette.danger);
      expect(
        find.text('Enter an email like name@example.com.'),
        findsOneWidget,
      );
      final message = tester.widget<Text>(
        find.text('Enter an email like name@example.com.'),
      );
      expect(message.style!.color, palette.dangerText);
      // Color is never the only cue: the alert icon is there too.
      expect(find.byType(Icon), findsWidgets);
      // The danger ring has no red wash.
      final well = tester
          .widget<Container>(find.byKey(const ValueKey('field-well')))
          .decoration! as BoxDecoration;
      expect(well.color, palette.surfaceCard);
    });
  }

  testWidgets('read-only and disabled wells', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const SizedBox(
        width: 340,
        child: Column(
          children: [
            PantasField(label: 'Plan', readOnly: true),
            PantasField(label: 'Locked', enabled: false),
          ],
        ),
      ),
    );
    final wells = find.byKey(const ValueKey('field-well'));
    const palette = PantasColors.light;
    final readOnly = tester.widget<Container>(wells.first);
    expect((readOnly.decoration! as BoxDecoration).color, palette.surfaceInset);
    expect(
      ((readOnly.foregroundDecoration! as BoxDecoration).border! as Border)
          .top
          .color,
      palette.divider,
    );
    final disabled = tester.widget<Container>(wells.last);
    expect((disabled.decoration! as BoxDecoration).color, palette.fill);
    expect(disabled.foregroundDecoration, isNull);
  });
}
