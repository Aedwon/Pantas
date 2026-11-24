/// Where the figures of a lesson go on wide web ("4 Held"), as numbers.
///
/// Spec: `docs/superpowers/specs/2026-11-23-lesson-reader-full-screen-design.md`,
/// sections "Layout", "Placing figures" and "Held figures". This file is plain
/// Dart: the layout object measures the text, hands the heights here, and gets
/// back every position. Nothing here draws or reads the scroll position.
library;

import 'dart:math' as math;

/// The room a figure takes beside the text, for one window width.
///
/// 1,280 px and up: a 1,096 px page, centered, with 640 px of text, a 56 px
/// gap and a 400 px figure column. 1,024 to 1,279 px: up to 600 px of text, a
/// 48 px gap, a 300 px figure column, centered with 40 px side margins at
/// least. Under 1,024 px
/// the phone layout applies and there is no figure column.
class HeldMetrics {
  const HeldMetrics._({
    required this.textWidth,
    required this.gap,
    required this.figureWidth,
    required this.pageLeft,
  });

  /// The metrics for a window [width] wide, or null under 1,024 px.
  static HeldMetrics? forWidth(double width) {
    if (width < 1024) return null;
    if (width >= 1280) {
      return HeldMetrics._(
        textWidth: 640,
        gap: 56,
        figureWidth: 400,
        pageLeft: (width - 1096) / 2,
      );
    }
    // The text column, the gap and the figure column are one block. It is
    // centered, with at least 40 px at each side.
    final text = math.min<double>(600, width - 2 * 40 - 300 - 48);
    return HeldMetrics._(
      textWidth: text,
      gap: 48,
      figureWidth: 300,
      pageLeft: math.max<double>(40, (width - (text + 48 + 300)) / 2),
    );
  }

  final double textWidth;
  final double gap;
  final double figureWidth;

  /// Where the text column starts, from the window's left edge.
  final double pageLeft;

  double get pageWidth => textWidth + gap + figureWidth;

  /// Where the figure column starts, from the window's left edge.
  double get figureLeft => pageLeft + textWidth + gap;

  /// A plate keeps 20 px at each side (14 px above and below).
  double get plateInnerWidth => figureWidth - 2 * plateSide;

  static const double plateSide = 20;
  static const double plateVertical = 14;
}

/// What a block of text is, for where a passage ends.
enum FlowKind {
  /// A paragraph, list item, table, formula or an inline figure.
  text,

  /// A `##` or `###` heading.
  heading,

  /// A tip, trap or other note card.
  note,

  /// An example card.
  example,
}

/// One block of the text column, once measured.
class FlowEntry {
  const FlowEntry({
    required this.kind,
    required this.height,
    this.above = 0,
    this.below = 16,
    this.list = false,
  });

  final FlowKind kind;
  final double height;

  /// The margins the page puts around the block. The larger of the margin
  /// below one block and the margin above the next separates them.
  final double above;
  final double below;

  /// Two list items one after the other sit 8 px apart.
  final bool list;
}

/// The space between two neighbors in the text column.
double flowGap(FlowEntry previous, FlowEntry next) =>
    previous.list && next.list ? 8 : math.max(previous.below, next.above);

/// A figure that sits in the figure column.
class MarginFigure {
  const MarginFigure({
    required this.id,
    required this.height,
    required this.anchorStart,
    required this.anchorEnd,
    required this.blockStart,
    this.example = false,
  });

  /// Names the figure in the result.
  final int id;

  /// The plate's height, with its padding.
  final double height;

  /// The first and last entry of the anchor: the block just before the figure
  /// in the lesson, or, where that block is a list, the list and the sentence
  /// that introduces it. For an example figure, the example's own entry.
  final int anchorStart;
  final int anchorEnd;

  /// The entry that opens the figure's subsection, section or trap item: the
  /// nearest heading before the anchor, or 0.
  final int blockStart;

  /// An example figure sits level with its card and never moves.
  final bool example;
}

/// Where one figure ended up.
class FigurePlacement {
  const FigurePlacement({
    required this.id,
    required this.top,
    required this.height,
    required this.extra,
    required this.passageEnd,
    required this.group,
  });

  final int id;

  /// The plate's top at rest, from the top of the text column.
  final double top;
  final double height;

  /// White space added under the passage so the plate fits.
  final double extra;

  /// Where the passage ends, white space included.
  final double passageEnd;
  final int group;
}

/// Plates that stay together while they are held.
///
/// Only figures that share a passage (no text between them) are one group.
/// A figure pushed down from its own anchor holds within its own passage.
class FigureGroup {
  FigureGroup(this.id, this.top);
  final int id;
  final double top;
  double bottom = 0;
  double passageEnd = 0;

  /// Where the next group rests; a held plate stays [plateGap] above it.
  double nextTop = double.infinity;
  final List<int> ids = [];
}

/// Every position the text column and the figure column need.
class PlacementResult {
  const PlacementResult({
    required this.entryTops,
    required this.totalHeight,
    required this.figures,
    required this.groups,
    required this.overCap,
  });

  final List<double> entryTops;

  /// The column's height, white space included.
  final double totalHeight;
  final Map<int, FigurePlacement> figures;
  final List<FigureGroup> groups;

  /// Figures that would break the stack cap. They go inline in the text.
  final Set<int> overCap;

  /// How far group [group] sits below its place at rest, for a window whose
  /// top is [viewportTop] in the column's coordinates.
  double heldOffset(int group, double viewportTop) {
    final g = groups[group];
    return _heldOffset(
      restTop: g.top,
      bottom: g.bottom,
      passageEnd: g.passageEnd,
      viewportTop: viewportTop,
      nextTop: g.nextTop,
    );
  }
}

/// The space kept clear between two plates.
const double plateGap = 18;

