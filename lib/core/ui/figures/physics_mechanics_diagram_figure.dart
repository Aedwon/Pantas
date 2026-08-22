import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Original mechanics diagrams for the seven physics briefs in original-code-a.
class PhysicsMechanicsDiagramFigure extends StatelessWidget {
  const PhysicsMechanicsDiagramFigure._({
    required this.type,
    required Map<String, Object?> spec,
  }) : _spec = spec;

  static const kind = 'physics-mechanics-diagram';

  final String type;
  final Map<String, Object?> _spec;

  static PhysicsMechanicsDiagramFigure? fromSpec(
    Map<String, Object?> spec,
  ) {
    if (spec['kind'] != kind || !_hasIllustrationKey(spec)) return null;
    final type = spec['type'];
    if (type is! String) return null;

    final valid = switch (type) {
      'newton-laws' => _validNewtonLaws(spec),
      'buoyancy-comparison' => _validBuoyancy(spec),
      'kepler-equal-areas' => _validKeplerEqualAreas(spec),
      'orbital-speed' => _validOrbitalSpeed(spec),
      'accelerated-motion' => _validAcceleratedMotion(spec),
      'impulse-duration' => _validImpulse(spec),
      'mechanical-energy' => _validMechanicalEnergy(spec),
      _ => false,
    };
    if (!valid) return null;

    return PhysicsMechanicsDiagramFigure._(
      type: type,
      spec: Map<String, Object?>.unmodifiable(spec),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: type == 'kepler-equal-areas' ? 230 : 210,
      child: CustomPaint(
        size: Size.infinite,
        painter: _PhysicsMechanicsPainter(
          type: type,
          spec: _spec,
          ink: colors.ink,
          inkMuted: colors.inkMuted,
          rule: colors.ruleFaint,
          board: colors.board,
          boardTint: colors.boardTint,
          rust: colors.rust,
          labelStyle: context.textStyles.bodySmall.copyWith(color: colors.ink),
          mutedStyle: context.textStyles.bodySmall.copyWith(
            color: colors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _PhysicsMechanicsPainter extends CustomPainter {
  _PhysicsMechanicsPainter({
    required this.type,
    required this.spec,
    required this.ink,
    required this.inkMuted,
    required this.rule,
    required this.board,
    required this.boardTint,
    required this.rust,
    required this.labelStyle,
    required this.mutedStyle,
  });

  final String type;
  final Map<String, Object?> spec;
  final Color ink;
  final Color inkMuted;
  final Color rule;
  final Color board;
  final Color boardTint;
  final Color rust;
  final TextStyle labelStyle;
  final TextStyle mutedStyle;

  Paint get _stroke => Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  Paint get _faint => Paint()
    ..color = rule
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'newton-laws':
        _paintNewtonLaws(canvas, size);
        break;
      case 'buoyancy-comparison':
        _paintBuoyancy(canvas, size);
        break;
      case 'kepler-equal-areas':
        _paintKeplerEqualAreas(canvas, size);
        break;
      case 'orbital-speed':
        _paintOrbitalSpeed(canvas, size);
        break;
      case 'accelerated-motion':
        _paintAcceleratedMotion(canvas, size);
        break;
      case 'impulse-duration':
        _paintImpulse(canvas, size);
        break;
      case 'mechanical-energy':
        _paintMechanicalEnergy(canvas, size);
        break;
    }
  }

  void _paintNewtonLaws(Canvas canvas, Size size) {
    final laws = _mapList(spec['laws'])!;
    final slot = size.width / 3;
    for (var i = 0; i < laws.length; i++) {
      final x0 = slot * i;
      _label(
        canvas,
        laws[i]['label']! as String,
        Offset(x0 + 4, 8),
        slot - 8,
        align: TextAlign.center,
      );
      if (i == 0) {
        final tableY = 127.0;
        final book = Rect.fromCenter(
          center: Offset(x0 + slot / 2, tableY - 20),
          width: 48,
          height: 20,
        );
        canvas
          ..drawRect(book, _stroke)
          ..drawLine(Offset(x0 + 18, tableY), Offset(x0 + slot - 18, tableY), _stroke);
        _arrow(canvas, Offset(book.center.dx, book.top - 3), Offset(book.center.dx, book.top - 36), _stroke);
        _arrow(canvas, Offset(book.center.dx, book.bottom + 3), Offset(book.center.dx, book.bottom + 36), _stroke);
        _label(canvas, 'balanced forces', Offset(x0 + 8, 153), slot - 16, style: mutedStyle, align: TextAlign.center);
      } else if (i == 1) {
        final cart = Rect.fromLTWH(x0 + slot * 0.35, 95, slot * 0.38, 34);
        canvas
          ..drawRect(cart, _stroke)
          ..drawCircle(Offset(cart.left + 10, cart.bottom + 7), 6, _stroke)
          ..drawCircle(Offset(cart.right - 10, cart.bottom + 7), 6, _stroke);
        _arrow(canvas, Offset(x0 + 12, cart.center.dy), Offset(cart.left - 3, cart.center.dy), _stroke);
        _arrow(canvas, Offset(cart.right + 4, cart.center.dy), Offset(x0 + slot - 10, cart.center.dy), Paint()..color = board..strokeWidth = 1.5);
        _label(canvas, 'force', Offset(x0 + 4, 72), slot * 0.30, style: mutedStyle, align: TextAlign.center);
        _label(canvas, 'acceleration', Offset(x0 + slot * 0.66, 72), slot * 0.32, style: labelStyle.copyWith(color: board), align: TextAlign.center);
      } else {
        final swimmer = Offset(x0 + slot * 0.50, 103);
        canvas
          ..drawCircle(Offset(swimmer.dx, swimmer.dy - 22), 7, _stroke)
          ..drawLine(Offset(swimmer.dx, swimmer.dy - 15), Offset(swimmer.dx, swimmer.dy + 12), _stroke)
          ..drawLine(Offset(swimmer.dx, swimmer.dy - 4), Offset(swimmer.dx - 20, swimmer.dy + 4), _stroke)
          ..drawLine(Offset(swimmer.dx, swimmer.dy - 4), Offset(swimmer.dx + 20, swimmer.dy + 4), _stroke)
          ..drawLine(Offset(x0 + 10, swimmer.dy + 25), Offset(x0 + slot - 10, swimmer.dy + 25), _faint);
        _arrow(canvas, Offset(swimmer.dx - 5, swimmer.dy + 35), Offset(x0 + 18, swimmer.dy + 35), _stroke);
        _arrow(canvas, Offset(swimmer.dx + 5, swimmer.dy - 42), Offset(x0 + slot - 18, swimmer.dy - 42), _stroke);
        _label(canvas, 'equal and opposite', Offset(x0 + 7, 157), slot - 14, style: mutedStyle, align: TextAlign.center);
      }
    }
  }

  void _paintBuoyancy(Canvas canvas, Size size) {
    final cases = _mapList(spec['cases'])!;
    final slot = size.width / 2;
    for (var i = 0; i < 2; i++) {
      final tank = Rect.fromLTWH(slot * i + 24, 40, slot - 48, 116);
      canvas
        ..drawLine(tank.topLeft, tank.bottomLeft, _stroke)
        ..drawLine(tank.bottomLeft, tank.bottomRight, _stroke)
        ..drawLine(tank.bottomRight, tank.topRight, _stroke)
        ..drawLine(Offset(tank.left, 72), Offset(tank.right, 72), Paint()..color = board..strokeWidth = 1.4);
      final objectY = i == 0 ? 68.0 : 126.0;
      final object = Rect.fromCenter(
        center: Offset(tank.center.dx, objectY),
        width: 44,
        height: 30,
      );
      canvas.drawRect(object, _stroke);
      final upLength = i == 0 ? 42.0 : 26.0;
      final downLength = 42.0;
      _arrow(canvas, Offset(object.center.dx - 8, object.top), Offset(object.center.dx - 8, object.top - upLength), Paint()..color = board..strokeWidth = 1.5);
      _arrow(canvas, Offset(object.center.dx + 8, object.bottom), Offset(object.center.dx + 8, object.bottom + downLength), Paint()..color = rust..strokeWidth = 1.5);
      _label(canvas, cases[i]['state']! as String, Offset(slot * i + 6, 9), slot - 12, align: TextAlign.center);
      _label(canvas, cases[i]['density']! as String, Offset(slot * i + 8, 166), slot - 16, style: mutedStyle, align: TextAlign.center);
      _label(canvas, 'buoyant force ${cases[i]['buoyantForce']}', Offset(slot * i + 8, 187), slot - 16, style: mutedStyle, align: TextAlign.center);
    }
  }

  void _paintKeplerEqualAreas(Canvas canvas, Size size) {
    final orbitRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.47),
      width: size.width * 0.72,
      height: size.height * 0.54,
    );
    final a = orbitRect.width / 2;
    final b = orbitRect.height / 2;
    final c = a * 0.55;
    final sun = Offset(orbitRect.center.dx - c, orbitRect.center.dy);
    final orbitPaint = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final sectorFill = Paint()
      ..color = boardTint
      ..style = PaintingStyle.fill;
    final sectorStroke = Paint()
      ..color = board
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawOval(orbitRect, orbitPaint);

    const nearHalfSpan = 0.80;
    const farHalfSpan = 0.263;
    final nearStartAngle = math.pi - nearHalfSpan;
    final nearEndAngle = math.pi + nearHalfSpan;
    final farStartAngle = -farHalfSpan;
    final farEndAngle = farHalfSpan;

    final nearStart = _ellipsePoint(orbitRect, nearStartAngle);
    final nearEnd = _ellipsePoint(orbitRect, nearEndAngle);
    final nearSector = Path()
      ..moveTo(sun.dx, sun.dy)
      ..lineTo(nearStart.dx, nearStart.dy)
      ..arcTo(orbitRect, nearStartAngle, nearEndAngle - nearStartAngle, false)
      ..close();
    canvas
      ..drawPath(nearSector, sectorFill)
      ..drawPath(nearSector, sectorStroke);

    final farStart = _ellipsePoint(orbitRect, farStartAngle);
    final farEnd = _ellipsePoint(orbitRect, farEndAngle);
    final farSector = Path()
      ..moveTo(sun.dx, sun.dy)
      ..lineTo(farStart.dx, farStart.dy)
      ..arcTo(orbitRect, farStartAngle, farEndAngle - farStartAngle, false)
      ..close();
    canvas
      ..drawPath(farSector, sectorFill)
      ..drawPath(farSector, sectorStroke);

    canvas
      ..drawCircle(sun, 8, Paint()..color = board)
      ..drawCircle(_ellipsePoint(orbitRect, math.pi), 5, Paint()..color = ink)
      ..drawCircle(_ellipsePoint(orbitRect, 0), 5, Paint()..color = ink);
    _label(canvas, 'Sun at one focus', Offset(sun.dx - 48, sun.dy + 12), 96, style: mutedStyle, align: TextAlign.center);
    _label(canvas, 'near Sun\nlonger arc • faster', Offset(4, 18), size.width * 0.30, style: labelStyle.copyWith(color: board), align: TextAlign.center, maxLines: 2);
    _label(canvas, 'far from Sun\nshorter arc • slower', Offset(size.width * 0.69, 18), size.width * 0.30, style: labelStyle, align: TextAlign.center, maxLines: 2);
    _label(canvas, 'equal time • equal swept area', Offset(size.width * 0.29, size.height - 28), size.width * 0.42, style: mutedStyle, align: TextAlign.center);
  }

  void _paintOrbitalSpeed(Canvas canvas, Size size) {
    final orbitRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, 103),
      width: size.width * 0.74,
      height: 118,
    );
    final sun = Offset(orbitRect.center.dx - orbitRect.width * 0.27, orbitRect.center.dy);
    canvas
      ..drawOval(orbitRect, _stroke)
      ..drawCircle(sun, 8, Paint()..color = board);
    final perihelion = _ellipsePoint(orbitRect, math.pi);
    final aphelion = _ellipsePoint(orbitRect, 0);
    canvas
      ..drawCircle(perihelion, 5, Paint()..color = ink)
      ..drawCircle(aphelion, 5, Paint()..color = ink);
    _arrow(canvas, Offset(perihelion.dx, perihelion.dy - 9), Offset(perihelion.dx, perihelion.dy - 59), Paint()..color = board..strokeWidth = 1.6);
    _arrow(canvas, Offset(aphelion.dx, aphelion.dy - 9), Offset(aphelion.dx, aphelion.dy - 32), _stroke);
    _label(canvas, 'perihelion\nfast', Offset(5, 18), size.width * 0.24, style: labelStyle.copyWith(color: board), align: TextAlign.center);
    _label(canvas, 'aphelion\nslow', Offset(size.width * 0.76, 18), size.width * 0.23, align: TextAlign.center);
    _label(canvas, 'long velocity arrow', Offset(4, 171), size.width * 0.31, style: mutedStyle, align: TextAlign.center);
    _label(canvas, 'short velocity arrow', Offset(size.width * 0.69, 171), size.width * 0.30, style: mutedStyle, align: TextAlign.center);
  }

