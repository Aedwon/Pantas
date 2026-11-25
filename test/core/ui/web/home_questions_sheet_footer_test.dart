import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_side_overlay.dart';

void main() {
  // Ruling E-155, U49: the docked drawer footer button is full width, as
  // HM_ReviewsPanel draws it (the board for the screen beats the general
  // handoff line about full-width buttons).
  testWidgets('the drawer footer button spans the footer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 440,
              child: HomeWebQuestionsSheet(
                title: 'Reviews',
                done: 1,
                total: 4,
                rows: const [Text('Row')],
                startLabel: 'Start Reviews',
                onStart: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = tester.getSize(find.byType(WebButton));
    // 440 wide, 16 of padding on each side.
    expect(button.width, 440 - 32);
  });
}
