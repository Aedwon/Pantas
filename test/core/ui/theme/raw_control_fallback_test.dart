import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';

// A raw Material control left anywhere must draw the system's look, not
// Flutter's: a rounded rectangle (never a stadium or circle), the
// `opacity-hover` wash, and no ink splash.
void main() {
  const themes = <String, bool>{'light': false, 'dark': true};

  for (final entry in themes.entries) {
    final dark = entry.value;
    final colors = dark ? PantasColors.dark : PantasColors.light;
    final theme = dark ? buildDarkTheme(web: true) : buildLightTheme(web: true);

    Widget host(Widget child) => MaterialApp(
          theme: theme,
          home: Scaffold(body: Center(child: child)),
        );

    void expectSystemRadius(ShapeBorder? shape, double radius) {
      expect(shape, isA<RoundedRectangleBorder>());
      expect(shape, isNot(isA<StadiumBorder>()));
      expect(
        (shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(radius),
      );
    }

    group('raw controls under the ${entry.key} theme', () {
      testWidgets('TextButton is a radius-md rectangle with the hover wash',
          (tester) async {
        await tester.pumpWidget(
          host(TextButton(onPressed: () {}, child: const Text('Back'))),
        );
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(TextButton),
            matching: find.byType(Material),
          ),
        );
        expectSystemRadius(material.shape, PantasRadius.md);
        final style = theme.textButtonTheme.style!;
        expect(
          style.overlayColor!.resolve({WidgetState.hovered}),
          colors.accent.withValues(alpha: PantasOpacity.hover),
        );
        expect(style.splashFactory, NoSplash.splashFactory);
      });

      testWidgets('IconButton is a radius-md rectangle with the hover wash',
          (tester) async {
        await tester.pumpWidget(
          host(
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close),
            ),
          ),
        );
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(IconButton),
            matching: find.byType(Material),
          ),
        );
        expectSystemRadius(material.shape, PantasRadius.md);
        expect(
          theme.iconButtonTheme.style!.overlayColor!
              .resolve({WidgetState.hovered}),
          colors.secondaryLabel.withValues(alpha: PantasOpacity.hover),
        );
      });

      testWidgets('every button theme is a rounded rectangle, not a stadium',
          (tester) async {
        for (final style in [
          theme.textButtonTheme.style,
          theme.filledButtonTheme.style,
          theme.elevatedButtonTheme.style,
          theme.outlinedButtonTheme.style,
          theme.iconButtonTheme.style,
        ]) {
          expectSystemRadius(style!.shape!.resolve({}), PantasRadius.md);
        }
      });

      testWidgets('InkWell in Material draws no splash and the system well',
          (tester) async {
        await tester.pumpWidget(
          host(
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {},
                child: const SizedBox(width: 80, height: 44),
              ),
            ),
          ),
        );
        final context = tester.element(find.byType(InkWell));
        final resolved = Theme.of(context);
        expect(resolved.splashFactory, NoSplash.splashFactory);
        expect(resolved.splashColor, Colors.transparent);
        expect(resolved.highlightColor, Colors.transparent);
        expect(resolved.hoverColor, colors.surfaceHover);
      });
    });
  }
}