  void _paintAcceleratedMotion(Canvas canvas, Size size) {
    const roadY = 143.0;
    canvas
      ..drawLine(Offset(15, roadY), Offset(size.width - 15, roadY), _stroke)
      ..drawLine(Offset(15, roadY + 22), Offset(size.width - 15, roadY + 22), _faint);
    final xs = <double>[size.width * 0.18, size.width * 0.48, size.width * 0.78];
    final arrowLengths = <double>[30, 52, 74];
    for (var i = 0; i < xs.length; i++) {
      final car = Rect.fromCenter(center: Offset(xs[i], roadY - 17), width: 48, height: 24);
      canvas
        ..drawRect(car, _stroke)
        ..drawCircle(Offset(car.left + 10, car.bottom + 5), 5, _stroke)
        ..drawCircle(Offset(car.right - 10, car.bottom + 5), 5, _stroke);
      _arrow(canvas, Offset(xs[i] - 5, 84), Offset(xs[i] - 5 + arrowLengths[i], 84), i == 2 ? Paint()..color = board..strokeWidth = 1.5 : _stroke);
      _label(canvas, 'v${i + 1}', Offset(xs[i] - 12, 57), 24, style: mutedStyle, align: TextAlign.center);
    }
    _arrow(canvas, Offset(size.width * 0.22, 32), Offset(size.width * 0.78, 32), Paint()..color = board..strokeWidth = 1.5);
    _label(canvas, 'constant acceleration', Offset(size.width * 0.32, 8), size.width * 0.36, style: labelStyle.copyWith(color: board), align: TextAlign.center);
  }

