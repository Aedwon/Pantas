import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  for (final dark in [false, true]) {
    for (final sample in [
      ('Aerol', 'A'),
      ('ñino', 'Ñ'),
      ('🌸 Bea', '🌸'),
      ('123', ''),
      ('@me', ''),
      ('', ''),
    ]) {
      testWidgets('profile ${sample.$1} dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: Scaffold(body: Avatar(name: sample.$1)),
          ),
        );
        final t = WebTokens(dark ? Brightness.dark : Brightness.light);
        if (sample.$2.isEmpty) {
          expect(find.byIcon(PantasIcons.profile), findsOneWidget);
        } else {
          expect(find.text(sample.$2), findsOneWidget);
          final container = tester
              .widgetList<Container>(
                find.descendant(
                  of: find.byType(Avatar),
                  matching: find.byType(Container),
                ),
              )
              .firstWhere((widget) => widget.color != null);
          expect(container.color, t.colors.accentTint);
        }
      });
    }
  }
}
