import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Original lesson diagrams for electricity, optics, heat, and sound.
class PhysicsEnergyDiagramFigure extends StatelessWidget {
  const PhysicsEnergyDiagramFigure._({required this.type, required this.spec});

  static const kind = 'physics-energy-diagram';

  static const _types = <String>{
    'electric-field-pairs',
    'series-parallel-circuit',
    'ohms-law-circuit',
    'circuit-failure',
    'lens-comparison',
    'heat-transfer-triptych',
    'doppler-ambulance',
  };

  final String type;
  final Map<String, Object?> spec;

  static PhysicsEnergyDiagramFigure? fromSpec(Map<String, Object?> spec) {
    if (spec['kind'] != kind) return null;
    final type = spec['type'];
    final illustrationKey = spec['illustrationKey'];
    if (type is! String || !_types.contains(type)) return null;
    if (illustrationKey is! String || illustrationKey.trim().isEmpty) {
      return null;
    }

    final valid = switch (type) {
      'electric-field-pairs' => _validElectricFieldPairs(spec),
      'series-parallel-circuit' => _validSeriesParallel(spec),
      'ohms-law-circuit' => _validOhmsLaw(spec),
      'circuit-failure' => _validCircuitFailure(spec),
      'lens-comparison' => _validLensComparison(spec),
      'heat-transfer-triptych' => _validHeatTransfer(spec),
      'doppler-ambulance' => _validDoppler(spec),
      _ => false,
    };
    if (!valid) return null;

    return PhysicsEnergyDiagramFigure._(
      type: type,
      spec: Map<String, Object?>.unmodifiable(spec),
    );
  }

  static bool _validElectricFieldPairs(Map<String, Object?> spec) {
    final cases = _mapList(spec['cases'], length: 2);
    if (cases == null) return false;
    return _stringListEquals(cases[0]['charges'], const [
          'positive',
          'positive',
        ]) &&
        cases[0]['fieldLines'] == 'point away from each' &&
        cases[0]['force'] == 'repel' &&
        _stringListEquals(cases[1]['charges'], const [
          'positive',
          'negative',
        ]) &&
        cases[1]['fieldLines'] == 'connect positive to negative' &&
        cases[1]['force'] == 'attract';
  }

  static bool _validSeriesParallel(Map<String, Object?> spec) {
    return spec['bulbsPerCircuit'] == 2 &&
        spec['seriesPath'] == 'single loop one after another' &&
        spec['parallelPath'] == 'separate side-by-side branches' &&
        spec['batteryShown'] == true;
  }

  static bool _validOhmsLaw(Map<String, Object?> spec) {
    final resistance = spec['resistanceOhms'];
    final current = spec['currentAmps'];
    return resistance is num &&
        resistance.isFinite &&
        resistance == 10 &&
        current is num &&
        current.isFinite &&
        current == 2 &&
        spec['voltageLabel'] == '?';
  }

  static bool _validCircuitFailure(Map<String, Object?> spec) {
    return spec['seriesOutcome'] == 'other bulb goes dark' &&
        spec['parallelOutcome'] == 'other bulb stays lit' &&
        spec['burnedOutBulbsPerCircuit'] == 1;
  }

  static bool _validLensComparison(Map<String, Object?> spec) {
    return spec['convexBehavior'] ==
            'parallel rays bend inward to one focus point' &&
        spec['concaveBehavior'] == 'parallel rays spread outward';
  }

  static bool _validHeatTransfer(Map<String, Object?> spec) {
    final panels = _mapList(spec['panels'], length: 3);
    if (panels == null) return false;
    const expected = <Map<String, String>>[
      {
        'name': 'conduction',
        'scene': 'heat through solid metal rod held over flame',
      },
      {
        'name': 'convection',
        'scene': 'warm fluid rises and cool fluid sinks in heated water',
      },
      {
        'name': 'radiation',
        'scene': 'wavy arrows from Sun through empty space to Earth',
      },
    ];
    for (var i = 0; i < expected.length; i++) {
      for (final entry in expected[i].entries) {
        if (panels[i][entry.key] != entry.value) return false;
      }
    }
    return true;
  }

