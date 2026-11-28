import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/pulley_system_figure.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

/// Records what a painter draws, with the canvas offset applied, so a test
/// can ask where the rope runs instead of matching call order.
class _Recorder implements Canvas {
  final List<Offset> _origins = [Offset.zero];
  final List<List<Offset>> ropes = [];
  final List<List<Offset>> filledShapes = [];
  final List<(Offset, Offset)> lines = [];
  final List<(Offset, double, bool)> circles = [];
  final List<Rect> rects = [];

  Offset get _o => _origins.last;

  @override
  void save() => _origins.add(_o);

  @override
  void restore() => _origins.removeLast();

  @override
  void translate(double dx, double dy) =>
      _origins[_origins.length - 1] = _o + Offset(dx, dy);

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) =>
      lines.add((p1 + _o, p2 + _o));

  @override
  void drawCircle(Offset c, double radius, Paint paint) =>
      circles.add((c + _o, radius, paint.style == PaintingStyle.fill));

  @override
  void drawRect(Rect rect, Paint paint) => rects.add(rect.shift(_o));

  @override
  void drawPath(Path path, Paint paint) {
    final points = <Offset>[];
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d <= metric.length; d += 0.5) {
        points.add(metric.getTangentForOffset(d)!.position + _o);
      }
      points.add(metric.getTangentForOffset(metric.length)!.position + _o);
    }
    (paint.style == PaintingStyle.fill ? filledShapes : ropes).add(points);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<_Recorder> _draw(
  WidgetTester tester,
  PulleySystemFigure figure, {
  double width = 800,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: [PantasColors.light, PantasTypeBundle.create()],
      ),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: figure),
        ),
      ),
    ),
  );
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(PulleySystemFigure),
      matching: find.byType(CustomPaint),
    ),
  );
  final recorder = _Recorder();
  paint.painter!.paint(recorder, Size(width, 150));
  return recorder;
}

bool _touches(List<Offset> points, Offset target, [double tolerance = 0.75]) =>
    points.any((p) => (p - target).distance <= tolerance);

/// The one rope: the longest stroked path.
List<Offset> _rope(_Recorder r) =>
    r.ropes.reduce((a, b) => a.length >= b.length ? a : b);

const _radius = 15.0;
const _beamY = 12.0;
const _fixedY = _beamY + 10 + _radius;
const _axleY = _beamY + 46.0;
const _loadTop = 150.0 - 34;

/// The filled arrowhead centred on [x].
List<Offset> _arrowhead(_Recorder r, {required double x}) =>
    r.filledShapes.singleWhere(
      (s) =>
          (s.map((p) => p.dx).reduce((a, b) => a + b) / s.length - x).abs() < 3,
    );

void _expectFixedPanel(_Recorder r, double cx) {
  final left = cx - _radius;
  final right = cx + _radius;
  final rope = _rope(r);

  // One continuous rope: over the top of the wheel and down both tangents.
  expect(_touches(rope, Offset(cx, _fixedY - _radius)), isTrue, reason: 'top');
  expect(_touches(rope, Offset(left, _fixedY + 20)), isTrue, reason: 'left');
  expect(_touches(rope, Offset(right, _fixedY + 20)), isTrue, reason: 'right');
  // It does not pass under the wheel.
  expect(
    rope.any((p) => (p.dx - cx).abs() < 10 && p.dy > _fixedY + 1),
    isFalse,
    reason: 'rope under the wheel',
  );

  // The wheel hangs from the beam.
  expect(
    r.lines.any(
      (l) =>
          l.$1 == Offset(cx, _beamY) &&
          l.$2.dx == cx &&
          l.$2.dy >= _fixedY - 15,
    ),
    isTrue,
    reason: 'hanger',
  );

  // The load hangs beneath the left tangent, joined to the rope.
  final load = r.rects.singleWhere((rect) => rect.top == _loadTop);
  expect(load.center.dx, left);
  expect(_touches(rope, Offset(left, load.top)), isTrue, reason: 'connector');

  // The hanging end opposite the load carries a downward effort arrow.
  final arrow = _arrowhead(r, x: right);
  final tip = arrow.reduce((a, b) => a.dy >= b.dy ? a : b);
  expect((tip.dx - right).abs(), lessThan(0.75));
  expect(arrow.where((p) => p.dy < tip.dy - 3), isNotEmpty);
  expect(tip.dy, greaterThan(_fixedY + 20));
  expect(tip.dy, lessThan(_loadTop + 24));
  expect(load.center.dx, lessThan(tip.dx));
}

