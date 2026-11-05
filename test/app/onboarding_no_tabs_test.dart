import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

// 3M-10: at 1024 to 1279 wide, the floating Home, Study, Quiz, Settings bar
// showed on every onboarding step. Its buttons went nowhere until onboarding
// was done.
void main() {
  for (final width in [1024.0, 1100.0, 1279.0, 1280.0, 1440.0]) {
    for (final path in ['/onboarding', '/onboarding/custom/name']) {
      testWidgets('$path has no tab navigation at $width', (tester) async {
        debugWebPlatformOverride = true;
        addTearDown(() => debugWebPlatformOverride = null);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(web: true),
              home: WebRouteShell(
                path: path,
                child: const Scaffold(body: Text('Onboarding')),
              ),
            ),
          ),
        );
        expect(find.byType(AppNavBar), findsNothing);
        expect(find.byType(WebSidebar), findsNothing);
        expect(find.text('Onboarding'), findsOneWidget);
      });
    }
  }
}
