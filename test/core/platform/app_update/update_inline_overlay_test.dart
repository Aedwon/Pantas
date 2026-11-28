import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/app_update/update_coordinator.dart';
import 'package:pantas/core/platform/app_update/update_overlay_registry.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_side_drawer.dart';
import 'package:pantas/core/ui/web/web_side_overlay.dart';

import 'update_coordinator_test.dart' show SafePoints;

void main() {
  for (final kind in ['sheet', 'home overlay', 'drawer', 'dialog']) {
    testWidgets('Home waits while the actual $kind is open', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final safe = SafePoints();
      final coordinator = UpdateCoordinator(
        onFailure: (error, _) => fail('$error'),
        onSafePoint: safe.call,
      )..routeChanged('/home');
      final Widget overlay = switch (kind) {
        'sheet' => PantasSheet(
            page: const SizedBox.expand(),
            label: 'Edit',
            open: true,
            onDismiss: () {},
            child: const TextField(),
          ),
        'home overlay' => HomeWebOverlay(
            page: const SizedBox.expand(),
            open: true,
            onDismiss: () {},
            label: 'Edit',
            child: const TextField(),
          ),
        'drawer' => WebSideDrawer(
            open: true,
            onDismiss: () {},
            title: 'Edit',
            body: const TextField(),
            closeLabel: 'Close',
          ),
        _ => CenteredDialog(
            title: 'Edit',
            message: '',
            primaryLabel: 'Save',
            secondaryLabel: 'Cancel',
            onConfirm: () {},
            onCancel: () {},
            content: const TextField(),
          ),
      };
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(body: overlay),
        ),
      );
      expect(updateOverlayRegistry.hasOpenOverlays, isTrue);
      await coordinator.check();
      expect(safe.count, 0);
      await tester.pumpWidget(const SizedBox());
      expect(updateOverlayRegistry.hasOpenOverlays, isFalse);
      await coordinator.check();
      expect(safe.count, 1);
    });
  }
}
