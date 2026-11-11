import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  for (final web in [false, true]) {
    dsMatrix(
      'Toast web=$web fits every width, theme and text scale',
      (context) => Toast(message: 'Question flagged', onUndo: () {}, web: web),
      check: (tester, cell) async {
        final colors = tester.element(find.byType(Toast)).colors;
        final shadows = cell.dark ? PantasShadow.dark : PantasShadow.light;
        final surface = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(Toast),
                matching: find.byType(Container),
              ),
            )
            .first;
        final box = surface.decoration! as BoxDecoration;
        expect(box.color, colors.toastBg);
        expect(box.borderRadius, BorderRadius.circular(PantasRadius.lg));
        expect(box.boxShadow, shadows.toast);
        final message = tester.widget<Text>(find.text('Question flagged'));
        expect(message.style!.color, colors.toastText);
        expect(
          message.style!.fontSize,
          (web ? PantasType.webRowValue : PantasType.phoneSubhead).fontSize,
        );
        final undo = tester.widget<Text>(find.text('Undo'));
        expect(undo.style!.color, colors.toastAction);
        expect(undo.style!.fontWeight, FontWeight.w600);
        // The Undo target is 44 high.
        expect(
          tester.getSize(find.byType(TextButton)).height,
          greaterThanOrEqualTo(44),
        );
      },
    );
  }

  testWidgets('Toast rises 16 on enter and falls 8 on exit', (tester) async {
    var visible = false;
    late StateSetter change;
    await pumpDs(
      tester,
      dsCells.first,
      StatefulBuilder(
        builder: (_, setState) {
          change = setState;
          return Toast(message: 'Saved', visible: visible);
        },
      ),
    );
    double rise() => tester
        .widget<Transform>(find.byKey(const ValueKey('toast-rise')))
        .transform
        .storage[13];
    change(() => visible = true);
    await tester.pump();
    await tester.pump(PantasDurations.fade ~/ 2);
    expect(
      rise(),
      closeTo(16 * (1 - PantasCurves.house.transform(.5)), .01),
    );
    await tester.pump(PantasDurations.fade);
    expect(rise(), 0);
    change(() => visible = false);
    await tester.pump();
    await tester.pump(PantasDurations.flip ~/ 2);
    expect(
      rise(),
      closeTo(8 * PantasCurves.house.transform(.5), .01),
    );
  });

  testWidgets('Toast under reduced motion only fades', (tester) async {
    var visible = true;
    late StateSetter change;
    await pumpDs(
      tester,
      dsCells.first,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: StatefulBuilder(
            builder: (_, setState) {
              change = setState;
              return Toast(message: 'Saved', visible: visible);
            },
          ),
        ),
      ),
    );
    change(() => visible = false);
    await tester.pump();
    await tester.pump(PantasDurations.short2 ~/ 2);
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('toast-rise')))
          .transform
          .storage[13],
      0,
    );
    final opacity = tester.widget<Opacity>(
      find.ancestor(
        of: find.byKey(const ValueKey('toast-rise')),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, inExclusiveRange(0, 1));
  });

  testWidgets('Toast action has hover, press and keyboard states',
      (tester) async {
    var undo = 0;
    await pumpDs(
      tester,
      dsCells.first,
      Toast(message: 'Saved', onUndo: () => undo++, web: true),
    );
    final colors = tester.element(find.byType(Toast)).colors;
    final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
    expect(
      style.overlayColor!.resolve({WidgetState.hovered}),
      colors.toastActionHover,
    );
    expect(
      style.overlayColor!.resolve({}),
      Colors.transparent,
    );
    // The hover tint is the document's token: white at 10 percent.
    expect(PantasColors.light.toastActionHover.a, closeTo(.1, .01));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(undo, 1);
  });
}
