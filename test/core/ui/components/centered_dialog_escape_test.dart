import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// A dialog opens with focus on its route, not inside its card. The card now
/// takes focus itself, so its own Esc shortcut is heard in a real browser.
void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> open(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (dialogContext) => CenteredDialog(
                  title: 'Sign out?',
                  message: 'Your progress is saved.',
                  primaryLabel: 'Sign Out',
                  secondaryLabel: 'Cancel',
                  onConfirm: () => Navigator.of(dialogContext).pop(true),
                  onCancel: () => Navigator.of(dialogContext).pop(false),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);
  }

  testWidgets('Esc closes a wide dialog', (tester) async {
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsNothing);
  });
}