  static bool _validDoppler(Map<String, Object?> spec) {
    if (spec['source'] != 'moving ambulance') return false;
    final ahead = _map(spec['ahead']);
    final behind = _map(spec['behind']);
    return ahead != null &&
        behind != null &&
        ahead['wavelength'] == 'shorter' &&
        ahead['pitch'] == 'higher' &&
        behind['wavelength'] == 'longer' &&
        behind['pitch'] == 'lower';
  }

  static List<Map<String, Object?>>? _mapList(Object? value, {int? length}) {
    if (value is! List || (length != null && value.length != length)) {
      return null;
    }
    final result = <Map<String, Object?>>[];
    for (final item in value) {
      if (item is! Map) return null;
      result.add(item.cast<String, Object?>());
    }
    return result;
  }

  static Map<String, Object?>? _map(Object? value) {
    if (value is! Map) return null;
    return value.cast<String, Object?>();
  }

  static bool _stringListEquals(Object? value, List<String> expected) {
    if (value is! List || value.length != expected.length) return false;
    for (var i = 0; i < expected.length; i++) {
      if (value[i] != expected[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 250,
      child: CustomPaint(
        size: Size.infinite,
        painter: _PhysicsEnergyPainter(
          type: type,
          ink: colors.label,
          muted: colors.secondaryLabel,
          faint: colors.fill,
          background: colors.background,
          labelStyle: context.type.subhead.copyWith(color: colors.label),
          smallStyle: context.type.subhead.copyWith(
            color: colors.secondaryLabel,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _PhysicsEnergyPainter extends CustomPainter {
  const _PhysicsEnergyPainter({
    required this.type,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.background,
    required this.labelStyle,
    required this.smallStyle,
  });

  final String type;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color background;
  final TextStyle labelStyle;
  final TextStyle smallStyle;

  Paint get _stroke => Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  Paint get _faintStroke => Paint()
    ..color = faint
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Paint get _fill => Paint()
    ..color = background
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'electric-field-pairs':
        _drawElectricFields(canvas, size);
      case 'series-parallel-circuit':
        _drawSeriesParallel(canvas, size, failure: false);
      case 'ohms-law-circuit':
        _drawOhmsLaw(canvas, size);
      case 'circuit-failure':
        _drawSeriesParallel(canvas, size, failure: true);
      case 'lens-comparison':
        _drawLenses(canvas, size);
      case 'heat-transfer-triptych':
        _drawHeatTransfer(canvas, size);
      case 'doppler-ambulance':
        _drawDoppler(canvas, size);
    }
  }

  void _drawElectricFields(Canvas canvas, Size size) {
    final panelWidth = size.width / 2;
    canvas.drawLine(
      Offset(panelWidth, 24),
      Offset(panelWidth, 226),
      _faintStroke,
    );
    _text(
      canvas,
      'like charges repel',
      Offset(panelWidth / 2, 24),
      maxWidth: 120,
    );
    _text(
      canvas,
      'opposite charges attract',
      Offset(panelWidth * 1.5, 24),
      maxWidth: 145,
    );
    _fieldPair(
      canvas,
      Rect.fromLTWH(12, 52, panelWidth - 24, 145),
      positivePair: true,
    );
    _fieldPair(
      canvas,
      Rect.fromLTWH(panelWidth + 12, 52, panelWidth - 24, 145),
      positivePair: false,
    );
  }

  void _fieldPair(Canvas canvas, Rect rect, {required bool positivePair}) {
    final left = Offset(rect.left + rect.width * .3, rect.center.dy);
    final right = Offset(rect.left + rect.width * .7, rect.center.dy);
    _charge(canvas, left, '+');
    _charge(canvas, right, positivePair ? '+' : '-');

    if (positivePair) {
      for (final dy in [-28.0, -14.0, 0.0, 14.0, 28.0]) {
        _arrow(canvas, left + Offset(-14, dy * .25), left + Offset(-50, dy));
        _arrow(canvas, right + Offset(14, dy * .25), right + Offset(50, dy));
      }
      _arrow(canvas, left + const Offset(-5, 49), left + const Offset(-42, 49));
      _arrow(canvas, right + const Offset(5, 49), right + const Offset(42, 49));
      _text(
        canvas,
        'field lines point away',
        Offset(rect.center.dx, rect.bottom - 6),
        maxWidth: 130,
        mutedText: true,
      );
    } else {
      for (final dy in [-26.0, -13.0, 0.0, 13.0, 26.0]) {
        final start = left + Offset(13, dy * .25);
        final end = right + Offset(-13, dy * .25);
        if (dy == 0) {
          _arrow(canvas, start, end);
        } else {
          final control = Offset(
            rect.center.dx,
            rect.center.dy + dy,
          );
          final path = Path()
            ..moveTo(start.dx, start.dy)
            ..quadraticBezierTo(
              control.dx,
              control.dy,
              end.dx,
              end.dy,
            );
          canvas.drawPath(path, _stroke);
          const arrowT = .62;
          const remainingT = 1 - arrowT;
          final arrowPoint = start * (remainingT * remainingT) +
              control * (2 * remainingT * arrowT) +
              end * (arrowT * arrowT);
          final tangent = Offset(
            2 * remainingT * (control.dx - start.dx) +
                2 * arrowT * (end.dx - control.dx),
            2 * remainingT * (control.dy - start.dy) +
                2 * arrowT * (end.dy - control.dy),
          );
          _arrowHead(
            canvas,
            arrowPoint,
            math.atan2(tangent.dy, tangent.dx),
          );
        }
      }
      _text(
        canvas,
        'field lines + to -',
        Offset(rect.center.dx, rect.bottom - 6),
        maxWidth: 112,
        mutedText: true,
      );
    }
  }

  void _drawSeriesParallel(Canvas canvas, Size size, {required bool failure}) {
    final panelWidth = size.width / 2;
    canvas.drawLine(
      Offset(panelWidth, 20),
      Offset(panelWidth, 230),
      _faintStroke,
    );
    _text(canvas, 'series', Offset(panelWidth / 2, 18), maxWidth: 70);
    _text(canvas, 'parallel', Offset(panelWidth * 1.5, 18), maxWidth: 70);
    _seriesCircuit(
      canvas,
      Rect.fromLTWH(18, 50, panelWidth - 36, 145),
      failure: failure,
    );
    _parallelCircuit(
      canvas,
      Rect.fromLTWH(panelWidth + 18, 50, panelWidth - 36, 145),
      failure: failure,
    );
    if (failure) {
      _text(
        canvas,
        'other bulb goes dark',
        Offset(panelWidth / 2, 210),
        maxWidth: 130,
        mutedText: true,
      );
      _text(
        canvas,
        'other bulb stays lit',
        Offset(panelWidth * 1.5, 210),
        maxWidth: 125,
        mutedText: true,
      );
    } else {
      _text(
        canvas,
        'one path',
        Offset(panelWidth / 2, 210),
        maxWidth: 70,
        mutedText: true,
      );
      _text(
        canvas,
        'separate branches',
        Offset(panelWidth * 1.5, 210),
        maxWidth: 110,
        mutedText: true,
      );
    }
  }

  void _seriesCircuit(Canvas canvas, Rect rect, {required bool failure}) {
    final top = rect.top + 20;
    final bottom = rect.bottom - 18;
    final left = rect.left + 18;
    final right = rect.right - 18;
    canvas
      ..drawLine(Offset(left, top), Offset(right, top), _stroke)
      ..drawLine(Offset(right, top), Offset(right, bottom), _stroke)
      ..drawLine(Offset(right, bottom), Offset(left, bottom), _stroke)
      ..drawLine(
        Offset(left, bottom),
        Offset(left, rect.center.dy + 18),
        _stroke,
      )
      ..drawLine(Offset(left, rect.center.dy - 18), Offset(left, top), _stroke);
    _battery(canvas, Offset(left, rect.center.dy));
    final bulb1 = Offset(rect.center.dx - 35, top);
    final bulb2 = Offset(rect.center.dx + 35, top);
    canvas
      ..drawLine(Offset(left, top), bulb1 - const Offset(14, 0), _stroke)
      ..drawLine(bulb2 + const Offset(14, 0), Offset(right, top), _stroke);
    if (!failure) {
      canvas.drawLine(
        bulb1 + const Offset(14, 0),
        bulb2 - const Offset(14, 0),
        _stroke,
      );
    }
    _bulb(canvas, bulb1, crossed: failure);
    _bulb(canvas, bulb2, dim: failure);
  }

  void _parallelCircuit(Canvas canvas, Rect rect, {required bool failure}) {
    final top = rect.top + 17;
    final bottom = rect.bottom - 18;
    final left = rect.left + 18;
    final right = rect.right - 18;
    canvas
      ..drawLine(Offset(left, top), Offset(right, top), _stroke)
      ..drawLine(Offset(right, top), Offset(right, bottom), _stroke)
      ..drawLine(Offset(right, bottom), Offset(left, bottom), _stroke)
      ..drawLine(
        Offset(left, bottom),
        Offset(left, rect.center.dy + 18),
        _stroke,
      )
      ..drawLine(Offset(left, rect.center.dy - 18), Offset(left, top), _stroke);
    _battery(canvas, Offset(left, rect.center.dy));
    final branch1 = rect.center.dx - 28;
    final branch2 = rect.center.dx + 28;
    canvas
      ..drawLine(
        Offset(branch1, top),
        Offset(branch1, rect.center.dy - 13),
        _stroke,
      )
      ..drawLine(
        Offset(branch2, top),
        Offset(branch2, rect.center.dy - 13),
        _stroke,
      )
      ..drawLine(
        Offset(branch2, rect.center.dy + 13),
        Offset(branch2, bottom),
        _stroke,
      )
      ..drawLine(
        Offset(branch1, rect.center.dy + 13),
        Offset(branch1, bottom),
        _stroke,
      );
    if (!failure) {
      canvas.drawLine(
        Offset(branch1, rect.center.dy - 13),
        Offset(branch1, rect.center.dy + 13),
        _stroke,
      );
    }
    _junction(canvas, Offset(branch1, top));
    _junction(canvas, Offset(branch2, top));
    _junction(canvas, Offset(branch1, bottom));
    _junction(canvas, Offset(branch2, bottom));
    _bulb(canvas, Offset(branch1, rect.center.dy), crossed: failure);
    _bulb(canvas, Offset(branch2, rect.center.dy));
  }

  void _drawOhmsLaw(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * .18, 55, size.width * .64, 140);
    final resistor = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.top),
      width: 92,
      height: 28,
    );
    canvas
      ..drawLine(
        Offset(rect.left, rect.top),
        Offset(resistor.left, rect.top),
        _stroke,
      )
      ..drawLine(
        Offset(resistor.right, rect.top),
        Offset(rect.right, rect.top),
        _stroke,
      )
      ..drawLine(
        Offset(rect.right, rect.top),
        Offset(rect.right, rect.bottom),
        _stroke,
      )
      ..drawLine(
        Offset(rect.right, rect.bottom),
        Offset(rect.left, rect.bottom),
        _stroke,
      )
      ..drawLine(
        Offset(rect.left, rect.bottom),
        Offset(rect.left, rect.center.dy + 18),
        _stroke,
      )
      ..drawLine(
        Offset(rect.left, rect.center.dy - 18),
        Offset(rect.left, rect.top),
        _stroke,
      );
    _battery(canvas, Offset(rect.left, rect.center.dy));
    canvas
      ..drawRect(resistor, _fill)
      ..drawRect(resistor, _stroke);
    _text(
      canvas,
      '10 ohms',
      resistor.center - const Offset(0, 7),
      maxWidth: 60,
    );
    _arrow(
      canvas,
      Offset(rect.left + 42, rect.top - 22),
      Offset(rect.right - 42, rect.top - 22),
    );
    _text(
      canvas,
      '2 A current',
      Offset(rect.center.dx, rect.top - 47),
      maxWidth: 90,
    );
    _text(
      canvas,
      'V = ?',
      Offset(rect.left + 28, rect.center.dy - 9),
      maxWidth: 52,
    );
    _text(
      canvas,
      'V = IR',
      Offset(size.width / 2, 216),
      maxWidth: 80,
      mutedText: true,
    );
  }

  void _drawLenses(Canvas canvas, Size size) {
    final panelWidth = size.width / 2;
    canvas.drawLine(
      Offset(panelWidth, 20),
      Offset(panelWidth, 228),
      _faintStroke,
    );
    _text(canvas, 'convex lens', Offset(panelWidth / 2, 18), maxWidth: 90);
    _text(canvas, 'concave lens', Offset(panelWidth * 1.5, 18), maxWidth: 90);
    _lensPanel(
      canvas,
      Rect.fromLTWH(10, 48, panelWidth - 20, 155),
      converging: true,
    );
    _lensPanel(
      canvas,
      Rect.fromLTWH(panelWidth + 10, 48, panelWidth - 20, 155),
      converging: false,
    );
  }

  void _lensPanel(Canvas canvas, Rect rect, {required bool converging}) {
    final lensX = rect.center.dx;
    final lensTop = rect.top + 14;
    final lensBottom = rect.bottom - 15;
    final path = Path();
    if (converging) {
      path
        ..moveTo(lensX, lensTop)
        ..quadraticBezierTo(lensX - 20, rect.center.dy, lensX, lensBottom)
        ..quadraticBezierTo(lensX + 20, rect.center.dy, lensX, lensTop);
    } else {
      path
        ..moveTo(lensX - 9, lensTop)
        ..quadraticBezierTo(lensX + 7, rect.center.dy, lensX - 9, lensBottom)
        ..lineTo(lensX + 9, lensBottom)
        ..quadraticBezierTo(lensX - 7, rect.center.dy, lensX + 9, lensTop)
        ..close();
    }
    canvas.drawPath(path, _stroke);
    final focus = Offset(rect.right - 23, rect.center.dy);
    for (final dy in [-37.0, 0.0, 37.0]) {
      final start = Offset(rect.left + 9, rect.center.dy + dy);
      final lensPoint = Offset(lensX, rect.center.dy + dy);
      canvas.drawLine(start, lensPoint, _stroke);
      if (converging) {
        _arrow(canvas, lensPoint, focus);
      } else {
        final end = Offset(rect.right - 8, rect.center.dy + dy * 1.55);
        _arrow(canvas, lensPoint, end);
      }
    }
    if (converging) {
      canvas.drawCircle(focus, 3, Paint()..color = ink);
      _text(
        canvas,
        'focus',
        focus + const Offset(0, 10),
        maxWidth: 45,
        mutedText: true,
      );
      _text(
        canvas,
        'rays bend inward',
        Offset(rect.center.dx, rect.bottom + 5),
        maxWidth: 110,
        mutedText: true,
      );
    } else {
      _text(
        canvas,
        'rays spread outward',
        Offset(rect.center.dx, rect.bottom + 5),
        maxWidth: 115,
        mutedText: true,
      );
    }
  }

  void _drawHeatTransfer(Canvas canvas, Size size) {
    final panelWidth = size.width / 3;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(panelWidth * i, 20),
        Offset(panelWidth * i, 230),
        _faintStroke,
      );
    }
    _text(canvas, 'conduction', Offset(panelWidth * .5, 18), maxWidth: 80);
    _text(canvas, 'convection', Offset(panelWidth * 1.5, 18), maxWidth: 80);
    _text(canvas, 'radiation', Offset(panelWidth * 2.5, 18), maxWidth: 80);
    _drawConduction(canvas, Rect.fromLTWH(8, 50, panelWidth - 16, 150));
    _drawConvection(
      canvas,
      Rect.fromLTWH(panelWidth + 8, 50, panelWidth - 16, 150),
    );
    _drawRadiation(
      canvas,
      Rect.fromLTWH(panelWidth * 2 + 8, 50, panelWidth - 16, 150),
    );
  }

  void _drawConduction(Canvas canvas, Rect rect) {
    final rod = Rect.fromLTWH(
      rect.left + 20,
      rect.center.dy - 8,
      rect.width - 35,
      16,
    );
    canvas.drawRect(rod, _stroke);
    _flame(canvas, Offset(rect.left + 32, rect.center.dy + 34));
    _text(
      canvas,
      'metal rod',
      Offset(rect.center.dx, rect.top + 10),
      maxWidth: rect.width - 8,
      mutedText: true,
    );
    for (var x = rod.left + 12; x < rod.right - 8; x += 22) {
      _arrow(canvas, Offset(x, rod.center.dy), Offset(x + 17, rod.center.dy));
    }
    _text(
      canvas,
      'heat through solid rod',
      Offset(rect.center.dx, rect.bottom - 2),
      maxWidth: rect.width - 8,
      mutedText: true,
    );
  }

  void _drawConvection(Canvas canvas, Rect rect) {
    final pot = Path()
      ..moveTo(rect.left + 22, rect.top + 38)
      ..lineTo(rect.right - 22, rect.top + 38)
      ..lineTo(rect.right - 14, rect.bottom - 22)
      ..lineTo(rect.left + 14, rect.bottom - 22)
      ..close();
    canvas.drawPath(pot, _stroke);
    final waterTop = rect.top + 52;
    canvas.drawLine(
      Offset(rect.left + 24, waterTop),
      Offset(rect.right - 24, waterTop),
      _faintStroke,
    );
    _text(
      canvas,
      'water',
      Offset(rect.center.dx, waterTop + 7),
      maxWidth: 40,
      mutedText: true,
    );
    final warmX = rect.left + 35;
    final coolX = rect.right - 35;
    _arrow(
      canvas,
      Offset(warmX, rect.bottom - 34),
      Offset(warmX, rect.top + 64),
    );
    _arrow(
      canvas,
      Offset(coolX, rect.top + 64),
      Offset(coolX, rect.bottom - 34),
    );
    _flame(canvas, Offset(rect.center.dx, rect.bottom - 2));
    _text(
      canvas,
      'warm rises',
      Offset(rect.center.dx - 27, rect.top + 17),
      maxWidth: 65,
      mutedText: true,
    );
    _text(
      canvas,
      'cool sinks',
      Offset(rect.center.dx + 30, rect.top + 17),
      maxWidth: 65,
      mutedText: true,
    );
  }

  void _drawRadiation(Canvas canvas, Rect rect) {
    final sun = Offset(rect.left + 23, rect.center.dy - 5);
    final earth = Offset(rect.right - 23, rect.center.dy - 5);
    _sun(canvas, sun, 14);
    _earth(canvas, earth, 14);
    for (final dy in [-18.0, 0.0, 18.0]) {
      _wavyArrow(
        canvas,
        Offset(sun.dx + 17, sun.dy + dy),
        Offset(earth.dx - 17, earth.dy + dy),
      );
    }
    _text(canvas, 'Sun', sun + const Offset(0, 19), maxWidth: 34);
    _text(canvas, 'Earth', earth + const Offset(0, 19), maxWidth: 42);
    _text(
      canvas,
      'empty space',
      Offset(rect.center.dx, rect.bottom - 3),
      maxWidth: rect.width - 8,
      mutedText: true,
    );
  }

  void _drawDoppler(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 126);
    _ambulance(canvas, center);
    _arrow(
      canvas,
      center + const Offset(-4, -48),
      center + const Offset(65, -48),
    );
    _text(
      canvas,
      'moving',
      center + const Offset(31, -72),
      maxWidth: 60,
      mutedText: true,
    );

    for (var i = 1; i <= 5; i++) {
      final x = center.dx + 43 + i * 15;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x, center.dy),
          width: 15 + i * 4,
          height: 105 + i * 5,
        ),
        -math.pi / 2,
        math.pi,
        false,
        _faintStroke,
      );
    }
    for (var i = 1; i <= 4; i++) {
      final x = center.dx - 45 - i * 31;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x, center.dy),
          width: 24 + i * 9,
          height: 105 + i * 8,
        ),
        math.pi / 2,
        math.pi,
        false,
        _faintStroke,
      );
    }
    _text(
      canvas,
      'shorter wavelength',
      Offset(size.width * .79, 47),
      maxWidth: 125,
    );
    _text(
      canvas,
      'higher pitch',
      Offset(size.width * .79, 72),
      maxWidth: 90,
      mutedText: true,
    );
    _text(
      canvas,
      'longer wavelength',
      Offset(size.width * .2, 47),
      maxWidth: 120,
    );
    _text(
      canvas,
      'lower pitch',
      Offset(size.width * .2, 72),
      maxWidth: 85,
      mutedText: true,
    );
    _text(
      canvas,
      'wavefronts bunch ahead and spread behind',
      Offset(size.width / 2, 220),
      maxWidth: 225,
      mutedText: true,
    );
  }

  void _charge(Canvas canvas, Offset center, String symbol) {
    canvas
      ..drawCircle(center, 18, _fill)
      ..drawCircle(center, 18, _stroke);
    _text(canvas, symbol, center - const Offset(0, 10), maxWidth: 20);
  }

  void _battery(Canvas canvas, Offset center) {
    canvas
      ..drawLine(
        center + const Offset(-14, -8),
        center + const Offset(14, -8),
        _stroke,
      )
      ..drawLine(
        center + const Offset(-8, 8),
        center + const Offset(8, 8),
        _stroke,
      );
  }

  void _junction(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 3, Paint()..color = ink);
  }

  void _bulb(
    Canvas canvas,
    Offset center, {
    bool crossed = false,
    bool dim = false,
  }) {
    final paint = dim
        ? (Paint()
          ..color = muted
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2)
        : _stroke;
    canvas
      ..drawCircle(center, 13, _fill)
      ..drawCircle(center, 13, paint)
      ..drawLine(
        center + const Offset(-7, -7),
        center + const Offset(7, 7),
        paint,
      )
      ..drawLine(
        center + const Offset(-7, 7),
        center + const Offset(7, -7),
        paint,
      );
    if (crossed) {
      canvas.drawLine(
        center + const Offset(-17, -17),
        center + const Offset(17, 17),
        _stroke,
      );
    }
  }

  void _ambulance(Canvas canvas, Offset center) {
    final body = Rect.fromCenter(center: center, width: 82, height: 38);
    final cab = Rect.fromLTWH(body.right - 24, body.top - 12, 24, 18);
    canvas
      ..drawRect(body, _stroke)
      ..drawRect(cab, _stroke)
      ..drawCircle(body.bottomLeft + const Offset(17, 4), 8, _fill)
      ..drawCircle(body.bottomLeft + const Offset(17, 4), 8, _stroke)
      ..drawCircle(body.bottomRight + const Offset(-17, 4), 8, _fill)
      ..drawCircle(body.bottomRight + const Offset(-17, 4), 8, _stroke)
      ..drawLine(
        center + const Offset(-7, -9),
        center + const Offset(7, -9),
        _stroke,
      )
      ..drawLine(
        center + const Offset(0, -16),
        center + const Offset(0, -2),
        _stroke,
      );
  }

  void _flame(Canvas canvas, Offset center) {
    final path = Path()
      ..moveTo(center.dx, center.dy - 20)
      ..cubicTo(
        center.dx + 15,
        center.dy - 5,
        center.dx + 12,
        center.dy + 15,
        center.dx,
        center.dy + 18,
      )
      ..cubicTo(
        center.dx - 14,
        center.dy + 12,
        center.dx - 13,
        center.dy - 3,
        center.dx,
        center.dy - 20,
      )
      ..close();
    canvas.drawPath(path, _stroke);
  }

  void _sun(Canvas canvas, Offset center, double radius) {
    canvas
      ..drawCircle(center, radius, _fill)
      ..drawCircle(center, radius, _stroke);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * (radius + 3),
        center + Offset(math.cos(angle), math.sin(angle)) * (radius + 9),
        _faintStroke,
      );
    }
  }

  void _earth(Canvas canvas, Offset center, double radius) {
    canvas
      ..drawCircle(center, radius, _fill)
      ..drawCircle(center, radius, _stroke)
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius * .6),
        -.8,
        1.7,
        false,
        _faintStroke,
      );
  }

  void _wavyArrow(Canvas canvas, Offset from, Offset to) {
    final path = Path()..moveTo(from.dx, from.dy);
    const waves = 5;
    for (var i = 1; i <= waves * 2; i++) {
      final t = i / (waves * 2);
      final x = from.dx + (to.dx - from.dx) * t;
      final y = from.dy + (to.dy - from.dy) * t + (i.isEven ? -4 : 4);
      path.lineTo(x, y);
    }
    path.lineTo(to.dx, to.dy);
    canvas.drawPath(path, _stroke);
    _arrowHead(canvas, to, math.atan2(to.dy - from.dy, to.dx - from.dx));
  }

  void _arrow(Canvas canvas, Offset from, Offset to) {
    canvas.drawLine(from, to, _stroke);
    _arrowHead(canvas, to, math.atan2(to.dy - from.dy, to.dx - from.dx));
  }

  void _arrowHead(Canvas canvas, Offset to, double angle) {
    const head = 7.0;
    canvas
      ..drawLine(
        to,
        to - Offset(math.cos(angle - .55), math.sin(angle - .55)) * head,
        _stroke,
      )
      ..drawLine(
        to,
        to - Offset(math.cos(angle + .55), math.sin(angle + .55)) * head,
        _stroke,
      );
  }

  void _text(
    Canvas canvas,
    String text,
    Offset center, {
    double maxWidth = 100,
    bool mutedText = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: mutedText ? smallStyle : labelStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, center - Offset(painter.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant _PhysicsEnergyPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.ink != ink ||
        oldDelegate.muted != muted ||
        oldDelegate.faint != faint ||
        oldDelegate.background != background ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.smallStyle != smallStyle;
  }
}
