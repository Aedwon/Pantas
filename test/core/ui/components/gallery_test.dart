import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/ui/gallery/component_gallery_page.dart';
import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('every gallery section builds and lays out', (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ComponentGalleryPage(),
      viewportSize: const Size(390, 844),
      disableAnimations: true,
    );
    final scroll =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    for (final name in ComponentGalleryPage.contractNames) {
      final section = find.byKey(ValueKey('gallery-$name'));
      for (var attempt = 0;
          section.evaluate().isEmpty && attempt < 80;
          attempt++) {
        scroll.jumpTo(math.min(scroll.pixels + 400, scroll.maxScrollExtent));
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(section, findsOneWidget, reason: name);
      expect(tester.takeException(), isNull, reason: name);
    }
  });
  test('gallery route exists only in debug configuration', () {
    expect(collectRoutePaths(), contains('/settings/_gallery'));
    expect(
      collectRoutePaths(includeDebugGallery: false),
      isNot(contains('/settings/_gallery')),
    );
  });
  testWidgets('gallery lists every contract and toggles the real theme',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ComponentGalleryPage(),
      viewportSize: const Size(390, 844),
    );
    expect(find.text('Component gallery'), findsOneWidget);
    await tester.tap(find.byTooltip('Switch theme'));
    await tester.pump(const Duration(milliseconds: 300));
    final scaffold = tester
        .widget<Scaffold>(find.byKey(const ValueKey('component-gallery')));
    expect(scaffold.backgroundColor, Colors.black);
    expect(
      ComponentGalleryPage.contractNames,
      containsAll([
        'GroupedSection',
        'ListRow',
        'PantasButton',
        'ButtonPair',
        'PantasSwitch',
        'SegmentedSwitch',
        'PantasPage',
        'ProgressRing',
        'CheckMark',
        'HalfRingGauge',
        'AccuracyBar',
        'WeekStrip',
        'SortCycleButton',
        'PantasSheet',
        'CenteredDialog',
        'Toast',
        'NoticeStrip',
        'FloatingBar',
        'QuestionGridSheet',
        'ValueWheel',
        'MonthFirstDatePicker',
        'ScopePicker',
        'SearchField',
        'Avatar',
        'LoadingShapes',
        'StepsScreen',
        'StateView',
        'ProTag',
        'ProPausedLine',
        'PlaceholderFigure',
        'QuestionCard',
        'ChoiceRow',
        'AnswerReveal',
        'PassageCard',
        'ContentRenderer',
        'MathText',
      ]),
    );
  });
}
