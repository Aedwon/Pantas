import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/update_required_page.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../../helpers/ds_matrix.dart';

/// Family C on the design system matrix: 390, 900, 1100 and 1440 wide, light
/// and dark, text scale 1.0 and 2.0. A layout overflow fails every cell.
void main() {
  setUpAll(loadDsFonts);

  dsMatrix(
    'the shell frame shows the sidebar from 1024 and never the TabBar',
    (context) => SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: 700,
      child: WebShellFrame(
        web: true,
        activeIndex: 2,
        person: 'Aedwon',
        exam: 'CSE',
        plan: 'Free',
        onNavigate: (_) {},
        onSearch: () {},
        child: const Text('Page'),
      ),
    ),
    scroll: false,
    web: true,
    cells: dsShellCells,
    check: (tester, cell) async {
      // The marker is measured after the first frame, then glides.
      await tester.pumpAndSettle();
      final sidebar = cell.width >= 1024;
      expect(find.byType(WebSidebar), sidebar ? findsOneWidget : findsNothing);
      expect(find.byType(AppNavBar), findsNothing);
      expect(find.text('Page'), findsOneWidget);
      if (sidebar) {
        final width = tester.getSize(find.byType(WebSidebar)).width;
        expect(
          width,
          inInclusiveRange(PantasLayout.sidebarMin, PantasLayout.sidebarMax),
        );
        // Every destination is at least a pointer target tall.
        for (final label in ['Home', 'Study', 'Quiz', 'Settings']) {
          expect(
            tester
                .getSize(
                  find.ancestor(
                    of: find.text(label),
                    matching: find.byType(TextButton),
                  ),
                )
                .height,
            greaterThanOrEqualTo(PantasSize.navItem),
          );
        }
        // The marker sits on the current item, wherever text size put it.
        final marker = tester.getRect(
          find.descendant(
            of: find.byKey(const ValueKey('sidebar-marker')),
            matching: find.byType(DecoratedBox),
          ),
        );
        final item = tester.getRect(
          find.ancestor(
            of: find.text('Quiz'),
            matching: find.byType(TextButton),
          ),
        );
        expect(marker.top, closeTo(item.top, .5));
        expect(marker.height, closeTo(item.height, .5));
      }
    },
  );

  dsMatrix(
    'the TabBar keeps four visible labels of at most 12 px and 44 targets',
    (context) => Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PantasLayout.tabbarMax),
        child: AppNavBar(currentIndex: 1, onTap: (_) {}),
      ),
    ),
    scroll: false,
    web: false,
    cells: [
      for (final c in dsShellCells)
        if (c.width < 1024) c,
    ],
    check: (tester, cell) async {
      for (final label in ['Home', 'Study', 'Quiz', 'Settings']) {
        final paragraph =
            tester.renderObject<RenderParagraph>(find.text(label));
        expect(paragraph.didExceedMaxLines, isFalse, reason: label);
        // D181: the label follows the OS size, but stops at 12.
        expect(paragraph.textScaler.scale(10), lessThanOrEqualTo(12.001));
        final target = tester.getSize(
          find
              .ancestor(of: find.text(label), matching: find.byType(Stack))
              .first,
        );
        expect(target.height, greaterThanOrEqualTo(PantasSize.targetTouch));
      }
      final bar = tester.getSize(find.byType(AppNavBar));
      expect(bar.height, PantasSize.tabbar);
      expect(bar.width, lessThanOrEqualTo(PantasLayout.tabbarMax));
    },
  );

  dsMatrix(
    'update required fits and keeps its Update action',
    (context) => const UpdateRequiredPage(isWeb: false),
    scroll: false,
    cells: dsShellCells,
    check: (tester, cell) async {
      expect(find.text('Update'), findsOneWidget);
      expect(
        find.text('Pantas needs an update to keep working.'),
        findsOneWidget,
      );
    },
  );
}
