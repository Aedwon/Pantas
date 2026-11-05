import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

/// The shell holds a Navigator beside the sidebar. A Navigator puts a modal
/// barrier under its page, and a barrier hides every earlier sibling from the
/// accessibility tree and from the browser's Tab order, so the sidebar must
/// not share a semantics boundary with it.
Future<void> pumpShell(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1440, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(web: true),
      home: WebShellFrame(
        web: true,
        activeIndex: 0,
        person: 'Aedwon',
        exam: 'CSE',
        plan: 'Free',
        onNavigate: (_) {},
        onSearch: () {},
        child: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Route content'),
                  TextButton(onPressed: () {}, child: const Text('First')),
                  TextButton(onPressed: () {}, child: const Text('Second')),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the sidebar is in the accessibility tree beside a Navigator',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpShell(tester);
    for (final label in ['Home', 'Study', 'Quiz', 'Settings']) {
      expect(
        find.bySemanticsLabel(label),
        findsOneWidget,
        reason: '$label is in the tree',
      );
    }
    expect(find.bySemanticsLabel(RegExp('Search lessons')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Tab reaches the sidebar items', (tester) async {
    await pumpShell(tester);
    final seen = <String>{};
    for (var i = 0; i < 8; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focus = FocusManager.instance.primaryFocus;
      final context = focus?.context;
      if (context == null) continue;
      final texts = <String>[];
      void visit(Element e) {
        final w = e.widget;
        if (w is Text && w.data != null) texts.add(w.data!);
        e.visitChildren(visit);
      }

      (context as Element).visitChildren(visit);
      seen.addAll(texts);
    }
    expect(seen, containsAll(['Study', 'Quiz', 'Settings']));
  });
}
