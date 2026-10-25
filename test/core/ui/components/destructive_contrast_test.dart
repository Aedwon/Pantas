import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/confirmation_dialog.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/settings.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('destructive dialog label is white on red, dark=$dark',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => showAppConfirmationDialog(
                    context: context,
                    title: 'Delete?',
                    body: 'This cannot be undone.',
                    cancelLabel: 'Cancel',
                    confirmLabel: 'Delete',
                    onCancel: () {},
                    onConfirm: () {},
                  ),
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      _expectWhiteOnRed(tester, 'Delete');
    });
    testWidgets(
        'delete labels keep contrast before and during deletion, dark=$dark',
        (tester) async {
      final pending = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          home: DeleteAccountPage(
            isAnonymous: false,
            entitlement: const SettingsEntitlementSnapshot.free(),
            dpoEmail: 'dpo@example.test',
            onDelete: () => pending.future,
          ),
        ),
      );
      _expectWhiteOnRed(tester, 'Delete My Data');
      await tester.tap(find.text('Delete My Data'));
      await tester.pump();
      _expectWhiteOnRed(tester, 'Delete My Data');
      expect(find.text('Deleting...'), findsOneWidget);
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .color,
        Colors.white,
      );
      pending.complete();
      await tester.pumpAndSettle();
    });
  }
}

void _expectWhiteOnRed(WidgetTester tester, String label) {
  final foreground = tester.widget<Text>(find.text(label)).style!.color!;
  final buttons =
      find.ancestor(of: find.text(label), matching: find.byType(TextButton));
  final Color background;
  if (buttons.evaluate().isNotEmpty) {
    background = tester
        .widget<TextButton>(buttons.first)
        .style!
        .backgroundColor!
        .resolve({})!;
  } else {
    background = tester
        .widgetList<Container>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(Container),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .firstWhere(
          (decoration) => decoration.color == PantasColors.light.destructive,
        )
        .color!;
  }
  expect(foreground, Colors.white);
  expect(
    (foreground.computeLuminance() + 0.05) /
        (background.computeLuminance() + 0.05),
    greaterThanOrEqualTo(4.5),
  );
}
