import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/severity.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('context exposes tokens and legacy adapters, dark=$dark',
        (tester) async {
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
              expect(theme.extension<AppColors>()!.ink, tokens.label);
              expect(
                theme.extension<AppTextStyles>()!.mathBody.fontFamily,
                'SourceSerif4',
              );
              expect(severityFor(0.4, context.colors), tokens.destructive);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  }

  testWidgets('legacy-only registries expose the new token APIs',
      (tester) async {
    final legacy = AppColors.light.copyWith(ink: Colors.blue);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [legacy, AppTextStyles.create()]),
        home: Builder(
          builder: (context) {
            expect(context.colors.label, Colors.blue);
            expect(context.colors.background, PantasColors.light.background);
            expect(context.type.body.fontFamily, 'Geist');
            return const SizedBox();
          },
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
