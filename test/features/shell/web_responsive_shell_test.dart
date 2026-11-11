import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

void main() {
  // D136: the TabBar is below 1024, the sidebar from 1024. The shell never
  // shows both, and 1280 is no longer a boundary.
  for (final width in [
    599.0,
    600.0,
    1023.0,
    1024.0,
    1279.0,
    1280.0,
    1439.0,
    1440.0,
  ]) {
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
            child: const SizedBox(
              key: ValueKey('page'),
              width: double.infinity,
              height: 40,
              child: Text('Content'),
            ),
          ),
        ),
      );
      final sidebar = width >= 1024;
      expect(find.byType(WebSidebar), sidebar ? findsOneWidget : findsNothing);
      // The shell frame never draws the TabBar; AppShell does, below 1024.
      expect(find.byType(AppNavBar), findsNothing);
      if (sidebar) {
        final side = tester.getSize(find.byType(WebSidebar)).width;
        expect(
          side,
          inInclusiveRange(PantasLayout.sidebarMin, PantasLayout.sidebarMax),
        );
        // The page fills the room right of the sidebar inside the main
        // sides (32 compact, 44 from 1440), at most 1080 wide.
        final sides = width >= 1440 ? PantasLayout.mainPadX : PantasSpace.s32;
        final room = width - side - 2 * sides;
        final page = tester.getRect(find.byKey(const ValueKey('page')));
        expect(
          page.width,
          room < PantasLayout.contentMax ? room : PantasLayout.contentMax,
        );
        expect(page.top, PantasLayout.mainPadTop);
        expect(
          page.left,
          side + sides + (room - page.width) / 2,
        );
        await tester.tap(find.text('Quiz'));
        expect(selected, 2);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
