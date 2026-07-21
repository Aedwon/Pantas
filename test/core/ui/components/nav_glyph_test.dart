import 'package:cse_cet_reviewer/core/ui/components/nav_glyph.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) => MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(body: Center(child: child)),
    );

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

  _structure();
}

void _structure() {
  const painter = NavGlyphPainter(
    kind: NavGlyphKind.home,
    fill: 0,
    color: Color(0xFF000000),
  );

  group('every glyph has internal structure', () {
    // A silhouette with nothing inside it reads as a blob at 23px. The first
    // cut drew only the outer shapes, which is what Aedwon saw.
    test('the house has a doorway as well as its walls', () {
      expect(painter.outlineFor(NavGlyphKind.home).computeMetrics().length, 2);
    });

    test('the book has two leaves', () {
      expect(painter.outlineFor(NavGlyphKind.study).computeMetrics().length, 2);
    });

    test('the sheet has a fold and a rising line', () {
      expect(
        painter.outlineFor(NavGlyphKind.progress).computeMetrics().length,
        3,
      );
    });

    test('the quiz is three options with three rules', () {
      expect(painter.outlineFor(NavGlyphKind.quiz).computeMetrics().length, 6);
    });
  });

  group('the fill region is not always the whole glyph', () {
    test('the quiz shades one option, not all three', () {
      final chosen = painter.fillRegionFor(NavGlyphKind.quiz).getBounds();
      final whole = painter.outlineFor(NavGlyphKind.quiz).getBounds();

      expect(chosen.height, lessThan(whole.height / 2));
      // The middle one, so it reads as a choice rather than a list.
      expect(chosen.center.dy, closeTo(12, 0.01));
    });

    test('the sheet does not fill its rising line into a blob', () {
      expect(
        painter.fillRegionFor(NavGlyphKind.progress).computeMetrics().length,
        1,
      );
    });

    test('the house fills without its doorway punched out', () {
      expect(
        painter.fillRegionFor(NavGlyphKind.home).computeMetrics().length,
        1,
      );
    });
  });
}
