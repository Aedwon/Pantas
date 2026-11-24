/// The lesson body on wide web ("4 Held"): a text column and a figure column.
///
/// Flutter web has no CSS sticky, so the hold is done here. Each figure plate
/// is a child of this layout. Layout puts it at its place at rest. Paint
/// moves it by the hold, which it works out from where the window's top is
/// at that moment. Paint runs in the frame that applied the scroll, so the
/// plate and the text can never be a frame apart, and no listener rebuilds
/// anything while the page scrolls.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/components/reader_figure_placement.dart';

/// One block of the text column.
class HeldEntry {
  const HeldEntry({
    required this.child,
    this.kind = FlowKind.text,
    this.above = 0,
    this.below = 16,
    this.list = false,
    this.major = false,
  });

  /// A `##` heading, which opens a section.
  final bool major;

  final Widget child;
  final FlowKind kind;
  final double above;
  final double below;
  final bool list;
}

/// A figure plate in the figure column.
class HeldFigure {
  const HeldFigure({
    required this.id,
    required this.plate,
    required this.anchorStart,
    required this.anchorEnd,
    required this.blockStart,
    this.example = false,
  });

  final int id;
  final Widget plate;
  final int anchorStart;
  final int anchorEnd;
  final int blockStart;
  final bool example;
}

/// The text column and the figure column of one lesson.
class HeldReader extends MultiChildRenderObjectWidget {
  HeldReader({
    required this.metrics,
    required this.viewportHeight,
    required this.entries,
    required this.figures,
    this.onOverCap,
    this.onLaidOut,
    super.key,
  }) : super(
          children: [
            for (final e in entries) e.child,
            for (final f in figures) f.plate,
          ],
        );

  final HeldMetrics metrics;

  /// The window's height, for the stack cap.
  final double viewportHeight;
  final List<HeldEntry> entries;
  final List<HeldFigure> figures;

  /// Called after layout, with the figures that would break the stack cap.
  final ValueChanged<Set<int>>? onOverCap;

  /// Called after layout with the result, so the page can read where its
  /// sections start.
  final ValueChanged<PlacementResult>? onLaidOut;

  @override
  RenderHeldReader createRenderObject(BuildContext context) =>
      RenderHeldReader()..configure(this);

  @override
  void updateRenderObject(BuildContext context, RenderHeldReader renderObject) {
    renderObject.configure(this);
  }
}

class HeldParentData extends ContainerBoxParentData<RenderBox> {}

class RenderHeldReader extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, HeldParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, HeldParentData> {
  HeldMetrics _metrics = HeldMetrics.forWidth(1440)!;
  double _viewportHeight = 900;
  List<HeldEntry> _entries = const [];
  List<HeldFigure> _figures = const [];
  ValueChanged<Set<int>>? _onOverCap;
  ValueChanged<PlacementResult>? _onLaidOut;
  PlacementResult? _result;
  Set<int> _reportedOver = {};

  /// The last result, for tests and for the page.
  PlacementResult? get result => _result;

  void configure(HeldReader widget) {
    _onOverCap = widget.onOverCap;
    _onLaidOut = widget.onLaidOut;
    final changed = _metrics.textWidth != widget.metrics.textWidth ||
        _metrics.figureLeft != widget.metrics.figureLeft ||
        _viewportHeight != widget.viewportHeight ||
        _entries.length != widget.entries.length ||
        _figures.length != widget.figures.length ||
        !_sameMeta(widget.entries) ||
        !_sameFigures(widget.figures);
    _metrics = widget.metrics;
    _viewportHeight = widget.viewportHeight;
    _entries = widget.entries;
    _figures = widget.figures;
    if (changed) markNeedsLayout();
  }

  bool _sameMeta(List<HeldEntry> next) {
    for (var i = 0; i < next.length && i < _entries.length; i++) {
      final a = _entries[i];
      final b = next[i];
      if (a.kind != b.kind ||
          a.above != b.above ||
          a.below != b.below ||
          a.list != b.list) {
        return false;
      }
    }
    return true;
  }

