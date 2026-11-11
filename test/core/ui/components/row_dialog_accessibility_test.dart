import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';

import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('check and radio rows expose checked state', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      for (final variant in [ListRowVariant.check, ListRowVariant.radio]) {
        await pumpAccessibilitySurface(
          tester,
          ListRow(
            title: 'Selected',
            variant: variant,
            selected: true,
            onTap: () {},
          ),
        );
        expect(
          tester
              .getSemantics(find.bySemanticsLabel('Selected'))
              .flagsCollection
              .isChecked,
          CheckedState.isTrue,
        );
      }
    } finally {
      semantics.dispose();
    }
  });
  testWidgets('switch row exposes one named toggle', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpAccessibilitySurface(
        tester,
        ListRow(
          title: 'Reminders',
          variant: ListRowVariant.switchControl,
          selected: true,
          onTap: () {},
        ),
      );
      final row = find.bySemanticsLabel('Reminders');
      expect(row, findsOneWidget);
      expect(
        tester.getSemantics(row).flagsCollection.isToggled,
        Tristate.isTrue,
      );
    } finally {
      semantics.dispose();
    }
  });
  for (final brightness in Brightness.values) {
    testWidgets('dialog surface is surface-modal with elev-modal $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        CenteredDialog(
          title: 'Leave?',
          message: 'Your answers stay.',
          primaryLabel: 'Keep going',
          secondaryLabel: 'Cancel',
          onConfirm: () {},
          onCancel: () {},
        ),
        brightness: brightness,
      );
      final box = tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('centered-dialog-surface')),
          )
          .decoration as BoxDecoration;
      final dark = brightness == Brightness.dark;
      expect(
        box.color,
        (dark ? PantasColors.dark : PantasColors.light).surfaceModal,
      );
      expect(
        box.boxShadow,
        (dark ? PantasShadow.dark : PantasShadow.light).modal,
      );
      expect(
        box.borderRadius,
        BorderRadius.circular(PantasRadius.r2xl),
      );
    });
  }
}
