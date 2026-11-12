import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';

void main() {
  testWidgets('an open sheet shows exactly one drag handle', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      PantasSheet(
        page: const SizedBox.expand(),
        label: 'Sort by',
        open: true,
        onDismiss: () {},
        closeLabel: 'Close',
        child: const Text('Sheet contents'),
      ),
      viewportSize: const Size(390, 844),
      disableAnimations: true,
    );
    await tester.pumpAndSettle();
    expect(find.byType(PantasSheetGrabber), findsOneWidget);
    expect(find.byKey(const ValueKey('pantas-sheet-grabber')), findsOneWidget);
  });
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
          // 200 of content plus the grabber: 8 above and 5 high.
          bookmarks ? closeTo(624.56, .01) : 213,
        );
        final decoration =
            tester.widget<DecoratedBox>(sheet).decoration as BoxDecoration;
        expect(
          decoration.borderRadius,
          const BorderRadius.vertical(top: Radius.circular(PantasRadius.lg)),
        );
        expect(
          decoration.color,
          (brightness == Brightness.dark
                  ? PantasColors.dark
                  : PantasColors.light)
              .surfaceModal,
        );
        expect(
          decoration.boxShadow,
          (brightness == Brightness.dark
                  ? PantasShadow.dark
                  : PantasShadow.light)
              .sheet,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('pantas-sheet-grabber'))),
          const Size(36, 5),
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

  group('reduced motion', () {
    // The system setting, not only the MediaQuery: a controller left on its
    // default behavior runs at 5% of its time under it.
    Future<void> openStill(WidgetTester tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpAccessibilitySurface(
        tester,
        PantasSheet(
          page: const SizedBox.expand(),
          label: 'Questions',
          open: true,
          onDismiss: () {},
          child: const SizedBox(height: 200, child: Text('Saved items')),
        ),
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    }

    double fade(WidgetTester tester) => tester
        .widget<Opacity>(find.byKey(const ValueKey('pantas-sheet-fade')))
        .opacity;

    double wash(WidgetTester tester) =>
        tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).color!.a;

    testWidgets('the sheet and scrim fade in place over 150 ms',
        (tester) async {
      await openStill(tester);
      final place = tester.getTopLeft(
        find.byKey(const ValueKey('pantas-sheet-surface')),
      );
      expect(place.dy, 844 - 213);
      await tester.pump(const Duration(milliseconds: 75));
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('pantas-sheet-surface'))),
        place,
      );
      expect(fade(tester), closeTo(.5, .02));
      final full = PantasColors.light.scrim.a;
      expect(wash(tester), closeTo(full / 2, .02));
      await tester.pump(const Duration(milliseconds: 80));
      expect(fade(tester), 1);
      expect(wash(tester), closeTo(full, .001));
    });

    testWidgets('closing fades out in place before the sheet leaves',
        (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      var open = true;
      late StateSetter change;
      await pumpAccessibilitySurface(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            change = setState;
            return PantasSheet(
              page: const SizedBox.expand(),
              label: 'Questions',
              open: open,
              onDismiss: () {},
              child: const SizedBox(height: 200, child: Text('Saved items')),
            );
          },
        ),
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();
      change(() => open = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      expect(
        tester
            .getTopLeft(find.byKey(const ValueKey('pantas-sheet-surface')))
            .dy,
        844 - 213,
      );
      expect(fade(tester), closeTo(.5, .02));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump();
      expect(find.byKey(const ValueKey('pantas-sheet-surface')), findsNothing);
    });
  });

  group('landscape and height', () {
    Future<void> pumpSized(
      WidgetTester tester,
      Size size,
      Widget sheet, {
      EdgeInsets padding = EdgeInsets.zero,
    }) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              padding: padding,
              viewPadding: padding,
              disableAnimations: true,
            ),
            child: Scaffold(body: sheet),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    PantasSheet sheetOf({double height = 200, String? closeLabel}) =>
        PantasSheet(
          page: const SizedBox.expand(),
          label: 'Questions',
          open: true,
          onDismiss: () {},
          closeLabel: closeLabel,
          child: SizedBox(height: height, child: const Text('Saved items')),
        );

    final surface = find.byKey(const ValueKey('pantas-sheet-surface'));

    testWidgets(
        'at 844 by 390 the sheet is centered, 560 wide, rounded all '
        'round', (tester) async {
      await pumpSized(tester, const Size(844, 390), sheetOf());
      final rect = tester.getRect(surface);
      expect(rect.width, PantasLayout.modalWide);
      expect(rect.center.dx, 422);
      expect(rect.center.dy, closeTo(195, .5));
      final decoration =
          tester.widget<DecoratedBox>(surface).decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        const BorderRadius.all(Radius.circular(PantasRadius.lg)),
      );
    });

    testWidgets('the 500 pixel boundary: 500 is landscape, 501 is not',
        (tester) async {
      await pumpSized(tester, const Size(844, 500), sheetOf());
      expect(tester.getSize(surface).width, PantasLayout.modalWide);
      await pumpSized(tester, const Size(844, 501), sheetOf());
      expect(tester.getSize(surface).width, 844);
      expect(tester.getRect(surface).bottom, 501);
    });

    testWidgets('a narrow landscape viewport keeps the sheet inside it',
        (tester) async {
      await pumpSized(tester, const Size(480, 360), sheetOf());
      expect(tester.getSize(surface).width, 480);
    });

    testWidgets('portrait is full width with top corners only', (tester) async {
      await pumpSized(tester, const Size(390, 844), sheetOf());
      expect(tester.getSize(surface).width, 390);
      final decoration =
          tester.widget<DecoratedBox>(surface).decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(PantasRadius.lg)),
      );
    });

    testWidgets('max height is the viewport minus the top safe area minus 32',
        (tester) async {
      await pumpSized(
        tester,
        const Size(390, 844),
        sheetOf(height: 2000),
        padding: const EdgeInsets.only(top: 47),
      );
      expect(tester.getSize(surface).height, 844 - 47 - 32);
    });

    testWidgets('max height holds in landscape', (tester) async {
      await pumpSized(tester, const Size(844, 390), sheetOf(height: 2000));
      expect(tester.getSize(surface).height, 390 - 32);
    });

    testWidgets('the close action stays visible when the body scrolls',
        (tester) async {
      await pumpSized(
        tester,
        const Size(844, 390),
        sheetOf(height: 2000, closeLabel: 'Close'),
      );
      final sheet = tester.getRect(surface);
      final button = tester.getRect(find.byType(PantasButton));
      expect(button.bottom, lessThanOrEqualTo(sheet.bottom));
      expect(button.top, greaterThan(sheet.top));
    });
  });

  group('close action', () {
    Future<int Function()> pumpClose(
      WidgetTester tester,
      String label, {
      EdgeInsets padding = EdgeInsets.zero,
    }) async {
      final dismissals = <int>[];
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              padding: padding,
              viewPadding: padding,
              disableAnimations: true,
            ),
            child: Scaffold(
              body: PantasSheet(
                page: const SizedBox.expand(),
                label: 'Questions',
                open: true,
                closeLabel: label,
                onDismiss: () => dismissals.add(1),
                child: const SizedBox(height: 200, child: Text('Saved items')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return () => dismissals.length;
    }

    testWidgets('Close is a button at the end of the sheet that dismisses',
        (tester) async {
      final closeCount = await pumpClose(tester, 'Close');
      expect(find.widgetWithText(PantasButton, 'Close'), findsOneWidget);
      final surfaceRect = tester.getRect(
        find.byKey(const ValueKey('pantas-sheet-surface')),
      );
      final button = tester.getRect(find.byType(PantasButton));
      expect(button.bottom, lessThan(surfaceRect.bottom));
      expect(button.height, greaterThanOrEqualTo(44));
      await tester.tap(find.widgetWithText(PantasButton, 'Close'));
      expect(closeCount(), 1);
    });

    testWidgets('Cancel dismisses the same way', (tester) async {
      final closeCount = await pumpClose(tester, 'Cancel');
      await tester.tap(find.widgetWithText(PantasButton, 'Cancel'));
      expect(closeCount(), 1);
    });

    testWidgets('Tab reaches the button and Enter and Space press it',
        (tester) async {
      final closeCount = await pumpClose(tester, 'Close');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(closeCount(), 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(closeCount(), 2);
    });

    testWidgets('bottom padding is 34 with no safe area', (tester) async {
      await pumpClose(tester, 'Close');
      final surfaceRect = tester.getRect(
        find.byKey(const ValueKey('pantas-sheet-surface')),
      );
      expect(
        surfaceRect.bottom - tester.getRect(find.byType(PantasButton)).bottom,
        34,
      );
    });

    testWidgets('bottom padding is the safe area plus 20 once that is larger',
        (tester) async {
      await pumpClose(
        tester,
        'Close',
        padding: const EdgeInsets.only(bottom: 34),
      );
      final surfaceRect = tester.getRect(
        find.byKey(const ValueKey('pantas-sheet-surface')),
      );
      expect(
        surfaceRect.bottom - tester.getRect(find.byType(PantasButton)).bottom,
        54,
      );
    });

    testWidgets('a sheet with no close action draws no button', (tester) async {
      await pumpAccessibilitySurface(
        tester,
        PantasSheet(
          page: const SizedBox.expand(),
          label: 'Questions',
          open: true,
          onDismiss: () {},
          child: const SizedBox(height: 200, child: Text('Saved items')),
        ),
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      expect(find.byType(PantasButton), findsNothing);
    });
  });

  for (final closeLabel in ['Cancel', 'Close']) {
    dsMatrix(
      'sheet with $closeLabel',
      (context) => SizedBox(
        height: 900,
        child: PantasSheet(
          page: const SizedBox.expand(),
          label: 'Sort by',
          open: true,
          closeLabel: closeLabel,
          onDismiss: () {},
          child: const SizedBox(height: 300, child: Text('Saved items')),
        ),
      ),
      scroll: false,
      cells: dsShellCells,
      check: (tester, cell) async {
        expect(find.widgetWithText(PantasButton, closeLabel), findsOneWidget);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
