import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

void main() {
  for (final width in [599.0, 600.0, 1023.0, 1024.0, 1279.0, 1280.0]) {
    testWidgets('shell navigation at $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var selected = -1;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: WebShellFrame(
            web: true,
            activeIndex: 0,
            person: 'Aedwon',
            exam: 'CSE',
            plan: 'Free',
            onNavigate: (index) => selected = index,
            onSearch: () {},
            child: const Text('Content'),
          ),
        ),
      );
      expect(
        find.byType(WebSidebar),
        width >= 1280 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(AppNavBar),
        width >= 1024 && width < 1280 ? findsOneWidget : findsNothing,
      );
      if (width >= 1024 && width < 1280) {
        expect(tester.getSize(find.byType(AppNavBar)).width, 358);
        expect(tester.getBottomLeft(find.byType(AppNavBar)).dy, 876);
        expect(tester.getCenter(find.byType(AppNavBar)).dx, width / 2);
        expect(find.text('Search lessons'), findsNothing);
        await tester.tap(find.text('Quiz'));
        expect(selected, 2);
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('tablet action bar clears navigation by 12 pixels',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebTabletNavigation(
          activeIndex: 2,
          onNavigate: (_) {},
          child: const Padding(
            padding: EdgeInsets.only(bottom: 72),
            child: Stack(
              children: [
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 28,
                  child: WebBottomBar(counter: '1 of 10', action: Text('Next')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.byType(AppNavBar)).dy -
          tester.getBottomLeft(find.byType(WebBottomBar)).dy,
      12,
    );
    expect(tester.takeException(), isNull);
  });
}
