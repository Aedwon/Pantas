import 'package:cse_cet_reviewer/core/ui/components/nav_glyph.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) => MaterialApp(
    theme: buildLightTheme(), home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders at the specified size', (tester) async {
    await tester.pumpWidget(
      harness(
        NavGlyph(
          kind: NavGlyphKind.home,
          fill: 0,
          color: AppColors.light.inkMuted,
        ),
      ),
    );
    final box = tester.getSize(find.byType(NavGlyph));
    expect(box.width, 23);
    expect(box.height, 23);
  });

  testWidgets('every kind paints without throwing', (tester) async {
    for (final kind in NavGlyphKind.values) {
      await tester.pumpWidget(
        harness(
          NavGlyph(kind: kind, fill: 0.5, color: AppColors.light.ink),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('fill outside 0..1 is clamped rather than throwing',
      (tester) async {
    await tester.pumpWidget(
      harness(
        NavGlyph(
          kind: NavGlyphKind.quiz,
          fill: 1.8,
          color: AppColors.light.ink,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('repaints when fill changes and not when it does not',
      (tester) async {
    const kind = NavGlyphKind.progress;
    await tester.pumpWidget(
      harness(const NavGlyph(kind: kind, fill: 0, color: Color(0xFF000000))),
    );
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(NavGlyph),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter! as NavGlyphPainter;
    expect(
      painter.shouldRepaint(
        const NavGlyphPainter(
          kind: kind,
          fill: 0,
          color: Color(0xFF000000),
        ),
      ),
      isFalse,
    );
    expect(
      painter.shouldRepaint(
        const NavGlyphPainter(
          kind: kind,
          fill: 0.4,
          color: Color(0xFF000000),
        ),
      ),
      isTrue,
    );
  });
}
