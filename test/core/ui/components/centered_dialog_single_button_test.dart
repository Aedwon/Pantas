import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

void main() {
  Future<void> pump(WidgetTester tester, {VoidCallback? onConfirm}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: CenteredDialog(
            title: 'Heads up',
            message: 'Plain words with an address.',
            messageSpan: const TextSpan(text: 'Span words with an address.'),
            primaryLabel: 'Got It',
            onConfirm: onConfirm ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('with no secondary label it draws one button', (tester) async {
    await pump(tester);
    expect(find.text('Got It'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('the message span replaces the plain message', (tester) async {
    await pump(tester);
    expect(
      find.text('Span words with an address.', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Plain words with an address.'), findsNothing);
  });

  testWidgets('the one button and Escape both confirm', (tester) async {
    var confirmed = 0;
    await pump(tester, onConfirm: () => confirmed++);
    await tester.tap(find.text('Got It'));
    expect(confirmed, 1);
  });
}