/// A plate's top sits this far below its anchor's top (the first line's cap
/// height).
const double anchorOffset = 6;

/// The held plate's top, from the top of the window.
const double stickyLine = 32;

/// Works out where each entry and each figure goes. The rules follow the
/// spec, in order: anchor, examples, passage, collision, stack cap.
PlacementResult placeFigures({
  required List<FlowEntry> entries,
  required List<MarginFigure> figures,
  required double viewportHeight,
}) {
  // Where each passage ends: the first entry after its anchor that is a
  // heading, a note, an example card or the anchor of a later figure.
  final anchorStarts = {for (final f in figures) f.anchorStart};
  final endingAt = <int, List<MarginFigure>>{};
  final exampleAt = <int, MarginFigure>{};
  for (final figure in figures) {
    if (figure.example) {
      exampleAt[figure.anchorStart] = figure;
      continue;
    }
    var end = entries.length;
    for (var i = figure.anchorEnd + 1; i < entries.length; i++) {
      final kind = entries[i].kind;
      if (kind != FlowKind.text || anchorStarts.contains(i)) {
        end = i;
        break;
      }
    }
    endingAt.putIfAbsent(end, () => []).add(figure);
  }

  final tops = List<double>.filled(entries.length, 0);
  final placed = <int, FigurePlacement>{};
  final groups = <FigureGroup>[];
  final overCap = <int>{};
  final cap = viewportHeight - stickyLine;
  var previousBottom = double.negativeInfinity;
  FigureGroup? current;
  var currentEnd = -1;

  void join(
    FigurePlacement placement, {
    required bool stack,
    required int end,
  }) {
    var group = current;
    // Only figures that share a passage are one unit.
    final joins = stack && end == currentEnd;
    if (!joins || group == null) {
      currentEnd = end;
      group = FigureGroup(groups.length, placement.top);
      groups.add(group);
      current = group;
    }
    final bottom = placement.top + placement.height;
    if (joins && bottom - group.top > cap) overCap.add(placement.id);
    group.ids.add(placement.id);
    group
      ..bottom = math.max(group.bottom, bottom)
      ..passageEnd = math.max(group.passageEnd, placement.passageEnd);
    placed[placement.id] = FigurePlacement(
      id: placement.id,
      top: placement.top,
      height: placement.height,
      extra: placement.extra,
      passageEnd: placement.passageEnd,
      group: group.id,
    );
    previousBottom = math.max(previousBottom, bottom);
  }

  var y = 0.0;
  for (var i = 0; i <= entries.length; i++) {
    // y is the bottom of entry i - 1, which is where a passage that ends at
    // entry i ends.
    final ending = endingAt[i];
    if (ending != null) {
      var extra = 0.0;
      final end = y;
      for (final figure in ending) {
        final rest = tops[figure.anchorStart] + anchorOffset;
        var top = rest;
        if (rest + figure.height > end) {
          // Rise, within the block, until the bottom meets the passage end.
          final floor = math.max(
            tops[figure.blockStart],
            previousBottom + plateGap,
          );
          top = math.min(rest, math.max(floor, end - figure.height));
        }
        var stack = false;
        if (top < previousBottom + plateGap && previousBottom.isFinite) {
          top = previousBottom + plateGap;
          stack = true;
        }
        final over = math.max<double>(0, top + figure.height - end);
        extra = math.max(extra, over);
        join(
          FigurePlacement(
            id: figure.id,
            top: top,
            height: figure.height,
            extra: over,
            passageEnd: end + over,
            group: 0,
          ),
          stack: stack,
          end: i,
        );
      }
      y += extra;
      // The passage ends are final once the white space is known.
      for (final figure in ending) {
        final p = placed[figure.id]!;
        placed[figure.id] = FigurePlacement(
          id: p.id,
          top: p.top,
          height: p.height,
          extra: extra,
          passageEnd: end + extra,
          group: p.group,
        );
        final group = groups[p.group];
        group.passageEnd = math.max(group.passageEnd, end + extra);
      }
    }
    if (i == entries.length) break;
    if (i > 0) y += flowGap(entries[i - 1], entries[i]);
    tops[i] = y;
    y += entries[i].height;
    final example = exampleAt[i];
    if (example != null) {
      join(
        FigurePlacement(
          id: example.id,
          top: tops[i],
          height: example.height,
          extra: 0,
          passageEnd: y,
          group: 0,
        ),
        stack: false,
        end: -2 - i,
      );
    }
  }
  for (var g = 0; g + 1 < groups.length; g++) {
    groups[g].nextTop = groups[g + 1].top;
  }
  return PlacementResult(
    entryTops: tops,
    totalHeight: y,
    figures: placed,
    groups: groups,
    overCap: overCap,
  );
}

/// How far a group sits below its place at rest, for a window whose top is
/// [viewportTop] in the column's own coordinates.
///
/// The group holds at the sticky line while its passage is on screen. Past the
/// end of the passage it stops, so the page carries it away at the speed of
/// the scroll. It never rises above where it rests, and never comes closer
/// than [plateGap] to the next group's plate.
double heldOffset({
  required double restTop,
  required double bottom,
  required double passageEnd,
  required double viewportTop,
  double nextTop = double.infinity,
}) =>
    _heldOffset(
      restTop: restTop,
      bottom: bottom,
      passageEnd: passageEnd,
      viewportTop: viewportTop,
      nextTop: nextTop,
    );

double _heldOffset({
  required double restTop,
  required double bottom,
  required double passageEnd,
  required double viewportTop,
  required double nextTop,
}) {
  final wanted = viewportTop + stickyLine - restTop;
  final room = math.max<double>(
    0,
    math.min(passageEnd, nextTop - plateGap) - bottom,
  );
  return wanted.clamp(0.0, room);
}
