import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
    final ink = tester.widget<Ink>(
      find
          .descendant(
            of: find.byType(BoardButton),
            matching: find.byType(Ink),
          )
          .first,
    );
    expect((ink.decoration! as BoxDecoration).color, AppColors.light.board);
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

  testWidgets('secondary meets the minimum tap target', (tester) async {
    await tester.pumpWidget(
      harness(
        BoardButton(label: 'Skip', onPressed: () {}, secondary: true),
      ),
    );
    final size = tester.getSize(
      find.descendant(
        of: find.byType(BoardButton),
        matching: find.byType(InkWell),
      ),
    );
    expect(size.height, greaterThanOrEqualTo(AppDimensions.minTapTarget));
  });

  testWidgets('secondary disabled label uses muted ink', (tester) async {
    await tester.pumpWidget(
      harness(
        const BoardButton(label: 'Skip', onPressed: null, secondary: true),
      ),
    );
    final text = tester.widget<Text>(find.text('Skip'));
    expect(text.style?.color, AppColors.light.inkMuted);
  });

  testWidgets('primary renders night board color under dark theme',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          body: BoardButton(label: 'Continue', onPressed: () {}),
        ),
      ),
    );
    final ink = tester.widget<Ink>(
      find.descendant(
        of: find.byType(BoardButton),
        matching: find.byType(Ink),
      ),
    );
    expect((ink.decoration as BoxDecoration?)?.color, AppColors.dark.board);
  });
}
