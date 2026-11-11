import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_side_overlay.dart';

import '../../../helpers/ds_matrix.dart';

const _wide = [
  DsCell(1440, 1, dark: false),
  DsCell(1440, 1, dark: true),
  DsCell(1440, 2, dark: false),
  DsCell(1440, 2, dark: true),
];

Widget _overlay({required bool drawer}) => HomeWebOverlay(
      page: const Text('Page'),
      open: true,
      label: 'Lessons',
      drawer: drawer,
      onDismiss: () {},
      child: const Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Pick a lesson to continue.'),
        ),
      ),
    );

void main() {
  for (final cell in _wide) {
    for (final drawer in [true, false]) {
      testWidgets('Drawer drawer=$drawer ($cell)', (tester) async {
        await pumpDs(tester, cell, _overlay(drawer: drawer), scroll: false);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final colors = cell.dark ? PantasColors.dark : PantasColors.light;
        final shadows = cell.dark ? PantasShadow.dark : PantasShadow.light;
        final key = ValueKey(drawer ? 'home-web-drawer' : 'home-web-dialog');
        final material = tester.widget<Material>(find.byKey(key));
        // The drawer is `bg-page` 440 wide; the dialog is `surface-modal`.
        expect(material.color, drawer ? colors.bgPage : colors.surfaceModal);
        final width = tester.getSize(find.byKey(key)).width;
        expect(width, drawer ? PantasLayout.drawer : PantasLayout.modalWide);
        if (!drawer) {
          expect(
            material.borderRadius,
            BorderRadius.circular(PantasRadius.r2xl),
          );
        }
        final shadow = tester
            .widgetList<DecoratedBox>(
              find.ancestor(
                of: find.byKey(key),
                matching: find.byType(DecoratedBox),
              ),
            )
            .map((d) => d.decoration)
            .whereType<BoxDecoration>()
            .firstWhere((d) => d.boxShadow != null)
            .boxShadow;
        expect(shadow, drawer ? shadows.drawer : shadows.modal);
        // The Close control keeps a 44 target.
        final close = tester.getSize(find.byTooltip('Close'));
        expect(close.shortestSide, greaterThanOrEqualTo(44));
        // The scrim is the `scrim` role.
        final barrier = tester.widget<AnimatedModalBarrier>(
          find.byType(AnimatedModalBarrier).last,
        );
        expect(barrier.color.value, colors.scrim);
      });
    }
  }

  test('Drawer and Dialog motion carry the system durations and curves', () {
    const drawer = WebOverlayMotion.drawer;
    expect(drawer.open, PantasDurations.long1);
    expect(drawer.close, PantasDurations.drawerClose);
    expect(drawer.curve, PantasCurves.slide);
    expect(drawer.scrim, PantasDurations.switchDuration);
    expect(drawer.scrimCurve, PantasCurves.fade);
    const dialog = WebOverlayMotion.dialog;
    expect(dialog.open, PantasDurations.medium3);
    expect(dialog.close, PantasDurations.medium2);
    expect(dialog.curve, PantasCurves.house);
    expect(dialog.scrim, PantasDurations.flip);
    expect(dialog.rise, 24);
    const popover = WebOverlayMotion.popover;
    expect(popover.open, PantasDurations.medium1);
    expect(popover.curve, PantasCurves.move);
  });

  for (final cell in _wide) {
    testWidgets('WebRootModal scrim is the scrim role ($cell)', (tester) async {
      await pumpDs(
        tester,
        cell,
        WebRootModal(
          modal: (_) => const Material(child: Text('Modal')),
          child: const Text('Page'),
        ),
        scroll: false,
      );
      await tester.pumpAndSettle();
      final colors = cell.dark ? PantasColors.dark : PantasColors.light;
      final barrier = tester.widget<AnimatedModalBarrier>(
        find.byType(AnimatedModalBarrier).last,
      );
      expect(barrier.color.value, colors.scrim);
      expect(find.text('Modal'), findsOneWidget);
    });
  }

  for (final cell in dsCells) {
    testWidgets('WebFullNotice ($cell)', (tester) async {
      await pumpDs(
        tester,
        cell,
        WebFullNotice(
          title: 'Something went wrong.',
          lead: "Nothing you've done is lost.",
          actionLabel: 'Try Again',
          onPressed: () {},
        ),
        scroll: false,
      );
      expect(tester.takeException(), isNull);
      final colors = cell.dark ? PantasColors.dark : PantasColors.light;
      final mark = tester.widget<Container>(
        find.byKey(const ValueKey('web-notice-mark')),
      );
      expect(
        (mark.decoration! as BoxDecoration).color,
        colors.accentFill,
      );
      expect(
        tester.widgetList<Scaffold>(find.byType(Scaffold)).last.backgroundColor,
        colors.bgPage,
      );
      final lead =
          tester.widget<Text>(find.text("Nothing you've done is lost."));
      expect(lead.style!.color, colors.textSecondary);
    });
  }
}
