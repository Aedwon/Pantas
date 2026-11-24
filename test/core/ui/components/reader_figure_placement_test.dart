// The held reader's placement rules, as numbers. Spec:
// docs/superpowers/specs/2026-11-23-lesson-reader-full-screen-design.md,
// "Layout", "Placing figures" (rules 1 to 5) and "Held figures".
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/reader_figure_placement.dart';

FlowEntry text(double height, {double above = 0, double below = 16}) =>
    FlowEntry(
      kind: FlowKind.text,
      height: height,
      above: above,
      below: below,
    );

FlowEntry heading(double height) => FlowEntry(
      kind: FlowKind.heading,
      height: height,
      above: 40,
      below: 12,
    );

MarginFigure prose(
  int id,
  double height, {
  required int anchor,
  int? anchorEnd,
  int blockStart = 0,
}) =>
    MarginFigure(
      id: id,
      height: height,
      anchorStart: anchor,
      anchorEnd: anchorEnd ?? anchor,
      blockStart: blockStart,
    );

void main() {
  group('layout metrics by window width', () {
    test('1280 and up: 1,096 page, 640 text, 56 gap, 400 figures', () {
      for (final width in [1280.0, 1440.0, 1920.0]) {
        final m = HeldMetrics.forWidth(width)!;
        expect(m.textWidth, 640);
        expect(m.gap, 56);
        expect(m.figureWidth, 400);
        expect(m.pageWidth, 1096);
        expect(m.pageLeft, (width - 1096) / 2);
      }
    });

    test('1024 to 1279: up to 600 text, 48 gap, 300 figures, 40 margins', () {
      final m = HeldMetrics.forWidth(1100)!;
      expect(m.textWidth, 600);
      expect(m.gap, 48);
      expect(m.figureWidth, 300);
      expect(m.pageLeft, 40);
      final narrow = HeldMetrics.forWidth(1024)!;
      expect(narrow.textWidth, 1024 - 2 * 40 - 300 - 48);
      expect(narrow.figureWidth, 300);
      final top = HeldMetrics.forWidth(1279)!;
      expect(top.textWidth, 600);
    });

    test('under 1024 there is no held layout', () {
      expect(HeldMetrics.forWidth(1023), isNull);
      expect(HeldMetrics.forWidth(390), isNull);
    });

    test('a figure plate is the column minus 20 px each side', () {
      expect(HeldMetrics.forWidth(1440)!.plateInnerWidth, 360);
      expect(HeldMetrics.forWidth(1100)!.plateInnerWidth, 260);
    });
  });

  group('rule 1, the anchor', () {
    test('the plate top is the anchor top plus 6 px', () {
      final result = placeFigures(
        entries: [text(100), text(200), text(300)],
        figures: [prose(1, 150, anchor: 1)],
        viewportHeight: 900,
      );
      final anchorTop = result.entryTops[1];
      expect(result.figures[1]!.top, anchorTop + 6);
    });

    test('a list anchor starts at the list, so the plate sits at its top', () {
      // 0 intro, 1 to 3 list items, figure after the last item.
      final result = placeFigures(
        entries: [
          text(30),
          text(30, below: 8),
          text(30, below: 8),
          text(30),
          text(400),
        ],
        figures: [prose(1, 120, anchor: 0, anchorEnd: 3)],
        viewportHeight: 900,
      );
      expect(result.figures[1]!.top, result.entryTops[0] + 6);
    });
  });

  group('rule 3, the passage', () {
    test('a plate that fits ends inside its passage and adds no space', () {
      final result = placeFigures(
        entries: [text(100), text(300), heading(40), text(100)],
        figures: [prose(1, 200, anchor: 1)],
        viewportHeight: 900,
      );
      expect(result.figures[1]!.extra, 0);
      expect(
        result.entryTops[3],
        _plain([text(100), text(300), heading(40), text(100)])[3],
      );
    });

    test('the next heading ends the passage', () {
      final entries = [text(100), text(60), heading(40), text(300)];
      final result = placeFigures(
        entries: entries,
        figures: [prose(1, 260, anchor: 1, blockStart: 0)],
        viewportHeight: 900,
      );
      final f = result.figures[1]!;
      final passageEnd = result.entryTops[1] + 60;
      // It cannot fit: it rises to the block start, then white space is added.
      expect(f.top + 260, lessThanOrEqualTo(passageEnd + f.extra));
      expect(f.passageEnd, passageEnd + f.extra);
    });

    test('a figure rises above its anchor, never above its heading', () {
      // 0 heading, 1 text (anchor), 2 text, heading 3. Plate 280 tall.
      final entries = [heading(40), text(80), text(80), heading(40), text(50)];
      final result = placeFigures(
        entries: entries,
        figures: [prose(1, 280, anchor: 1, blockStart: 0)],
        viewportHeight: 900,
      );
      final f = result.figures[1]!;
      expect(f.top, greaterThanOrEqualTo(result.entryTops[0]));
      expect(f.top, lessThanOrEqualTo(result.entryTops[1] + 6));
      // 40 heading + 12 + 80 + 16 + 80 = 228 of text: 280 does not fit, so the
      // passage grows by what is missing.
      expect(f.top + 280, f.passageEnd);
      expect(f.extra, greaterThan(0));
    });

    test('rising to the passage end uses the space above the anchor first', () {
      // The passage is short (60) but 400 of text sits above it in the block.
      final entries = [heading(40), text(400), text(60), heading(40)];
      final result = placeFigures(
        entries: entries,
        figures: [prose(1, 200, anchor: 2, blockStart: 0)],
        viewportHeight: 900,
      );
      final f = result.figures[1]!;
      final passageEnd = result.entryTops[2] + 60;
      expect(f.extra, 0);
      expect(f.top + 200, passageEnd);
      expect(f.top, lessThan(result.entryTops[2] + 6));
    });

    test('white space shifts everything after the passage', () {
      final entries = [heading(40), text(60), heading(40), text(50)];
      final without = _plain(entries);
      final result = placeFigures(
        entries: entries,
        figures: [prose(1, 300, anchor: 1, blockStart: 0)],
        viewportHeight: 900,
      );
      final extra = result.figures[1]!.extra;
      expect(extra, greaterThan(0));
      expect(result.entryTops[2], without[2] + extra);
      expect(result.entryTops[3], without[3] + extra);
      expect(result.totalHeight, _plainHeight(entries) + extra);
    });

    test('a note ends the passage like a heading', () {
      final entries = [
        text(100),
        text(80),
        const FlowEntry(kind: FlowKind.note, height: 70, below: 16),
        text(100),
      ];
      final result = placeFigures(
        entries: entries,
        figures: [prose(1, 150, anchor: 1)],
        viewportHeight: 900,
      );
      expect(result.figures[1]!.passageEnd, greaterThan(0));
      expect(
        result.figures[1]!.passageEnd,
        result.entryTops[1] + 80 + result.figures[1]!.extra,
      );
    });

    test("the next figure's anchor ends the passage", () {
      final entries = [text(100), text(100), text(100), text(100)];
      final result = placeFigures(
        entries: entries,
        figures: [
          prose(1, 80, anchor: 0),
          prose(2, 80, anchor: 2),
        ],
        viewportHeight: 900,
      );
      expect(
        result.figures[1]!.passageEnd,
        result.entryTops[1] + 100 + result.figures[1]!.extra,
      );
    });

    test('with no terminator the passage ends at the last entry', () {
      final entries = [text(100), text(100)];
      final result = placeFigures(
        entries: entries,
        figures: [prose(1, 80, anchor: 0)],
        viewportHeight: 900,
      );
      expect(result.figures[1]!.passageEnd, result.entryTops[1] + 100);
    });
  });

  group('rule 2, examples', () {
    test('an example figure sits level with its card top and never moves', () {
      final entries = [
        text(100),
        const FlowEntry(kind: FlowKind.example, height: 300, below: 18),
        text(100),
      ];
      final result = placeFigures(
        entries: entries,
        figures: const [
          MarginFigure(
            id: 7,
            height: 228,
            anchorStart: 1,
            anchorEnd: 1,
            blockStart: 0,
            example: true,
          ),
        ],
        viewportHeight: 900,
      );
      final f = result.figures[7]!;
      expect(f.top, result.entryTops[1]);
      expect(f.passageEnd, result.entryTops[1] + 300);
      expect(f.extra, 0);
    });
  });

  group('rule 4, collision', () {
    test('a plate closer than 18 px to the one above moves down and stacks',
        () {
      // Two figures anchored on the same block.
      final entries = [text(100), text(500)];
      final result = placeFigures(
        entries: entries,
        figures: [
          prose(1, 200, anchor: 0),
          prose(2, 200, anchor: 0),
        ],
        viewportHeight: 1200,
      );
      final a = result.figures[1]!;
      final b = result.figures[2]!;
      expect(b.top, a.top + 200 + 18);
      expect(b.group, a.group);
      expect(result.groups.length, 1);
    });

    test('a figure at its own anchor starts a new group', () {
      final entries = [text(300), text(300), text(300)];
      final result = placeFigures(
        entries: entries,
        figures: [
          prose(1, 100, anchor: 0),
          prose(2, 100, anchor: 2),
        ],
        viewportHeight: 900,
      );
      expect(result.figures[1]!.group, isNot(result.figures[2]!.group));
      expect(result.groups.length, 2);
    });
  });

  group('rule 5, the stack cap', () {
    test('a group taller than the window minus 32 sends the last one inline',
        () {
      final entries = [text(100), text(900)];
      final result = placeFigures(
        entries: entries,
        figures: [
          prose(1, 300, anchor: 0),
          prose(2, 300, anchor: 0),
        ],
        viewportHeight: 650,
      );
      // 300 + 18 + 300 = 618 fits 650 - 32 = 618 exactly.
      expect(result.overCap, isEmpty);
      final tight = placeFigures(
        entries: entries,
        figures: [
          prose(1, 300, anchor: 0),
          prose(2, 300, anchor: 0),
        ],
        viewportHeight: 649,
      );
      expect(tight.overCap, {2});
    });
  });

  group('held offset', () {
    // A figure at rest 300, 200 tall, its passage ending at 900.
    double held(double viewportTop) => heldOffset(
          restTop: 300,
          bottom: 500,
          passageEnd: 900,
          viewportTop: viewportTop,
        );

    test('before its text reaches the sticky line the figure rests', () {
      expect(held(0), 0);
      expect(held(200), 0); // line at 232, rest 300
      expect(held(268), 0); // line at 300 exactly
    });

    test('while the passage is on screen the top stays at the sticky line', () {
      expect(held(300), 32);
      expect(held(500), 232);
      expect(held(668), 400); // line 700 = the push-off limit (900 - 200)
    });

    test('the end of the passage pushes the figure with the scroll', () {
      // Held offset stops growing at passageEnd - bottom = 400.
      expect(held(700), 400);
      expect(held(2000), 400);
    });

    test('never moves above its rest position', () {
      expect(held(-500), 0);
    });
  });
}

List<double> _plain(List<FlowEntry> entries) {
  final tops = <double>[];
  var y = 0.0;
  for (var i = 0; i < entries.length; i++) {
    if (i > 0) y += flowGap(entries[i - 1], entries[i]);
    tops.add(y);
    y += entries[i].height;
  }
  return tops;
}

double _plainHeight(List<FlowEntry> entries) {
  final tops = _plain(entries);
  return tops.last + entries.last.height;
}
