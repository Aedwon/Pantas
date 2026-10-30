import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_mock_finale.dart';

import 'cse_mock_finale_test.dart' show input;
import 'web_mock_layout_test.dart' show result;

void main() {
  for (final reduced in [false, true]) {
    testWidgets('wide finale ends once, reduced=$reduced', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 1000),
              disableAnimations: reduced,
            ),
            child: CseMockFinale(
              input: input(),
              blueprintName: 'CSE Professional simulation',
              resultsBuilder: (_, clock) => MockResultsPage(
                results: result,
                blueprintName: 'CSE Professional simulation',
                proIsActive: true,
                finaleClock: clock,
                pastResults: const [MockPastPoint(percent: 60, label: 'Oct 1')],
                onDone: () {},
              ),
            ),
          ),
        ),
      );
      final header = find
          .byWidgetPredicate((w) => w is WebFinaleEffect && w.track == 'k-rh');
      final past = find.byWidgetPredicate(
        (w) => w is WebFinaleEffect && w.track == 'k-rpast',
      );
      double opacity(Finder f) => tester
          .widget<Opacity>(
            find.descendant(of: f, matching: find.byType(Opacity)).first,
          )
          .opacity;
      if (!reduced) {
        expect(
          find.bySemanticsLabel('Time is up. 155 questions. 106 correct.'),
          findsOneWidget,
        );
      }
      expect(opacity(header), reduced ? 1 : 0);
      expect(opacity(past), reduced ? 1 : 0);
      if (!reduced) {
        List<Offset> labelOffsets() {
          final canvas = _TextPositionCanvas();
          tester
              .widget<CustomPaint>(
                find.byKey(const ValueKey('web-finale-scene')),
              )
              .painter!
              .paint(canvas, const Size(1440, 1000));
          return canvas.textOffsets.where((at) => at.dy == 440).toList();
        }

        expect(labelOffsets().single.dx, 753);
        await tester.pump(const Duration(milliseconds: 1100));
        expect(labelOffsets().single.dx, inExclusiveRange(464, 753));
        await tester.pump(const Duration(milliseconds: 400));
        expect(labelOffsets().single.dx, 464);
        await tester.pump(const Duration(milliseconds: 4100));
        final roll = tester.widget<Transform>(
          find.byKey(const ValueKey('web-finale-odometer')),
        );
        expect(roll.transform.storage[13], lessThan(0));
        expect(roll.transform.storage[13], greaterThan(-2944));
        await tester.pump(const Duration(milliseconds: 5750));
      } else {
        await tester.pump(const Duration(milliseconds: 11350));
      }
      expect(opacity(header), 1);
      expect(opacity(past), 1);
      expect(find.byKey(const ValueKey('web-mock-score')), findsOneWidget);
      expect(find.byKey(const ValueKey('web-finale-scene')), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.transientCallbackCount, 0);
    });
  }
}

class _TextPositionCanvas implements Canvas {
  final textOffsets = <Offset>[];

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {
    textOffsets.add(offset);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
