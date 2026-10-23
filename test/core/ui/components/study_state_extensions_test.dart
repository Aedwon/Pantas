import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Study state board metrics $brightness $scale',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          StateView(
            message: 'Could not load your topics.',
            boardLayout: true,
            onRetry: () {},
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
        );
        final message =
            tester.widget<Text>(find.text('Could not load your topics.'));
        expect(message.style!.fontSize, 20);
        expect(message.style!.fontWeight, FontWeight.w700);
        expect(message.style!.height, 1.35);
        expect(message.style!.letterSpacing, -.2);
        expect(
          tester.getSize(find.byKey(const ValueKey('state-mark'))),
          const Size(40, 40),
        );
        final button = tester.widget<PantasButton>(find.byType(PantasButton));
        expect(button.height, 44);
        expect(button.radius, 99);
        expect(button.horizontalPadding, 22);
        expect(button.fullWidth, isFalse);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'reader image failure keeps its frame and retries $brightness $scale',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          const ContentRenderer(
            readerFigures: true,
            blocks: [
              {
                '_type': 'image',
                'asset': {'url': 'https://example.invalid/diagram.png'},
                'alt': 'A described diagram',
              },
            ],
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
        final failure = find.text('This illustration didn’t load.');
        expect(failure, findsOneWidget);
        expect(tester.widget<Text>(failure).style!.fontSize, 13);
        expect(
          tester
              .getSize(find.byKey(const ValueKey('reader-image-failure')))
              .height,
          greaterThanOrEqualTo(223),
        );
        expect(find.byTooltip('Expand figure'), findsNothing);
        final colors = tester.element(failure).colors;
        final a = colors.secondaryLabel.computeLuminance();
        final b = colors.background.computeLuminance();
        expect(
          a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05),
          greaterThanOrEqualTo(4.5),
        );
        final before = tester.widget<Image>(find.byType(Image)).key;
        await tester.tap(find.text('Try Again'));
        await tester.pump();
        expect(tester.widget<Image>(find.byType(Image)).key, isNot(before));
        expect(
          tester.getSize(find.byType(Image)).height,
          greaterThanOrEqualTo(223),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