  void _paintImpulse(Canvas canvas, Size size) {
    final cases = _mapList(spec['cases'])!;
    final slot = size.width / 2;
    for (var i = 0; i < cases.length; i++) {
      final x0 = slot * i;
      _label(canvas, cases[i]['surface']! as String, Offset(x0 + 4, 9), slot - 8, align: TextAlign.center);
      final handY = 102.0;
      canvas
        ..drawLine(Offset(x0 + 30, handY), Offset(x0 + slot * 0.48, handY), _stroke)
        ..drawCircle(Offset(x0 + 30, handY), 7, _stroke);
      if (i == 0) {
        canvas.drawLine(Offset(x0 + slot * 0.72, 65), Offset(x0 + slot * 0.72, 143), _stroke);
        _arrow(canvas, Offset(x0 + slot * 0.48, handY), Offset(x0 + slot * 0.70, handY), Paint()..color = rust..strokeWidth = 2.4);
      } else {
        final bag = Rect.fromCenter(center: Offset(x0 + slot * 0.73, handY), width: 68, height: 82);
        canvas.drawOval(bag, Paint()..color = board..style = PaintingStyle.stroke..strokeWidth = 1.5);
        _arrow(canvas, Offset(x0 + slot * 0.48, handY), Offset(x0 + slot * 0.64, handY), _stroke);
      }
      _label(canvas, '${cases[i]['force']} force', Offset(x0 + 8, 154), slot - 16, style: i == 0 ? labelStyle.copyWith(color: rust) : labelStyle.copyWith(color: board), align: TextAlign.center);
      _label(canvas, '${cases[i]['time']} time', Offset(x0 + 8, 176), slot - 16, style: mutedStyle, align: TextAlign.center);
    }
    _label(canvas, 'same total impulse', Offset(size.width * 0.33, 54), size.width * 0.34, style: mutedStyle, align: TextAlign.center);
  }

