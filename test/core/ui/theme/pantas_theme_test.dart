import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/severity.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('context exposes current tokens, dark=$dark', (tester) async {
      final theme = dark ? buildDarkTheme() : buildLightTheme();
      final tokens = dark ? PantasColors.dark : PantasColors.light;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              expect(context.colors, tokens);
              expect(context.type.body.fontFamily, 'Geist');
              expect(theme.extension<PantasColors>(), tokens);
              expect(theme.extension<PantasType>(), isNotNull);
              expect(
                theme.extension<PantasType>()!.mathSerif.fontFamily,
                'packages/flutter_math_fork/KaTeX_Main',
              );
              expect(severityFor(0.4, context.colors), tokens.destructive);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  }
}