void _expectMovablePanel(_Recorder r, double cx) {
  final left = cx - _radius;
  final right = cx + _radius;
  final rope = _rope(r);

  // One leg is fixed to a marked anchor on the beam.
  expect(
    r.circles.any((c) => c.$1 == Offset(left, _beamY) && c.$3),
    isTrue,
    reason: 'anchor',
  );
  expect(_touches(rope, Offset(left, _beamY)), isTrue, reason: 'leg top');
  expect(_touches(rope, Offset(left, _axleY)), isTrue, reason: 'left tangent');

  // The rope runs around the lower half of the wheel...
  expect(
    _touches(rope, Offset(cx, _axleY + _radius)),
    isTrue,
    reason: 'under the wheel',
  );
  // ...and not over the top of it.
  expect(
    rope.any((p) => (p.dx - cx).abs() < 10 && p.dy < _axleY - 1),
    isFalse,
    reason: 'rope over the wheel',
  );

  // The other tangent rises to a free end that stops short of the beam.
  expect(_touches(rope, Offset(right, _axleY)), isTrue, reason: 'right');
  expect(_touches(rope, Offset(right, _axleY - 20)), isTrue, reason: 'rises');
  final freeEnd =
      rope.where((p) => (p.dx - right).abs() < 0.75).map((p) => p.dy);
  expect(freeEnd.reduce(math.min), greaterThan(_beamY + 8), reason: 'free');

  // An upward pull arrow marks the free end.
  final arrow = _arrowhead(r, x: right);
  final tip = arrow.reduce((a, b) => a.dy <= b.dy ? a : b);
  expect((tip.dx - right).abs(), lessThan(0.75));
  expect(arrow.where((p) => p.dy > tip.dy + 3), isNotEmpty);
  expect(tip.dy, greaterThan(_beamY + 8));

  // The load connector starts at the axle or the rim, with no gap.
  final connector = r.lines.singleWhere(
    (l) => l.$1.dx == cx && l.$2.dx == cx && l.$2.dy == _loadTop,
  );
  expect(connector.$1.dy, lessThanOrEqualTo(_axleY + _radius));
  expect(connector.$1.dy, greaterThanOrEqualTo(_axleY - 1));
  expect(r.rects.singleWhere((rect) => rect.top == _loadTop).center.dx, cx);
}

void main() {
  group('single fixed pulley rope', () {
    testWidgets('runs over the wheel with a downward effort arrow', (
      tester,
    ) async {
      final r = await _draw(
        tester,
        const PulleySystemFigure(fixed: 1, movable: 0, comparison: false),
      );
      _expectFixedPanel(r, 400);
    });

    testWidgets('is the left panel of the comparison', (tester) async {
      final r = await _draw(
        tester,
        const PulleySystemFigure(fixed: 1, movable: 1, comparison: true),
      );
      // The left half is drawn first and is centred at a quarter of the width.
      final left = _Recorder()
        ..ropes.addAll(
          r.ropes.where((s) => s.every((p) => p.dx < 400)),
        )
        ..filledShapes.addAll(
          r.filledShapes.where((s) => s.every((p) => p.dx < 400)),
        )
        ..lines.addAll(r.lines.where((l) => l.$1.dx < 400))
        ..rects.addAll(r.rects.where((rect) => rect.center.dx < 400));
      _expectFixedPanel(left, 200);
    });
  });

  group('single movable pulley rope', () {
    testWidgets('hangs from an anchor and ends in an upward pull', (
      tester,
    ) async {
      final r = await _draw(
        tester,
        const PulleySystemFigure(fixed: 0, movable: 1, comparison: false),
      );
      _expectMovablePanel(r, 400);
    });

    testWidgets('is the right panel of the comparison', (tester) async {
      final r = await _draw(
        tester,
        const PulleySystemFigure(fixed: 1, movable: 1, comparison: true),
      );
      final right = _Recorder()
        ..ropes.addAll(
          r.ropes.where((s) => s.every((p) => p.dx > 400)),
        )
        ..filledShapes.addAll(
          r.filledShapes.where((s) => s.every((p) => p.dx > 400)),
        )
        ..lines.addAll(r.lines.where((l) => l.$1.dx > 400))
        ..circles.addAll(r.circles.where((c) => c.$1.dx > 400))
        ..rects.addAll(r.rects.where((rect) => rect.center.dx > 400));
      _expectMovablePanel(right, 600);
    });

    testWidgets('stays inside a phone-width panel', (tester) async {
      final r = await _draw(
        tester,
        const PulleySystemFigure(fixed: 1, movable: 1, comparison: true),
        width: 342,
      );
      final all = [...r.ropes, ...r.filledShapes].expand((s) => s);
      expect(all.every((p) => p.dx >= 0 && p.dx <= 342), isTrue);
    });
  });

  testWidgets('a fixed pulley with a movable one keeps its two support legs', (
    tester,
  ) async {
    final r = await _draw(
      tester,
      const PulleySystemFigure(fixed: 1, movable: 1, comparison: false),
    );
    const movableY = _beamY + 46.0 + _radius * 1.6;
    final legs = r.lines.where(
      (l) => l.$1.dy == movableY && l.$1.dx == l.$2.dx && l.$2.dy < movableY,
    );
    expect(legs, hasLength(2));
  });
}
