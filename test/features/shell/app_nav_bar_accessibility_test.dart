import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

Widget harness(
        {bool dark = false,
        ValueChanged<int>? onTap,
        TextScaler textScaler = TextScaler.noScaling}) =>
    MaterialApp(
      theme: dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: Scaffold(
              bottomNavigationBar:
                  AppNavBar(currentIndex: 0, onTap: onTap ?? (_) {}))),
    );

void main() {
  testWidgets('tab glyphs use the board size of 23', (tester) async {
    await tester.pumpWidget(harness());
    expect(tester.widgetList<Icon>(find.byType(Icon)).map((icon) => icon.size),
        everyElement(23));
  });

  for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
    testWidgets('every tab accepts keyboard ${key.keyLabel}', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(harness(onTap: taps.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      for (var index = 0; index < 4; index++) {
        await tester.sendKeyEvent(key);
        await tester.pump();
        expect(taps, List<int>.generate(index + 1, (i) => i));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(tester.binding.transientCallbackCount, 0);
    });
  }

  for (final dark in [false, true]) {
    testWidgets(
        'unselected tab labels and icons use secondaryLabel, dark=$dark',
        (tester) async {
      await tester.pumpWidget(harness(dark: dark));
      final palette = dark ? PantasColors.dark : PantasColors.light;
      for (final label in ['Study', 'Quiz', 'Settings']) {
        final color = tester.widget<Text>(find.text(label)).style!.color!;
        expect(color, palette.secondaryLabel);
        final luminances = [
          color.computeLuminance(),
          palette.surface.computeLuminance()
        ]..sort();
        expect((luminances.last + 0.05) / (luminances.first + 0.05),
            greaterThanOrEqualTo(4.5));
      }
      expect(
          tester
              .widgetList<Icon>(find.byType(Icon))
              .skip(1)
              .map((icon) => icon.color),
          everyElement(palette.secondaryLabel));
    });
  }
}
