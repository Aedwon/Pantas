import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/ui/components/install_card.dart';
import 'package:pantas/core/ui/components/install_sheet.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  for (final path in [InstallPath.native, InstallPath.iosInstructions]) {
    dsMatrix(
      'Install card $path fits every width, theme and text scale',
      (context) => SizedBox(
        width: 390,
        child: InstallCard(path: path, onPrimary: () {}, onNotNow: () {}),
      ),
    );
  }

  dsMatrix(
    'Install sheet fits and uses surface-modal',
    (context) => const SizedBox(height: 860, child: InstallSheet()),
    scroll: false,
    check: (tester, cell) async {
      final colors = cell.dark ? PantasColors.dark : PantasColors.light;
      final shadows = cell.dark ? PantasShadow.dark : PantasShadow.light;
      final surface = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(InstallSheet),
              matching: find.byType(Container),
            ),
          )
          .first;
      final box = surface.decoration! as BoxDecoration;
      expect(box.color, colors.surfaceModal);
      expect(
        box.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(PantasRadius.lg)),
      );
      expect(box.boxShadow, shadows.sheet);
      expect(find.text('Got It'), findsOneWidget);
    },
  );
}
