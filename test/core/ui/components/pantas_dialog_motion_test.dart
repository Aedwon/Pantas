import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Design system motion table: a dialog opens over 420 ms and closes over
/// 320 ms, on `motion-house`, with a 24 px rise and a fade.
void main() {
  Route<void>? route;

  Future<void> open(WidgetTester tester) async {
    route = null;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showPantasDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  route = ModalRoute.of(dialogContext)! as Route<void>;
                  return CenteredDialog(
                    title: 'Leave?',
                    message: 'Your place is saved.',
                    primaryLabel: 'Leave',
                    secondaryLabel: 'Stay',
                    onConfirm: () => Navigator.of(dialogContext).pop(true),
                    onCancel: () => Navigator.of(dialogContext).pop(false),
                  );
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
  }

  testWidgets('a dialog opens over 420 ms and closes over 320 ms',
      (tester) async {
    await open(tester);
    final animation = (route! as ModalRoute<void>).animation!;
    await tester.pump(const Duration(milliseconds: 210));
    expect(animation.value, closeTo(0.5, 0.05));
    await tester.pump(const Duration(milliseconds: 215));
    expect(animation.value, 1);
    expect(find.text('Leave?'), findsOneWidget);

    await tester.tap(find.text('Stay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    expect(animation.value, closeTo(0.5, 0.05));
    expect(find.text('Leave?'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 165));
    await tester.pump();
    expect(find.text('Leave?'), findsNothing);
  });

  testWidgets('a dialog rises 24 px as it fades in', (tester) async {
    await open(tester);
    final start = tester.getTopLeft(find.text('Leave?')).dy;
    await tester.pump(const Duration(milliseconds: 500));
    final rest = tester.getTopLeft(find.text('Leave?')).dy;
    expect(start - rest, closeTo(24, 1.5));
  });
}
