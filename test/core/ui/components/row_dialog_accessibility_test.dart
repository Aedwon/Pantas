import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/list_row.dart';

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
  testWidgets('confirmation shadow uses QV_Leave CSS', (tester) async {
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
    );
    final box = tester
        .widget<DecoratedBox>(
          find.byKey(const ValueKey('centered-dialog-surface')),
        )
        .decoration as BoxDecoration;
    expect(box.boxShadow!.single.blurRadius, 40);
    expect(box.boxShadow!.single.offset, const Offset(0, 10));
    expect(box.boxShadow!.single.color.a, closeTo(.2, .001));
  });
}
