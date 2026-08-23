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

  static PhysicsMechanicsDiagramFigure? fromSpec(Map<String, Object?> spec) {
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
      case 'buoyancy-comparison':
        _paintBuoyancy(canvas, size);
      case 'kepler-equal-areas':
        _paintKeplerEqualAreas(canvas, size);
      case 'orbital-speed':
        _paintOrbitalSpeed(canvas, size);
      case 'accelerated-motion':
        _paintAcceleratedMotion(canvas, size);
      case 'impulse-duration':
        _paintImpulse(canvas, size);
      case 'mechanical-energy':
        _paintMechanicalEnergy(canvas, size);
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
        const tableY = 127.0;
        final book = Rect.fromCenter(
          center: Offset(x0 + slot / 2, tableY - 20),
          width: 48,
          height: 20,
        );
        canvas
          ..drawRect(book, _stroke)
          ..drawLine(
            Offset(book.left + 8, book.top + 5),
            Offset(book.right - 8, book.top + 5),
            _faint,
          )
          ..drawLine(
            Offset(x0 + 18, tableY),
            Offset(x0 + slot - 18, tableY),
            _stroke,
          )
          ..drawLine(
            Offset(x0 + 28, tableY),
            Offset(x0 + 24, tableY + 12),
            _stroke,
          )
          ..drawLine(
            Offset(x0 + slot - 28, tableY),
            Offset(x0 + slot - 24, tableY + 12),
            _stroke,
          );
        _arrow(
          canvas,
          Offset(book.center.dx, book.top - 3),
          Offset(book.center.dx, book.top - 36),
          _stroke,
        );
        _arrow(
          canvas,
          Offset(book.center.dx, book.bottom + 3),
          Offset(book.center.dx, book.bottom + 36),
          _stroke,
        );
        _label(
          canvas,
          'balanced forces',
          Offset(x0 + 8, 153),
          slot - 16,
          style: mutedStyle,
          align: TextAlign.center,
        );
      } else if (i == 1) {
        final cart = Rect.fromLTWH(x0 + slot * 0.35, 95, slot * 0.38, 34);
        canvas
          ..drawRect(cart, _stroke)
          ..drawLine(
            Offset(cart.left + 5, cart.top + 8),
            Offset(cart.right - 5, cart.top + 8),
            _faint,
          )
          ..drawCircle(Offset(cart.left + 10, cart.bottom + 7), 6, _stroke)
          ..drawCircle(Offset(cart.right - 10, cart.bottom + 7), 6, _stroke);
        final palm = Rect.fromCenter(
          center: Offset(cart.left - 13, cart.center.dy + 1),
          width: 17,
          height: 22,
        );
        canvas
          ..drawArc(palm, -math.pi / 2, math.pi, false, _stroke)
          ..drawLine(
            Offset(palm.left, palm.top + 3),
            Offset(palm.left - 12, palm.top - 5),
            _stroke,
          )
          ..drawLine(
            Offset(palm.left, palm.center.dy),
            Offset(palm.left - 15, palm.center.dy - 2),
            _stroke,
          )
          ..drawLine(
            Offset(palm.left, palm.bottom - 3),
            Offset(palm.left - 11, palm.bottom + 5),
            _stroke,
          )
          ..drawLine(
            Offset(palm.right, palm.top + 4),
            Offset(cart.left, palm.top + 4),
            _stroke,
          )
          ..drawLine(
            Offset(palm.right, palm.center.dy),
            Offset(cart.left, palm.center.dy),
            _stroke,
          );
        _arrow(
          canvas,
          Offset(x0 + 12, cart.center.dy),
          Offset(cart.left - 3, cart.center.dy),
          _stroke,
        );
        _arrow(
          canvas,
          Offset(cart.right + 4, cart.center.dy),
          Offset(x0 + slot - 10, cart.center.dy),
          Paint()
            ..color = board
            ..strokeWidth = 1.5,
        );
        _label(
          canvas,
          'force',
          Offset(x0 + 4, 72),
          slot * 0.30,
          style: mutedStyle,
          align: TextAlign.center,
        );
        _label(
          canvas,
          'acceleration',
          Offset(x0 + slot * 0.66, 72),
          slot * 0.32,
          style: labelStyle.copyWith(color: board),
          align: TextAlign.center,
        );
      } else {
        final swimmer = Offset(x0 + slot * 0.50, 103);
        canvas
          ..drawCircle(Offset(swimmer.dx, swimmer.dy - 22), 7, _stroke)
          ..drawLine(
            Offset(swimmer.dx, swimmer.dy - 15),
            Offset(swimmer.dx, swimmer.dy + 12),
            _stroke,
          )
          ..drawLine(
            Offset(swimmer.dx, swimmer.dy - 4),
            Offset(swimmer.dx - 20, swimmer.dy + 4),
            _stroke,
          )
          ..drawLine(
            Offset(swimmer.dx, swimmer.dy - 4),
            Offset(swimmer.dx + 20, swimmer.dy + 4),
            _stroke,
          )
          ..drawLine(
            Offset(x0 + 10, swimmer.dy + 25),
            Offset(x0 + slot - 10, swimmer.dy + 25),
            _faint,
          );
        for (var wave = 0; wave < 3; wave++) {
          final waveY = swimmer.dy + 22 + wave * 8;
          canvas.drawArc(
            Rect.fromLTWH(x0 + 10, waveY - 4, slot - 20, 8),
            math.pi,
            math.pi,
            false,
            _faint,
          );
        }
        _arrow(
          canvas,
          Offset(swimmer.dx - 20, swimmer.dy + 4),
          Offset(x0 + 18, swimmer.dy + 4),
          _stroke,
        );
        _arrow(
          canvas,
          Offset(swimmer.dx + 20, swimmer.dy - 4),
          Offset(x0 + slot - 18, swimmer.dy - 4),
          _stroke,
        );
        _label(
          canvas,
          'swimmer on water',
          Offset(x0 + 4, 145),
          slot * 0.47,
          style: mutedStyle,
          align: TextAlign.center,
        );
        _label(
          canvas,
          'water on swimmer',
          Offset(x0 + slot * 0.51, 145),
          slot * 0.45,
          style: mutedStyle,
          align: TextAlign.center,
        );
        _label(
          canvas,
          'equal and opposite',
          Offset(x0 + 7, 177),
          slot - 14,
          style: mutedStyle,
          align: TextAlign.center,
        );
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
        ..drawLine(
          Offset(tank.left, 72),
          Offset(tank.right, 72),
          Paint()
            ..color = board
            ..strokeWidth = 1.4,
        );
      for (var wave = 0; wave < 3; wave++) {
        final waveX = tank.left + 12 + wave * 22;
        canvas.drawArc(
          Rect.fromLTWH(waveX, 68, 18, 7),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = board
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
      final objectY = i == 0 ? 68.0 : 126.0;
      final object = Rect.fromCenter(
        center: Offset(tank.center.dx, objectY),
        width: 44,
        height: 30,
      );
      canvas.drawRect(object, _stroke);
      final upLength = i == 0 ? 42.0 : 26.0;
      const downLength = 42.0;
      _arrow(
        canvas,
        Offset(object.center.dx, object.top),
        Offset(object.center.dx, object.top - upLength),
        Paint()
          ..color = board
          ..strokeWidth = 1.5,
      );
      _arrow(
        canvas,
        Offset(object.center.dx, object.bottom),
        Offset(object.center.dx, object.bottom + downLength),
        Paint()
          ..color = rust
          ..strokeWidth = 1.5,
      );
      _label(
        canvas,
        'B',
        Offset(object.center.dx - 22, object.top - upLength / 2 - 6),
        16,
        style: labelStyle.copyWith(color: board),
        align: TextAlign.center,
        maxLines: 1,
      );
      _label(
        canvas,
        'W',
        Offset(object.center.dx + 7, object.bottom + downLength / 2 - 6),
        16,
        style: labelStyle.copyWith(color: rust),
        align: TextAlign.center,
        maxLines: 1,
      );
      _label(
        canvas,
        cases[i]['state']! as String,
        Offset(slot * i + 6, 9),
        slot - 12,
        align: TextAlign.center,
      );
      _label(
        canvas,
        cases[i]['density']! as String,
        Offset(slot * i + 8, 166),
        slot - 16,
        style: mutedStyle,
        align: TextAlign.center,
      );
      _label(
        canvas,
        'buoyant force ${cases[i]['buoyantForce']}',
        Offset(slot * i + 8, 187),
        slot - 16,
        style: mutedStyle,
        align: TextAlign.center,
      );
    }
  }

  void _paintKeplerEqualAreas(Canvas canvas, Size size) {
    final orbitWidth = size.width * 0.72;
    final orbitHeight = math.min(size.height * 0.54, orbitWidth * 0.62);
    final orbitRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.47),
      width: orbitWidth,
      height: orbitHeight,
    );
    final a = orbitRect.width / 2;
    final b = orbitRect.height / 2;
    final c = math.sqrt(a * a - b * b);
    final eccentricity = c / a;
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

    const farHalfSpan = 0.16;
    final nearHalfSpan = _equalAreaNearHalfSpan(eccentricity, farHalfSpan);
    final nearStartAngle = math.pi - nearHalfSpan;
    final nearEndAngle = math.pi + nearHalfSpan;
    const farStartAngle = -farHalfSpan;
    const farEndAngle = farHalfSpan;

    final nearStart = _ellipsePoint(orbitRect, nearStartAngle);
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
      ..drawPath(farSector, sectorStroke)
      ..drawCircle(farStart, 3.5, Paint()..color = board)
      ..drawCircle(farEnd, 3.5, Paint()..color = board)
      ..drawCircle(_ellipsePoint(orbitRect, math.pi), 5, Paint()..color = ink)
      ..drawCircle(_ellipsePoint(orbitRect, 0), 5, Paint()..color = ink);
    _drawSun(canvas, sun);
    _label(
      canvas,
      'Sun',
      Offset(sun.dx - 18, orbitRect.bottom + 2),
      36,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
      maxLines: 1,
    );
    _label(
      canvas,
      'near Sun\nlonger arc • faster',
      const Offset(4, 18),
      size.width * 0.30,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'far from Sun\nshorter arc • slower',
      Offset(size.width * 0.69, 18),
      size.width * 0.30,
      style: labelStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'equal time • equal swept area',
      Offset(size.width * 0.29, size.height - 28),
      size.width * 0.42,
      style: mutedStyle,
      align: TextAlign.center,
    );
  }

  void _paintOrbitalSpeed(Canvas canvas, Size size) {
    final orbitWidth = size.width * 0.74;
    final orbitHeight = math.min<double>(118, orbitWidth * 0.62);
    final orbitRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, 103),
      width: orbitWidth,
      height: orbitHeight,
    );
    final a = orbitRect.width / 2;
    final b = orbitRect.height / 2;
    final c = math.sqrt(a * a - b * b);
    final sun = Offset(orbitRect.center.dx - c, orbitRect.center.dy);
    canvas.drawOval(orbitRect, _stroke);
    _drawSun(canvas, sun);
    final perihelion = _ellipsePoint(orbitRect, math.pi);
    final aphelion = _ellipsePoint(orbitRect, 0);
    canvas
      ..drawCircle(perihelion, 5, Paint()..color = ink)
      ..drawCircle(aphelion, 5, Paint()..color = ink);
    _arrow(
      canvas,
      Offset(perihelion.dx, perihelion.dy - 9),
      Offset(perihelion.dx, perihelion.dy - 59),
      Paint()
        ..color = board
        ..strokeWidth = 1.6,
    );
    _arrow(
      canvas,
      Offset(aphelion.dx, aphelion.dy - 9),
      Offset(aphelion.dx, aphelion.dy - 32),
      _stroke,
    );
    _label(
      canvas,
      'perihelion\nfast',
      const Offset(5, 18),
      size.width * 0.24,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'Sun',
      Offset(sun.dx - 44, sun.dy - 7),
      40,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.right,
      maxLines: 1,
    );
    _label(
      canvas,
      'aphelion\nslow',
      Offset(size.width * 0.76, 18),
      size.width * 0.23,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'long velocity arrow',
      const Offset(4, 171),
      size.width * 0.31,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'short velocity arrow',
      Offset(size.width * 0.69, 171),
      size.width * 0.30,
      style: mutedStyle,
      align: TextAlign.center,
    );
  }

  void _paintAcceleratedMotion(Canvas canvas, Size size) {
    const roadY = 143.0;
    canvas
      ..drawLine(
        const Offset(15, roadY),
        Offset(size.width - 15, roadY),
        _stroke,
      )
      ..drawLine(
        const Offset(15, roadY + 22),
        Offset(size.width - 15, roadY + 22),
        _faint,
      );
    final xs = <double>[
      size.width * 0.18,
      size.width * 0.48,
      size.width * 0.78,
    ];
    final arrowLengths = <double>[28, 50, 58];
    for (var i = 0; i < xs.length; i++) {
      final velocityArrowPaint = i == 2
          ? (Paint()
            ..color = board
            ..strokeWidth = 1.5)
          : _stroke;
      final car = Rect.fromCenter(
        center: Offset(xs[i], roadY - 17),
        width: 48,
        height: 24,
      );
      _drawCar(canvas, car);
      _arrow(
        canvas,
        Offset(car.right + 3, car.center.dy),
        Offset(car.right + 3 + arrowLengths[i], car.center.dy),
        velocityArrowPaint,
      );
      _label(
        canvas,
        'v${String.fromCharCode(0x2081 + i)}',
        Offset(xs[i] - 12, 91),
        24,
        style: mutedStyle,
        align: TextAlign.center,
        maxLines: 1,
      );
    }
    final accelerationPaint = Paint()
      ..color = board
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final accelerationStart = Offset(size.width * 0.22, 42);
    final accelerationEnd = Offset(size.width * 0.78, 42);
    final accelerationControl = Offset(size.width * 0.50, 10);
    final accelerationPath = Path()
      ..moveTo(accelerationStart.dx, accelerationStart.dy)
      ..quadraticBezierTo(
        accelerationControl.dx,
        accelerationControl.dy,
        accelerationEnd.dx,
        accelerationEnd.dy,
      );
    canvas.drawPath(accelerationPath, accelerationPaint);
    final tangent = accelerationEnd - accelerationControl;
    final tangentLength = tangent.distance;
    final unit = tangent / tangentLength;
    final normal = Offset(-unit.dy, unit.dx);
    canvas
      ..drawLine(
        accelerationEnd,
        accelerationEnd - unit * 9 + normal * 4,
        accelerationPaint,
      )
      ..drawLine(
        accelerationEnd,
        accelerationEnd - unit * 9 - normal * 4,
        accelerationPaint,
      );
    _label(
      canvas,
      'constant acceleration',
      Offset(size.width * 0.32, 8),
      size.width * 0.36,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
  }

  void _paintImpulse(Canvas canvas, Size size) {
    final cases = _mapList(spec['cases'])!;
    final slot = size.width / 2;
    for (var i = 0; i < cases.length; i++) {
      final x0 = slot * i;
      _label(
        canvas,
        cases[i]['surface']! as String,
        Offset(x0 + 4, 9),
        slot - 8,
        align: TextAlign.center,
      );
      const handY = 102.0;
      final handContactX = x0 + slot * 0.48;
      _drawHand(
        canvas,
        center: Offset(x0 + slot * 0.29, handY),
        contactX: handContactX,
      );
      if (i == 0) {
        final wallX = x0 + slot * 0.72;
        canvas.drawRect(Rect.fromLTWH(wallX, 65, 7, 78), _stroke);
        for (var hatch = 0; hatch < 5; hatch++) {
          final hatchY = 70 + hatch * 15.0;
          canvas.drawLine(
            Offset(wallX, hatchY),
            Offset(wallX + 7, hatchY + 7),
            _faint,
          );
        }
        _arrow(
          canvas,
          Offset(handContactX, handY),
          Offset(wallX - 2, handY),
          Paint()
            ..color = rust
            ..strokeWidth = 2.4,
        );
      } else {
        final bag = Rect.fromCenter(
          center: Offset(x0 + slot * 0.73, handY),
          width: 68,
          height: 82,
        );
        _drawAirbag(canvas, bag);
        _arrow(
          canvas,
          Offset(handContactX, handY),
          Offset(bag.left + 7, handY),
          _stroke,
        );
      }
      _label(
        canvas,
        '${cases[i]['force']} force',
        Offset(x0 + 8, 154),
        slot - 16,
        style: i == 0
            ? labelStyle.copyWith(color: rust)
            : labelStyle.copyWith(color: board),
        align: TextAlign.center,
      );
      _label(
        canvas,
        '${cases[i]['time']} time',
        Offset(x0 + 8, 176),
        slot - 16,
        style: mutedStyle,
        align: TextAlign.center,
      );
    }
    _label(
      canvas,
      'same total impulse',
      Offset(size.width * 0.33, 54),
      size.width * 0.34,
      style: mutedStyle,
      align: TextAlign.center,
    );
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
        ..drawCircle(
          positions[i],
          8,
          Paint()..color = i == 2 ? board : inkMuted,
        );
    }
    _label(
      canvas,
      'PE',
      Offset(size.width * 0.58, 8),
      32,
      style: labelStyle.copyWith(color: board),
      maxLines: 1,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, 11, 8, 8),
      Paint()..color = boardTint,
    );
    _label(
      canvas,
      'KE',
      Offset(size.width * 0.72, 8),
      32,
      style: labelStyle.copyWith(color: rust),
      maxLines: 1,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.69, 11, 8, 8),
      Paint()..color = rust,
    );
    _energyBar(canvas, Offset(size.width * 0.63, 56), 'high', 1, 0);
    _energyBar(canvas, Offset(size.width * 0.75, 56), 'mid', 0.5, 0.5);
    _energyBar(canvas, Offset(size.width * 0.87, 56), 'low', 0, 1);
    _label(
      canvas,
      'total energy constant',
      Offset(size.width * 0.57, 190),
      size.width * 0.40,
      style: mutedStyle,
      align: TextAlign.center,
      maxLines: 1,
    );
  }

  void _drawSun(Canvas canvas, Offset center) {
    final rays = Paint()
      ..color = board
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final inner = Offset(
        center.dx + math.cos(angle) * 10,
        center.dy + math.sin(angle) * 10,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * 14,
        center.dy + math.sin(angle) * 14,
      );
      canvas.drawLine(inner, outer, rays);
    }
    canvas.drawCircle(center, 8, Paint()..color = board);
  }

  void _drawCar(Canvas canvas, Rect car) {
    final body = Path()
      ..moveTo(car.left, car.bottom - 3)
      ..lineTo(car.left + 3, car.top + 8)
      ..lineTo(car.left + 14, car.top + 8)
      ..lineTo(car.left + 21, car.top)
      ..lineTo(car.right - 12, car.top)
      ..lineTo(car.right - 4, car.top + 8)
      ..lineTo(car.right, car.top + 8)
      ..lineTo(car.right, car.bottom - 3)
      ..close();
    canvas
      ..drawPath(body, _stroke)
      ..drawLine(
        Offset(car.left + 22, car.top + 1),
        Offset(car.left + 23, car.top + 8),
        _faint,
      )
      ..drawLine(
        Offset(car.left + 23, car.top + 8),
        Offset(car.right - 5, car.top + 8),
        _faint,
      )
      ..drawCircle(Offset(car.left + 10, car.bottom + 3), 5, _stroke)
      ..drawCircle(Offset(car.right - 10, car.bottom + 3), 5, _stroke);
  }

  void _drawHand(
    Canvas canvas, {
    required Offset center,
    required double contactX,
  }) {
    final palm = Rect.fromCenter(center: center, width: 24, height: 30);
    canvas
      ..drawLine(
        Offset(palm.left - 18, center.dy + 5),
        Offset(palm.left, center.dy + 5),
        _stroke,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(palm, const Radius.circular(5)),
        _stroke,
      );
    for (var finger = 0; finger < 4; finger++) {
      final y = palm.top + 5 + finger * 5.0;
      canvas.drawLine(Offset(palm.right, y), Offset(contactX, y), _stroke);
    }
    canvas.drawLine(
      Offset(palm.right - 2, center.dy + 8),
      Offset(contactX, center.dy + 4),
      _stroke,
    );
  }

  void _drawAirbag(Canvas canvas, Rect bag) {
    final path = Path()
      ..moveTo(bag.left + 18, bag.top)
      ..cubicTo(
        bag.left + 5,
        bag.top + 4,
        bag.left,
        bag.top + 19,
        bag.left + 8,
        bag.center.dy - 13,
      )
      ..cubicTo(
        bag.left + 2,
        bag.center.dy - 5,
        bag.left + 2,
        bag.center.dy + 5,
        bag.left + 8,
        bag.center.dy + 13,
      )
      ..cubicTo(
        bag.left,
        bag.bottom - 19,
        bag.left + 5,
        bag.bottom - 4,
        bag.left + 18,
        bag.bottom,
      )
      ..lineTo(bag.right - 12, bag.bottom)
      ..cubicTo(
        bag.right - 2,
        bag.bottom - 10,
        bag.right - 2,
        bag.top + 10,
        bag.right - 12,
        bag.top,
      )
      ..close();
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = board
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      )
      ..drawLine(
        Offset(bag.left + 16, bag.center.dy - 12),
        Offset(bag.left + 28, bag.center.dy - 4),
        _faint,
      )
      ..drawLine(
        Offset(bag.left + 16, bag.center.dy + 12),
        Offset(bag.left + 28, bag.center.dy + 4),
        _faint,
      );
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
    if (potential > 0) {
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * potential),
        Paint()..color = boardTint,
      );
    }
    if (kinetic > 0) {
      canvas.drawRect(
        Rect.fromLTWH(
          rect.left,
          rect.bottom - rect.height * kinetic,
          rect.width,
          rect.height * kinetic,
        ),
        Paint()..color = rust,
      );
    }
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
    _label(
      canvas,
      label,
      Offset(origin.dx - 9, origin.dy - 20),
      44,
      style: mutedStyle,
      align: TextAlign.center,
      maxLines: 1,
    );
    _label(
      canvas,
      peLabel,
      Offset(origin.dx - 9, rect.bottom + 5),
      44,
      style: mutedStyle,
      align: TextAlign.center,
      maxLines: 1,
    );
    _label(
      canvas,
      keLabel,
      Offset(origin.dx - 9, rect.bottom + 23),
      44,
      style: mutedStyle,
      align: TextAlign.center,
      maxLines: 1,
    );
  }

  double _equalAreaNearHalfSpan(double eccentricity, double farHalfSpan) {
    final target = farHalfSpan + eccentricity * math.sin(farHalfSpan);
    var low = 0.0;
    var high = math.pi - 0.01;
    for (var i = 0; i < 32; i++) {
      final mid = (low + high) / 2;
      final sweptAreaTerm = mid - eccentricity * math.sin(mid);
      if (sweptAreaTerm < target) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return (low + high) / 2;
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
    TextPainter(
      text: TextSpan(text: text, style: style ?? labelStyle),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: maxLines,
    )
      ..layout(maxWidth: width)
      ..paint(canvas, offset);
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
