import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  for (final tone in PantasTagTone.values) {
    dsMatrix(
      'Tag $tone is a 12/600 pill in its pair of roles',
      (context) => PantasTag('New Items', tone: tone),
      check: (tester, cell) async {
        final c = tester.element(find.byType(PantasTag)).colors;
        final (fill, ink) = switch (tone) {
          PantasTagTone.tint => (c.accentTint, c.accentTintText),
          PantasTagTone.solid => (c.accentFill, c.onAccent),
          PantasTagTone.gray => (c.fill, c.textOnFill),
          PantasTagTone.warning => (c.warningTint, c.warningTintText),
        };
        final box = tester.widget<Container>(
          find.byKey(const ValueKey('pantas-tag')),
        );
        final decoration = box.decoration! as ShapeDecoration;
        expect(decoration.color, fill);
        expect(decoration.shape, isA<StadiumBorder>());
        final text = tester.widget<Text>(find.text('New Items'));
        expect(text.style!.fontSize, 12);
        expect(text.style!.fontWeight, FontWeight.w600);
        expect(text.style!.color, ink);
        expect(
          box.padding,
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        );
        // Every tone holds 4.5:1 in both themes.
        double lum(Color x) => x.computeLuminance();
        final hi = lum(fill) > lum(ink) ? fill : ink;
        final lo = lum(fill) > lum(ink) ? ink : fill;
        expect((lum(hi) + .05) / (lum(lo) + .05), greaterThanOrEqualTo(4.5));
      },
    );
  }

  testWidgets('a tag is not interactive', (tester) async {
    await pumpDs(tester, dsCells.first, const PantasTag('New'));
    expect(find.byType(InkWell), findsNothing);
    expect(find.byType(GestureDetector), findsNothing);
    expect(
      PantasTag.heightFor(12),
      closeTo(12 * 1.3 + 4, .001),
    );
  });

  dsMatrix(
    'ProMark is gold with ink text, 11/700, radius 5, in both themes',
    (context) => const ProMark(),
    check: (tester, cell) async {
      final c = tester.element(find.byType(ProMark)).colors;
      final box = tester.widget<Container>(
        find.byKey(const ValueKey('pro-tag-surface')),
      );
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, c.pro);
      expect(decoration.borderRadius, BorderRadius.circular(5));
      expect(
        box.padding,
        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      );
      final text = tester.widget<Text>(find.text('Pro'));
      expect(text.style!.fontSize, 11);
      expect(text.style!.fontWeight, FontWeight.w700);
      expect(text.style!.color, c.onPro);
    },
  );

  testWidgets('ProTag keeps working as ProMark', (tester) async {
    await pumpDs(tester, dsCells.first, const ProTag());
    expect(
      find.byWidgetPredicate((widget) => widget is ProMark),
      findsOneWidget,
    );
  });
}
