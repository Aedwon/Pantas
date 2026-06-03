import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('primary renders board fill and fires onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      harness(
        BoardButton(label: 'Continue lesson', onPressed: () => tapped = true),
      ),
    );
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(BoardButton),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((box.decoration as BoxDecoration).color, AppColors.light.board);
    await tester.tap(find.text('Continue lesson'));
    expect(tapped, isTrue);
  });

  testWidgets('secondary has no fill', (tester) async {
    await tester.pumpWidget(
      harness(
        BoardButton(label: 'Skip', onPressed: () {}, secondary: true),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(BoardButton),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
    expect(find.text('Skip'), findsOneWidget);
  });
}
