import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// 5S-4: on wide web the sheet's scrim was a gray box the size of the page
/// column, with hard edges, and the sidebar stayed bright.
void main() {
  const window = Size(1440, 900);
  late StateSetter change;
  var open = false;
  var dismissals = 0;

  Future<void> pumpShell(WidgetTester tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = window
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    open = false;
    dismissals = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Row(
            children: [
              const SizedBox(width: 295, child: Text('Sidebar')),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 28, 65, 0),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      change = setState;
                      return PantasSheet(
                        page: const Text('Quiz page'),
                        label: 'New questions',
                        open: open,
                        readerContents: true,
                        scrollable: false,
                        onDismiss: () => dismissals++,
                        child: const SizedBox(
                          height: 140,
                          child: Text('Sheet contents'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Finder scrim() => find.byWidgetPredicate(
        (widget) => widget is ModalBarrier && widget.semanticsLabel != null,
      );

  testWidgets('the scrim covers the whole window, sidebar and margins',
      (tester) async {
    await pumpShell(tester);
    expect(scrim(), findsNothing);

    change(() => open = true);
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.getRect(scrim()), Offset.zero & window);
  });

  testWidgets('the sheet itself stays in the page column', (tester) async {
    await pumpShell(tester);
    change(() => open = true);
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    final surface = tester.getRect(
      find.byKey(const ValueKey('pantas-sheet-surface')),
    );
    expect(surface.left, 295);
    expect(surface.right, window.width - 65);
    expect(surface.bottom, window.height);
    expect(find.text('Sheet contents'), findsOneWidget);
  });

  testWidgets('a tap on the sidebar side of the scrim dismisses the sheet',
      (tester) async {
    await pumpShell(tester);
    change(() => open = true);
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(100, 400));
    expect(dismissals, 1);
  });

  testWidgets('closing takes the scrim and the sheet off the window',
      (tester) async {
    await pumpShell(tester);
    change(() => open = true);
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    change(() => open = false);
    await tester.pumpAndSettle();

    expect(scrim(), findsNothing);
    expect(find.text('Sheet contents'), findsNothing);
    expect(find.text('Quiz page'), findsOneWidget);
  });
}
