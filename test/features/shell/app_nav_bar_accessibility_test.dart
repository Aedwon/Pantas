import 'package:flutter/material.dart';
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
