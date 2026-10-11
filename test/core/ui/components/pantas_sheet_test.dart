import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';

import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('closed sheet keeps the page interactive without a barrier',
      (tester) async {
    var presses = 0;
    await pumpAccessibilitySurface(
      tester,
      PantasSheet(
        page: TextButton(
          onPressed: () => presses++,
          child: const Text('Open bookmarks'),
        ),
        label: 'Bookmarks',
        open: false,
        onDismiss: () {},
        child: const Text('Sheet contents'),
      ),
      viewportSize: const Size(390, 844),
      disableAnimations: true,
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(PantasSheet),
        matching: find.byType(ModalBarrier),
      ),
      findsNothing,
    );
    expect(find.text('Sheet contents'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(presses, 1);
  });
  testWidgets('page semantics return only after the closing sheet leaves',
      (tester) async {
    var open = true;
    late StateSetter change;
    final semantics = tester.ensureSemantics();
    try {
      await pumpAccessibilitySurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            change = setState;
            return PantasSheet(
              page: Semantics(
                label: 'Study content',
                child: const SizedBox.expand(),
              ),
              label: 'Bookmarks',
              open: open,
              bookmarks: true,
              onDismiss: () {},
              child: const Text('Saved items'),
            );
          },
        ),
        viewportSize: const Size(390, 844),
      );
      await tester.pumpAndSettle();
      change(() => open = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.bySemanticsLabel('Study content'), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.bySemanticsLabel('Study content'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
  testWidgets('sheet closes from a downward drag at the top of long contents',
      (tester) async {
    var dismissals = 0;
    await pumpAccessibilitySurface(
      tester,
      PantasSheet(
        page: const SizedBox.expand(),
        label: 'Bookmarks',
        open: true,
        bookmarks: true,
        onDismiss: () => dismissals++,
        child: const SizedBox(height: 1200),
      ),
      viewportSize: const Size(390, 844),
      disableAnimations: true,
    );
    await tester.drag(
      find.byKey(const ValueKey('pantas-sheet-surface')),
      const Offset(0, 100),
    );
    await tester.pump();
    expect(dismissals, 1);
  });
  for (final brightness in Brightness.values) {
    for (final bookmarks in [false, true]) {
      testWidgets('sheet $bookmarks final metrics and keyboard in $brightness',
          (tester) async {
        var dismissals = 0;
        final widget = PantasSheet(
          page: const ColoredBox(color: Colors.transparent),
          label: bookmarks ? 'Bookmarks' : 'Questions',
          open: true,
          bookmarks: bookmarks,
          onDismiss: () => dismissals++,
          child: const SizedBox(height: 200, child: Text('Saved items')),
        );
        await pumpAccessibilitySurface(
          tester,
          widget,
          viewportSize: const Size(390, 844),
          brightness: brightness,
          disableAnimations: true,
        );
        final sheet = find.byKey(const ValueKey('pantas-sheet-surface'));
        expect(
          tester.getSize(sheet).height,
          bookmarks ? closeTo(624.56, .01) : 200,
        );
        final decoration =
            tester.widget<DecoratedBox>(sheet).decoration as BoxDecoration;
        expect(
          decoration.borderRadius,
          const BorderRadius.vertical(top: Radius.circular(22)),
        );
        final pageScale = tester.widget<Transform>(
          find.byKey(const ValueKey('pantas-sheet-page-scale')),
        );
        expect(pageScale.transform.entry(0, 0), bookmarks ? .985 : 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        expect(dismissals, 1);
        await expectSurvivesTextScale(
          tester,
          widget,
          viewportSize: const Size(390, 844),
          brightness: brightness,
          disableAnimations: true,
        );
      });
    }
    testWidgets(
        'bookmarks sheet and page reach board values at 225ms in $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        PantasSheet(
          page: const SizedBox.expand(),
          label: 'Bookmarks',
          open: true,
          bookmarks: true,
          onDismiss: () {},
          child: const Text('Saved items'),
        ),
        viewportSize: const Size(390, 844),
        brightness: brightness,
      );
      await tester.pump(const Duration(milliseconds: 225));
      final scale = tester.widget<Transform>(
        find.byKey(const ValueKey('pantas-sheet-page-scale')),
      );
      expect(scale.transform.entry(0, 0), closeTo(.985576, .0001));
      final shift = tester.widget<Transform>(
        find.byKey(const ValueKey('pantas-sheet-page-shift')),
      );
      expect(shift.transform.entry(1, 3), closeTo(9.61584, .01));
      await tester.pump(const Duration(milliseconds: 225));
      expect(
        tester
            .widget<Transform>(
              find.byKey(const ValueKey('pantas-sheet-page-shift')),
            )
            .transform
            .entry(1, 3),
        10,
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
