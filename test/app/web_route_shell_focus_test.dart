import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  for (final path in ['/beta', '/auth/email-link']) {
    testWidgets('$path has no app navigation at tablet width', (tester) async {
      debugWebPlatformOverride = true;
      tester.view
        ..physicalSize = const Size(1100, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: WebRouteShell(path: path, child: const Placeholder()),
          ),
        ),
      );
      expect(find.byType(AppNavBar), findsNothing);
    });
  }

  // D136: from 1024 the sidebar is the navigation and the TabBar is gone.
  // Pages outside the sidebar families take the whole window at every wide
  // size, with no navigation over them and no padding that moves their bars.
  for (final width in [1024.0, 1100.0, 1439.0, 1440.0]) {
    for (final path in [
      '/lesson/l1',
      '/quiz/resume/e',
      '/quiz/mock/resume/a',
      '/quiz/all/a',
      '/assessment/e',
    ]) {
      testWidgets('$path at $width px takes the whole window', (tester) async {
        debugWebPlatformOverride = true;
        tester.view
          ..physicalSize = Size(width, 900)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const page = Placeholder(key: ValueKey('page'));
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildLightTheme(web: true),
              home: WebRouteShell(path: path, child: page),
            ),
          ),
        );
        expect(find.byType(AppNavBar), findsNothing);
        expect(find.byType(WebSidebar), findsNothing);
        expect(tester.getSize(find.byKey(const ValueKey('page'))).height, 900);
      });
    }
  }
}
