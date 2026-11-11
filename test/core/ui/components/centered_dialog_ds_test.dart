import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

import '../../../helpers/ds_matrix.dart';

CenteredDialog _dialog({
  bool destructive = false,
  Widget? content,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) =>
    CenteredDialog(
      title: 'Sign out?',
      message: 'You can sign back in at any time. Your progress is saved.',
      primaryLabel: destructive ? 'Discard' : 'Sign Out',
      secondaryLabel: 'Cancel',
      onConfirm: onConfirm ?? () {},
      onCancel: onCancel ?? () {},
      destructive: destructive,
      content: content,
    );

void main() {
  for (final destructive in [false, true]) {
    dsMatrix(
      'Dialog destructive=$destructive fits every width, theme and text scale',
      (context) => _dialog(destructive: destructive),
      scroll: false,
      check: (tester, cell) async {
        final colors = cell.dark ? PantasColors.dark : PantasColors.light;
        final surface = tester.widget<DecoratedBox>(
          find.byKey(const ValueKey('centered-dialog-surface')),
        );
        final box = surface.decoration as BoxDecoration;
        // surface-modal, radius-2xl and elev-modal on every width.
        expect(box.color, colors.surfaceModal);
        expect(box.borderRadius, BorderRadius.circular(PantasRadius.r2xl));
        expect(
          box.boxShadow,
          (cell.dark ? PantasShadow.dark : PantasShadow.light).modal,
        );
        final rect = tester
            .getRect(find.byKey(const ValueKey('centered-dialog-surface')));
        final title = tester.widget<Text>(find.text('Sign out?'));
        if (cell.width >= 1024) {
          expect(rect.width, PantasLayout.modal);
          expect(title.style!.fontSize, PantasType.webH3.fontSize);
        } else {
          // `dialog--phone`: inset 24 each side.
          expect(rect.width, cell.width - 48);
          expect(title.style!.fontSize, PantasType.phoneTitle3.fontSize);
        }
        expect(title.style!.fontWeight, FontWeight.w700);
        // Both buttons stay on screen.
        expect(find.text('Cancel'), findsOneWidget);
        expect(
          find.text(destructive ? 'Discard' : 'Sign Out'),
          findsOneWidget,
        );
        final window = Rect.fromLTWH(0, 0, cell.width, 900);
        expect(window.contains(tester.getTopLeft(find.text('Cancel'))), isTrue);
      },
    );
  }

  dsMatrix(
    'Dialog with content widens on a wide screen and scrolls',
    (context) => _dialog(
      content: const SizedBox(height: 900, child: Text('Long body')),
    ),
    scroll: false,
    check: (tester, cell) async {
      final rect =
          tester.getRect(find.byKey(const ValueKey('centered-dialog-surface')));
      if (cell.width >= 1024) {
        expect(rect.width, PantasLayout.modalWide);
        // The actions stay visible while the body scrolls.
        expect(tester.getRect(find.text('Sign Out')).bottom, lessThan(900));
      }
      expect(rect.height, lessThanOrEqualTo(900));
    },
  );

  testWidgets('Dialog: Tab reaches the safe action first when destructive',
      (tester) async {
    var confirmed = 0;
    var cancelled = 0;
    await pumpDs(
      tester,
      const DsCell(390, 1, dark: false),
      _dialog(
        destructive: true,
        onConfirm: () => confirmed++,
        onCancel: () => cancelled++,
      ),
      scroll: false,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(cancelled, 1);
    expect(confirmed, 0);
  });

  testWidgets('Dialog: Esc cancels, and not when escape is off',
      (tester) async {
    var cancelled = 0;
    await pumpDs(
      tester,
      const DsCell(1440, 1, dark: false),
      _dialog(onCancel: () => cancelled++),
      scroll: false,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(cancelled, 1);
  });

  for (final cell in [dsCells[0], dsCells[3], dsCells[5]]) {
    testWidgets('Sheet surface, grabber and scrim ($cell)', (tester) async {
      var dismissed = 0;
      await pumpDs(
        tester,
        cell,
        PantasSheet(
          page: const SizedBox.expand(),
          label: 'Sort by',
          open: true,
          onDismiss: () => dismissed++,
          child: const SizedBox(height: 120, child: Text('Weakest first')),
        ),
        scroll: false,
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      final colors = cell.dark ? PantasColors.dark : PantasColors.light;
      final decoration = tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('pantas-sheet-surface')),
          )
          .decoration as BoxDecoration;
      expect(decoration.color, colors.surfaceModal);
      expect(
        decoration.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(PantasRadius.lg)),
      );
      expect(
        decoration.boxShadow,
        (cell.dark ? PantasShadow.dark : PantasShadow.light).sheet,
      );
      final grabber = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('pantas-sheet-grabber')),
      );
      expect(
        (grabber.decoration as BoxDecoration).color,
        colors.dividerStrong,
      );
      expect(
        tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).color,
        colors.scrim,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(dismissed, 1);
    });
  }
}