  bool _sameFigures(List<HeldFigure> next) {
    for (var i = 0; i < next.length && i < _figures.length; i++) {
      final a = _figures[i];
      final b = next[i];
      if (a.id != b.id ||
          a.anchorStart != b.anchorStart ||
          a.anchorEnd != b.anchorEnd ||
          a.blockStart != b.blockStart ||
          a.example != b.example) {
        return false;
      }
    }
    return true;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! HeldParentData) {
      child.parentData = HeldParentData();
    }
  }

  List<RenderBox> get _children {
    final out = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      out.add(child);
      child = childAfter(child);
    }
    return out;
  }

  @override
  void performLayout() {
    final all = _children;
    final m = _metrics;
    // Plates first: their heights decide the example cards' least height.
    final plateHeights = <double>[];
    for (var i = 0; i < _figures.length; i++) {
      final box = all[_entries.length + i]
        ..layout(
          BoxConstraints.tightFor(width: m.figureWidth),
          parentUsesSize: true,
        );
      plateHeights.add(box.size.height);
    }
    final exampleHeight = <int, double>{};
    for (var i = 0; i < _figures.length; i++) {
      final f = _figures[i];
      if (f.example) {
        exampleHeight[f.anchorStart] = math.max(
          exampleHeight[f.anchorStart] ?? 0,
          plateHeights[i],
        );
      }
    }
    final flow = <FlowEntry>[];
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      final box = all[i];
      final least = exampleHeight[i] ?? 0;
      box.layout(
        BoxConstraints(
          minWidth: m.textWidth,
          maxWidth: m.textWidth,
          minHeight: least,
        ),
        parentUsesSize: true,
      );
      flow.add(
        FlowEntry(
          kind: e.kind,
          height: box.size.height,
          above: e.above,
          below: e.below,
          list: e.list,
        ),
      );
    }
    final result = placeFigures(
      entries: flow,
      figures: [
        for (var i = 0; i < _figures.length; i++)
          MarginFigure(
            id: _figures[i].id,
            height: _figures[i].example
                ? exampleHeight[_figures[i].anchorStart]!
                : plateHeights[i],
            anchorStart: _figures[i].anchorStart,
            anchorEnd: _figures[i].anchorEnd,
            blockStart: _figures[i].blockStart,
            example: _figures[i].example,
          ),
      ],
      viewportHeight: _viewportHeight,
    );
    _result = result;
    for (var i = 0; i < _entries.length; i++) {
      (all[i].parentData! as HeldParentData).offset =
          Offset(m.pageLeft, result.entryTops[i]);
    }
    for (var i = 0; i < _figures.length; i++) {
      (all[_entries.length + i].parentData! as HeldParentData).offset =
          Offset(m.figureLeft, result.figures[_figures[i].id]!.top);
    }
    size = constraints.constrain(
      Size(constraints.maxWidth, result.totalHeight),
    );
    final over = result.overCap;
    if (!_sameSet(over, _reportedOver)) {
      _reportedOver = {...over};
      if (over.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (attached) _onOverCap?.call(over);
        });
      }
    }
    final laidOut = _onLaidOut;
    if (laidOut != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (attached) laidOut(result);
      });
    }
  }

  bool _sameSet(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  /// Where the window's top is, in this object's own coordinates. Read at
  /// paint and hit test time, so it is the scroll of the frame being drawn.
  double _viewportTop() {
    final viewport = RenderAbstractViewport.maybeOf(this);
    if (viewport == null) return double.negativeInfinity;
    final transform = getTransformTo(viewport as RenderObject);
    return -transform.getTranslation().y;
  }

  double _heldDy(int figureIndex, double viewportTop) {
    final placement = _result?.figures[_figures[figureIndex].id];
    if (placement == null || !viewportTop.isFinite) return 0;
    final group = _result!.groups[placement.group];
    return heldOffset(
      restTop: group.top,
      bottom: group.bottom,
      passageEnd: group.passageEnd,
      viewportTop: viewportTop,
    );
  }

  Offset _plateOffset(RenderBox child, int figureIndex, double viewportTop) {
    final rest = (child.parentData! as HeldParentData).offset;
    return rest + Offset(0, _heldDy(figureIndex, viewportTop));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final all = _children;
    for (var i = 0; i < _entries.length; i++) {
      final data = all[i].parentData! as HeldParentData;
      context.paintChild(all[i], offset + data.offset);
    }
    final top = _viewportTop();
    for (var i = 0; i < _figures.length; i++) {
      final box = all[_entries.length + i];
      context.paintChild(box, offset + _plateOffset(box, i, top));
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final all = _children;
    final index = all.indexOf(child);
    final data = child.parentData! as HeldParentData;
    var offset = data.offset;
    if (index >= _entries.length) {
      offset = _plateOffset(child, index - _entries.length, _viewportTop());
    }
    transform.translateByDouble(offset.dx, offset.dy, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final all = _children;
    final top = _viewportTop();
    for (var i = all.length - 1; i >= 0; i--) {
      final child = all[i];
      final offset = i >= _entries.length
          ? _plateOffset(child, i - _entries.length, top)
          : (child.parentData! as HeldParentData).offset;
      final hit = result.addWithPaintOffset(
        offset: offset,
        position: position,
        hitTest: (result, transformed) =>
            child.hitTest(result, position: transformed),
      );
      if (hit) return true;
    }
    return false;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(Size(constraints.maxWidth, 0));
}
