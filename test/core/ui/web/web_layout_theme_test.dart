import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_layout_theme.dart';

void main() {
  for (final width in [1440.0, 1023.0]) {
    for (final dark in [false, true]) {
      testWidgets('web palette at $width dark=$dark respects the layout switch',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        late PantasColors colors;
        await tester.pumpWidget(
          MaterialApp(
            theme:
                dark ? buildDarkTheme(web: false) : buildLightTheme(web: false),
            home: WebLayoutTheme(
              web: true,
              child: Builder(
                builder: (context) {
                  colors = context.colors;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
        expect(
          colors.background,
          width >= 1024
              ? dark
                  ? const Color(0xFF151515)
                  : const Color(0xFFF5F5F7)
              : dark
                  ? PantasColors.dark.background
                  : PantasColors.light.background,
        );
        expect(
          colors.wrongTint,
          width >= 1024
              ? dark
                  ? const Color(0xFF33201F)
                  : const Color(0xFFFDE8EA)
              : dark
                  ? PantasColors.dark.wrongTint
                  : PantasColors.light.wrongTint,
        );
      });
    }
  }
}
