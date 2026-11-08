import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/motion/view_swap.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';

import '../../../core/ui/motion/preview_curves.dart';
import '../../../helpers/in_memory_database.dart';

// Item 17, demo 5 on the onboarding exam picker's group chips (wide web): the
// fill and label fade over 160 ms on the ease, and a press shrinks the chip.
const _entries = [
  ExamCatalogEntry(
    id: 'exam_cse_pro',
    name: 'CSE',
    shortName: 'CSE',
    priceTier: 'Student',
    group: 'Civil service',
    comingSoon: false,
    publishedSittings: [],
    hasContent: true,
  ),
  ExamCatalogEntry(
    id: 'exam_upcat',
    name: 'UPCAT',
    shortName: 'UPCAT',
    priceTier: 'Student',
    group: 'College entrance',
    comingSoon: false,
    publishedSittings: [],
    hasContent: true,
  ),
];

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pumpPicker(WidgetTester tester, {bool reduced = false}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final controller = OnboardingFrameController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(_entries)),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Scaffold(
            body: OnboardingFrame(
              controller: controller,
              enabled: true,
              resetToken: 'picker',
              child: ExamPickerScreen(
                mode: ExamPickerMode.onboarding,
                cseOnly: false,
                onPicked: (_) {},
                onBack: () {},
                onCustom: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder chip(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byKey(const ValueKey('wide-chip-fill')),
      );
  // The painted width, which a scale changes and the layout size does not.
  double width(WidgetTester tester, String label) =>
      tester.getBottomRight(chip(label)).dx - tester.getTopLeft(chip(label)).dx;
  Color fill(WidgetTester tester, String label) =>
      ((tester.widget<DecoratedBox>(chip(label)).decoration) as ShapeDecoration)
          .color!;
  Color ink(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style?.color ??
      DefaultTextStyle.of(tester.element(find.text(label))).style.color!;

  testWidgets('picking a chip fades its fill and label, 160 ms on the ease',
      (tester) async {
    await pumpPicker(tester);
    final off = fill(tester, 'Civil service');
    final on = const WebTokens(Brightness.light).colors.label;
    expect(off, isNot(on));
    await tester.tap(find.text('Civil service'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final mid = fill(tester, 'Civil service');
    expect(mid, isNot(off));
    expect(mid, isNot(on));
    final t = previewEase(80 / 150);
    expect(mid.r, closeTo(off.r + (on.r - off.r) * t, .02));
    final midInk = ink(tester, 'Civil service');
    await tester.pump(const Duration(milliseconds: 100));
    expect(fill(tester, 'Civil service'), on);
    expect(ink(tester, 'Civil service'), isNot(midInk));
  });

  testWidgets('a tap 3 px above the painted chip still selects it',
      (tester) async {
    await pumpPicker(tester);
    final painted = chip('Civil service');
    expect(tester.getSize(painted).height, 36);
    final off = fill(tester, 'Civil service');
    final top = tester.getTopLeft(painted);
    await tester.tapAt(Offset(top.dx + 20, top.dy - 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(fill(tester, 'Civil service'), isNot(off));
  });

  testWidgets('a press shrinks the chip to 96%, then springs back',
      (tester) async {
    await pumpPicker(tester);
    final rest = width(tester, 'College');
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('College')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final mid = width(tester, 'College') / rest;
    expect(mid, lessThan(1));
    expect(mid, greaterThan(.96));
    await tester.pump(const Duration(milliseconds: 120));
    expect(
      width(tester, 'College') / rest,
      closeTo(.96, .005),
    );
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(width(tester, 'College'), greaterThan(rest * .96));
    await tester.pumpAndSettle();
    expect(width(tester, 'College'), closeTo(rest, .01));
  });

  testWidgets('reduced motion shows the new fill and label at once',
      (tester) async {
    await pumpPicker(tester, reduced: true);
    await tester.tap(find.text('Civil service'));
    await tester.pump();
    final on = const WebTokens(Brightness.light).colors.label;
    expect(fill(tester, 'Civil service'), on);
  });

  // The exam list under the chips swaps with the approved view swap: 240 ms,
  // the old list fading out as the new one fades in.
  double seen(WidgetTester tester, String text) {
    var best = 0.0;
    for (final element in find.text(text).evaluate()) {
      var opacity = 1.0;
      element.visitAncestorElements((ancestor) {
        final widget = ancestor.widget;
        if (widget is Opacity) opacity *= widget.opacity;
        return true;
      });
      if (opacity > best) best = opacity;
    }
    return best;
  }

  testWidgets('picking a chip fades the exam list over 240 ms', (tester) async {
    await pumpPicker(tester);
    expect(seen(tester, 'CSE'), 1);
    expect(seen(tester, 'UPCAT'), 1);
    await tester.tap(find.text('Civil service'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    // Part-way: the old list is thinning and the new one has not come in.
    final oldMid = seen(tester, 'UPCAT');
    expect(oldMid, lessThan(1));
    expect(oldMid, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 80));
    final newMid = seen(tester, 'CSE');
    expect(newMid, greaterThan(0));
    expect(newMid, lessThan(1));
    // The old list is gone before the new one is whole.
    expect(find.text('UPCAT'), findsNothing);
    await tester.pumpAndSettle();
    expect(seen(tester, 'CSE'), 1);
    expect(find.text('UPCAT'), findsNothing);
    expect(find.byType(ViewSwap), findsOneWidget);
  });

  testWidgets('typing in the search does not swap the list', (tester) async {
    await pumpPicker(tester);
    await tester.enterText(find.byType(TextField), 'civil');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(seen(tester, 'CSE'), 1);
  });

  testWidgets('reduced motion swaps the exam list at once', (tester) async {
    await pumpPicker(tester, reduced: true);
    await tester.tap(find.text('Civil service'));
    await tester.pump();
    expect(seen(tester, 'CSE'), 1);
    expect(find.text('UPCAT'), findsNothing);
  });
}
