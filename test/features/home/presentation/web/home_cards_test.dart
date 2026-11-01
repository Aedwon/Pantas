import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('Home links have separate card surfaces, dark=$dark',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: HomeWebLayout(
              header: const Text('Home'),
              today: const Text('Today'),
              onRecord: () {},
              onTendencies: () {},
            ),
          ),
        ),
      );
      // Home (Main) board: white 16 px cards.
      final rows = <Element>[];
      for (final title in ['Your record', 'Your tendencies']) {
        final row = find.ancestor(
          of: find.text(title),
          matching: find.byType(TextButton),
        );
        expect(row, findsOneWidget);
        rows.add(row.evaluate().single);
        final button = tester.widget<TextButton>(row);
        expect(
          button.style!.backgroundColor!.resolve(<WidgetState>{}),
          dark ? const Color(0xFF1F1F1F) : Colors.white,
        );
        expect(
          button.style!.backgroundColor!.resolve({WidgetState.hovered}),
          dark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F9),
        );
      }
      expect(identical(rows[0], rows[1]), isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
