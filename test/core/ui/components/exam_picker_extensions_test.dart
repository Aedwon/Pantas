import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('picker row and chip metrics $brightness $scale',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          Builder(
            builder: (context) => ColoredBox(
              color: context.colors.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PantasButton.filterChip(
                    label: 'All',
                    selected: true,
                    onPressed: () {},
                  ),
                  ListRow.exam(
                    title: 'UPCAT',
                    subtitle: 'University of the Philippines',
                    selected: true,
                    onTap: () {},
                    divider: true,
                  ),
                ],
              ),
            ),
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final label = tester.widget<Text>(find.text('All'));
        expect(label.style!.fontSize, 14);
        expect(label.style!.fontWeight, FontWeight.w600);
        expect(
          tester.getSize(find.byType(PantasButton)).height,
          scale == 1 ? 32 : 38,
        );
        final style =
            tester.widget<TextButton>(find.byType(TextButton).first).style!;
        expectContrast(
          label.style!.color!,
          style.backgroundColor!.resolve({})!,
        );
        final title = tester.widget<Text>(find.text('UPCAT'));
        final colors = tester.element(find.byType(ListRow)).colors;
        expectContrast(title.style!.color!, colors.surface);
        final subtitle =
            tester.widget<Text>(find.text('University of the Philippines'));
        expectContrast(subtitle.style!.color!, colors.surface);
        expect(title.style!.fontSize, 17);
        expect(title.style!.fontWeight, FontWeight.w400);
        expect(title.style!.height, 1.35);
        expect(title.style!.letterSpacing, -.204);
        expect(subtitle.style!.fontSize, 13);
        expect(subtitle.style!.height, 1.35);
        final mark = find.byKey(const ValueKey('selection-mark'));
        expect(
          mark,
          paints
            ..path(
              color: colors.onAccent,
              strokeWidth: 2,
              style: PaintingStyle.stroke,
            ),
        );
        expectContrast(colors.accent, colors.surface, minimum: 3);
        expect(title.maxLines, 1);
        expect(title.overflow, TextOverflow.ellipsis);
        expect(
          tester.getSize(find.byKey(const ValueKey('selection-mark'))),
          const Size(24, 24),
        );
        final line = tester.widget<DecoratedBox>(
          find.byKey(const ValueKey('exam-row-divider')),
        );
        expect(
          ((line.decoration as BoxDecoration).border! as Border).bottom.width,
          .5,
        );
        expect(tester.takeException(), isNull);
      });
      testWidgets('settings picker title metrics $brightness $scale',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          PantasPage.settingsPicker(onBack: () {}, children: const []),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
          disableAnimations: true,
        );
        final title = tester.widget<Text>(find.text('Exam'));
        expect(title.style!.fontSize, 28);
        expect(title.style!.height, 1.2);
        expect(tester.getTopLeft(find.text('Exam')), const Offset(20, 52));
        expect(find.text('Your exam'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
