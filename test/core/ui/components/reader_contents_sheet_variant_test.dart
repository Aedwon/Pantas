import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

import '../../../helpers/accessibility.dart';

void main() {
  Finder inSheet(Type type) => find.descendant(
        of: find.byType(PantasSheet),
        matching: find.byType(type),
      );
  for (final brightness in Brightness.values) {
    testWidgets('reader Contents exact opening and closing in $brightness',
        (tester) async {
      var open = false;
      late StateSetter change;
      await pumpAccessibilitySurface(
        tester,
        StatefulBuilder(
          builder: (_, setState) {
            change = setState;
            return PantasSheet(
              page: const SizedBox.expand(),
              label: 'Contents',
              readerContents: true,
              open: open,
              onDismiss: () => setState(() => open = false),
              child: const SizedBox(height: 200),
            );
          },
        ),
        viewportSize: const Size(390, 844),
        brightness: brightness,
      );
      await tester.pumpAndSettle();
      change(() => open = true);
      await tester.pump();
      expect(
        tester
            .widget<FractionalTranslation>(
              inSheet(FractionalTranslation),
            )
            .translation
            .dy,
        1.05,
      );
      await tester.pump(const Duration(milliseconds: 175));
      expect(
        tester.widget<ModalBarrier>(inSheet(ModalBarrier)).color!.a,
        closeTo(.32 * PantasCurves.ease.transform(.5), .00001),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        tester
            .widget<FractionalTranslation>(
              inSheet(FractionalTranslation),
            )
            .translation
            .dy,
        closeTo(1.05 * (1 - PantasCurves.slideC.transform(.5)), .00001),
      );
      await tester.pump(const Duration(milliseconds: 225));
      expect(tester.widget<ModalBarrier>(inSheet(ModalBarrier)).color!.a, .32);
      expect(
        tester
            .getSize(
              find.byKey(const ValueKey('pantas-sheet-surface')),
            )
            .height,
        200,
      );
      for (final key in [
        'pantas-sheet-page-scale',
        'pantas-sheet-page-shift',
      ]) {
        final matrix =
            tester.widget<Transform>(find.byKey(ValueKey(key))).transform;
        expect(matrix.entry(0, 0), 1);
        expect(matrix.entry(1, 3), 0);
      }
      change(() => open = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 175));
      expect(
        tester.widget<ModalBarrier>(inSheet(ModalBarrier)).color!.a,
        closeTo(.32 * (1 - PantasCurves.ease.transform(.5)), .00001),
      );
      await tester.pump(const Duration(milliseconds: 25));
      expect(
        tester
            .widget<FractionalTranslation>(
              inSheet(FractionalTranslation),
            )
            .translation
            .dy,
        closeTo(1.05 * PantasCurves.slideC.transform(.5), .00001),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(inSheet(ModalBarrier), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reader Contents reduced motion and large text in $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        PantasSheet(
          page: const SizedBox.expand(),
          label: 'Contents',
          readerContents: true,
          open: true,
          onDismiss: () {},
          child: const SizedBox(height: 1200, child: Text('Today')),
        ),
        viewportSize: const Size(320, 640),
        textScale: 2,
        brightness: brightness,
        disableAnimations: true,
      );
      expect(
        tester
            .widget<FractionalTranslation>(
              inSheet(FractionalTranslation),
            )
            .translation
            .dy,
        0,
      );
      expect(tester.widget<ModalBarrier>(inSheet(ModalBarrier)).color!.a, .32);
      expect(
        tester
            .getSize(
              find.byKey(const ValueKey('pantas-sheet-surface')),
            )
            .height,
        lessThanOrEqualTo(640),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  for (final dismissal in ['escape', 'barrier', 'back', 'drag']) {
    testWidgets('reader Contents $dismissal returns page focus and semantics',
        (tester) async {
      var open = true;
      var presses = 0;
      final semantics = tester.ensureSemantics();
      try {
        await pumpAccessibilitySurface(
          tester,
          StatefulBuilder(
            builder: (_, setState) => PantasSheet(
              page: TextButton(
                onPressed: () => presses++,
                child: const Text('Reader action'),
              ),
              label: 'Contents',
              readerContents: true,
              open: open,
              onDismiss: () => setState(() => open = false),
              child: const SizedBox(height: 200, child: Text('Today')),
            ),
          ),
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Reader action'), findsNothing);
        switch (dismissal) {
          case 'escape':
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          case 'barrier':
            await tester.tapAt(const Offset(100, 100));
          case 'back':
            await tester.binding.handlePopRoute();
          case 'drag':
            await tester.drag(
              find.byKey(const ValueKey('pantas-sheet-surface')),
              const Offset(0, 100),
            );
        }
        await tester.pumpAndSettle();
        expect(inSheet(ModalBarrier), findsNothing);
        expect(find.bySemanticsLabel('Reader action'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(presses, 1);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }
}