  void _paintMechanicalEnergy(Canvas canvas, Size size) {
    final pivot = Offset(size.width * 0.50, 28);
    final positions = <Offset>[
      Offset(size.width * 0.22, 94),
      Offset(size.width * 0.36, 137),
      Offset(size.width * 0.50, 156),
    ];
    final arc = Rect.fromCircle(center: pivot, radius: 128);
    canvas.drawArc(arc, math.pi * 0.25, math.pi * 0.50, false, _faint);
    for (var i = 0; i < positions.length; i++) {
      canvas
        ..drawLine(pivot, positions[i], i == 2 ? _stroke : _faint)
        ..drawCircle(positions[i], 8, Paint()..color = i == 2 ? board : inkMuted);
    }
    _energyBar(canvas, Offset(size.width * 0.63, 56), 'high', 1.0, 0.0);
    _energyBar(canvas, Offset(size.width * 0.75, 56), 'mid', 0.5, 0.5);
    _energyBar(canvas, Offset(size.width * 0.87, 56), 'low', 0.0, 1.0);
    _label(canvas, 'total mechanical energy stays constant', Offset(size.width * 0.57, 175), size.width * 0.40, style: mutedStyle, align: TextAlign.center, maxLines: 2);
  }

  void _energyBar(
    Canvas canvas,
    Offset origin,
    String label,
    double potential,
    double kinetic,
  ) {
    const height = 96.0;
    const width = 26.0;
    final rect = Rect.fromLTWH(origin.dx, origin.dy, width, height);
    canvas.drawRect(rect, _stroke);
    if (potential > 0 && potential < 1) {
      canvas.drawLine(
        Offset(rect.left, rect.bottom - height * potential),
        Offset(rect.right, rect.bottom - height * potential),
        _stroke,
      );
    }
    final peLabel = potential == 1
        ? 'PE all'
        : potential == 0
            ? 'PE 0'
            : 'PE +';
    final keLabel = kinetic == 1
        ? 'KE all'
        : kinetic == 0
            ? 'KE 0'
            : 'KE +';
    _label(canvas, label, Offset(origin.dx - 8, origin.dy - 20), 42, style: mutedStyle, align: TextAlign.center);
    _label(canvas, peLabel, Offset(origin.dx - 13, rect.bottom + 5), 52, style: mutedStyle, align: TextAlign.center);
    _label(canvas, keLabel, Offset(origin.dx - 13, rect.bottom + 23), 52, style: mutedStyle, align: TextAlign.center);
  }

  Offset _ellipsePoint(Rect rect, double angle) {
    return Offset(
      rect.center.dx + rect.width / 2 * math.cos(angle),
      rect.center.dy + rect.height / 2 * math.sin(angle),
    );
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
    final delta = to - from;
    final length = delta.distance;
    if (length == 0) return;
    final ux = delta.dx / length;
    final uy = delta.dy / length;
    final left = Offset(to.dx - ux * 8 - uy * 4, to.dy - uy * 8 + ux * 4);
    final right = Offset(to.dx - ux * 8 + uy * 4, to.dy - uy * 8 - ux * 4);
    canvas
      ..drawLine(to, left, paint)
      ..drawLine(to, right, paint);
  }

  void _label(
    Canvas canvas,
    String text,
    Offset offset,
    double width, {
    TextStyle? style,
    TextAlign align = TextAlign.left,
    int maxLines = 2,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style ?? labelStyle),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: maxLines,
    )..layout(maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_PhysicsMechanicsPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.spec.toString() != spec.toString() ||
        oldDelegate.ink != ink ||
        oldDelegate.inkMuted != inkMuted ||
        oldDelegate.rule != rule ||
        oldDelegate.board != board ||
        oldDelegate.boardTint != boardTint ||
        oldDelegate.rust != rust;
  }
}

bool _validNewtonLaws(Map<String, Object?> spec) {
  final laws = _mapList(spec['laws']);
  if (laws == null || laws.length != 3) return false;
  const labels = <String>['first law', 'second law', 'third law'];
  const scenes = <String>[
    'book motionless on table',
    'hand pushing cart',
    'swimmer pushes water backward',
  ];
  const relationships = <String>[
    'balanced forces',
    'force arrow and acceleration arrow',
    'water pushes swimmer forward equally',
  ];
  for (var i = 0; i < laws.length; i++) {
    if (laws[i]['label'] != labels[i] ||
        laws[i]['scene'] != scenes[i] ||
        laws[i]['relationship'] != relationships[i]) {
      return false;
    }
  }
  return true;
}

bool _validBuoyancy(Map<String, Object?> spec) {
  final cases = _mapList(spec['cases']);
  return cases != null &&
      cases.length == 2 &&
      cases[0]['state'] == 'floating' &&
      cases[0]['density'] == 'less dense than water' &&
      cases[0]['buoyantForce'] == 'equal to weight' &&
      cases[1]['state'] == 'sinking' &&
      cases[1]['density'] == 'denser than water' &&
      cases[1]['buoyantForce'] == 'smaller than weight';
}

bool _validKeplerEqualAreas(Map<String, Object?> spec) {
  if (spec['orbit'] != 'ellipse' ||
      spec['sunPosition'] != 'one focus' ||
      spec['interval'] != 'equal time' ||
      spec['areas'] != 'equal') {
    return false;
  }
  final near = _stringObjectMap(spec['near']);
  final far = _stringObjectMap(spec['far']);
  return near != null &&
      far != null &&
      near['arc'] == 'longer' &&
      near['speed'] == 'faster' &&
      far['arc'] == 'shorter' &&
      far['speed'] == 'slower';
}

bool _validOrbitalSpeed(Map<String, Object?> spec) {
  if (spec['orbit'] != 'ellipse' || spec['sunPosition'] != 'one focus') {
    return false;
  }
  final perihelion = _stringObjectMap(spec['perihelion']);
  final aphelion = _stringObjectMap(spec['aphelion']);
  return perihelion != null &&
      aphelion != null &&
      perihelion['distance'] == 'near' &&
      perihelion['velocityArrow'] == 'long' &&
      perihelion['speed'] == 'fast' &&
      aphelion['distance'] == 'far' &&
      aphelion['velocityArrow'] == 'short' &&
      aphelion['speed'] == 'slow';
}

bool _validAcceleratedMotion(Map<String, Object?> spec) {
  return spec['path'] == 'straight road' &&
      spec['moments'] == 3 &&
      spec['velocityTrend'] == 'increasing' &&
      spec['acceleration'] == 'constant';
}

bool _validImpulse(Map<String, Object?> spec) {
  if (spec['impulse'] != 'same') return false;
  final cases = _mapList(spec['cases']);
  return cases != null &&
      cases.length == 2 &&
      cases[0]['surface'] == 'hard surface' &&
      cases[0]['force'] == 'large' &&
      cases[0]['time'] == 'very short' &&
      cases[1]['surface'] == 'airbag' &&
      cases[1]['force'] == 'smaller' &&
      cases[1]['time'] == 'longer';
}

bool _validMechanicalEnergy(Map<String, Object?> spec) {
  if (spec['system'] != 'pendulum' || spec['totalEnergy'] != 'constant') {
    return false;
  }
  final points = _mapList(spec['points']);
  return points != null &&
      points.length == 3 &&
      points[0]['position'] == 'high' &&
      points[0]['potential'] == 'all' &&
      points[0]['kinetic'] == 'zero' &&
      points[1]['position'] == 'midpoint' &&
      points[1]['potential'] == 'some' &&
      points[1]['kinetic'] == 'some' &&
      points[2]['position'] == 'low' &&
      points[2]['potential'] == 'zero' &&
      points[2]['kinetic'] == 'all';
}

bool _hasIllustrationKey(Map<String, Object?> spec) {
  final key = spec['illustrationKey'];
  return key is String && key.trim().isNotEmpty;
}

Map<String, Object?>? _stringObjectMap(Object? value) {
  if (value is! Map) return null;
  for (final key in value.keys) {
    if (key is! String) return null;
  }
  return value.cast<String, Object?>();
}

List<Map<String, Object?>>? _mapList(Object? value) {
  if (value is! List || value.isEmpty) return null;
  final result = <Map<String, Object?>>[];
  for (final item in value) {
    final map = _stringObjectMap(item);
    if (map == null) return null;
    result.add(map);
  }
  return result;
}
