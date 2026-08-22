import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Original lesson diagrams for Earth Science and Astronomy.
class EarthScienceDiagramFigure extends StatelessWidget {
  const EarthScienceDiagramFigure._({
    required this.type,
    required this.spec,
  });

  static const kind = 'earth-science-diagram';

  static const _types = <String>{
    'seasonal-orbit',
    'earth-motion-triptych',
    'seasonal-tilt-comparison',
    'sidereal-solar-day',
    'earth-subsystems',
    'moon-phases',
    'half-life-halving',
    'stratigraphy-stack',
    'half-life-billion-years',
    'comet-tail',
    'seismic-core',
    'rock-cycle',
    'nebular-sequence',
    'plate-boundary-comparison',
    'transform-boundary',
    'seismograph-arrivals',
    'water-cycle',
    'atmosphere-layers',
  };

  final String type;
  final Map<String, Object?> spec;

  static EarthScienceDiagramFigure? fromSpec(Map<String, Object?> spec) {
    if (spec['kind'] != kind) return null;
    final type = spec['type'];
    final illustrationKey = spec['illustrationKey'];
    if (type is! String || !_types.contains(type)) return null;
    if (illustrationKey is! String || illustrationKey.trim().isEmpty) return null;

    final valid = switch (type) {
      'seasonal-orbit' => _validSeasonalOrbit(spec),
      'earth-motion-triptych' => _validMotionTriptych(spec),
      'seasonal-tilt-comparison' => _validSeasonalTilt(spec),
      'sidereal-solar-day' => _validSiderealDay(spec),
      'earth-subsystems' => _validEarthSubsystems(spec),
      'moon-phases' => _validMoonPhases(spec),
      'half-life-halving' => _validHalfLifeHalving(spec),
      'stratigraphy-stack' => _validStratigraphy(spec),
      'half-life-billion-years' => _validHalfLifeBillionYears(spec),
      'comet-tail' => _validCometTail(spec),
      'seismic-core' => _validSeismicCore(spec),
      'rock-cycle' => _validRockCycle(spec),
      'nebular-sequence' => _validNebularSequence(spec),
      'plate-boundary-comparison' => _validBoundaryComparison(spec),
      'transform-boundary' => _validTransformBoundary(spec),
      'seismograph-arrivals' => _validSeismograph(spec),
      'water-cycle' => _validWaterCycle(spec),
      'atmosphere-layers' => _validAtmosphere(spec),
      _ => false,
    };
    if (!valid) return null;

    return EarthScienceDiagramFigure._(
      type: type,
      spec: Map<String, Object?>.unmodifiable(spec),
    );
  }

  static bool _validSeasonalOrbit(Map<String, Object?> spec) {
    return spec['earthPositions'] == 4 &&
        spec['axisDirection'] == 'constant' &&
        _stringListEquals(
          spec['hemisphereTilt'],
          const ['toward Sun', 'away from Sun'],
        );
  }

  static bool _validMotionTriptych(Map<String, Object?> spec) {
    final motions = _mapList(spec['motions'], length: 3);
    if (motions == null) return false;
    return _mapStringsEqual(
          motions[0],
          const {
            'name': 'rotation',
            'effect': 'day/night',
            'motion': 'spin on axis',
          },
        ) &&
        _mapStringsEqual(
          motions[1],
          const {
            'name': 'revolution',
            'effect': 'seasons',
            'motion': 'orbit Sun with tilted axis',
          },
        ) &&
        _mapStringsEqual(
          motions[2],
          const {
            'name': 'precession',
            'effect': 'axis wobble',
            'motion': 'slow wobble',
          },
        );
  }

  static bool _validSeasonalTilt(Map<String, Object?> spec) {
    final angle = spec['axisTiltDegrees'];
    return spec['earthPositions'] == 2 &&
        angle is num &&
        angle.isFinite &&
        angle == 23.5 &&
        _stringListEquals(
          spec['northernHemisphereStates'],
          const ['toward Sun (summer)', 'away from Sun (winter)'],
        ) &&
        spec['sunlightAngles'] == 'different';
  }

  static bool _validSiderealDay(Map<String, Object?> spec) {
    return spec['earthPositions'] == 2 &&
        spec['siderealReference'] == 'distant stars' &&
        spec['extraRotation'] == 'a few extra degrees' &&
        spec['result'] == 'solar day slightly longer';
  }

  static bool _validEarthSubsystems(Map<String, Object?> spec) {
    final features = _mapList(spec['features'], length: 4);
    if (features == null) return false;
    const expected = <Map<String, String>>[
      {'label': 'lithosphere', 'feature': 'rocky ground'},
      {'label': 'hydrosphere', 'feature': 'ocean water'},
      {'label': 'atmosphere', 'feature': 'surrounding air'},
      {
        'label': 'biosphere',
        'feature': 'plants/animals living across all three',
      },
    ];
    for (var i = 0; i < expected.length; i++) {
      if (!_mapStringsEqual(features[i], expected[i])) return false;
    }
    return true;
  }

  static bool _validMoonPhases(Map<String, Object?> spec) {
    return spec['moonPositions'] == 8 &&
        spec['sunlightFrom'] == 'one side' &&
        _stringListEquals(
          spec['phaseNames'],
          const [
            'new moon',
            'waxing crescent',
            'first quarter',
            'waxing gibbous',
            'full moon',
            'waning gibbous',
            'last quarter',
            'waning crescent',
          ],
        ) &&
        spec['showEarthView'] == true;
  }

  static bool _validHalfLifeHalving(Map<String, Object?> spec) {
    return spec['halfLifeSteps'] == 3 &&
        _stringListEquals(
          spec['parentFractions'],
          const ['1', '1/2', '1/4', '1/8'],
        ) &&
        spec['daughterMaterial'] == 'stable remainder';
  }

  static bool _validStratigraphy(Map<String, Object?> spec) {
    return _stringListEquals(
          spec['layersBottomToTop'],
          const ['W', 'X', 'Y', 'Z'],
        ) &&
        spec['oldest'] == 'W' &&
        spec['youngest'] == 'Z';
  }

  static bool _validHalfLifeBillionYears(Map<String, Object?> spec) {
    return _numListEquals(
          spec['parentPercentages'],
          const [100, 50, 25],
        ) &&
        spec['halfLife'] == '1 billion years' &&
        _stringListEquals(
          spec['halfLifeLabels'],
          const ['1 half-life', '2 half-lives'],
        ) &&
        spec['result'] == '2 billion years';
  }

  static bool _validCometTail(Map<String, Object?> spec) {
    return spec['orbitShape'] == 'oval' &&
        spec['cometPositions'] == 2 &&
        spec['tailDirection'] == 'away from Sun';
  }

  static bool _validSeismicCore(Map<String, Object?> spec) {
    return spec['sWaveBehavior'] == 'stops at liquid outer core' &&
        spec['pWaveBehavior'] == 'bends through liquid outer core' &&
        spec['shadowZone'] == 'S-wave';
  }

  static bool _validRockCycle(Map<String, Object?> spec) {
    if (!_stringListEquals(
      spec['stages'],
      const [
        'magma',
        'igneous rock',
        'sediment',
        'sedimentary rock',
        'metamorphic rock',
      ],
    )) {
      return false;
    }
    final processes = _mapList(spec['processes'], length: 5);
    if (processes == null) return false;
    const expected = <Map<String, String>>[
      {'from': 'magma', 'to': 'igneous rock', 'label': 'cooling'},
      {'from': 'igneous rock', 'to': 'sediment', 'label': 'weathering'},
      {'from': 'sediment', 'to': 'sedimentary rock', 'label': 'compacting'},
      {
        'from': 'any rock',
        'to': 'metamorphic rock',
        'label': 'heat and pressure',
      },
      {'from': 'any rock', 'to': 'magma', 'label': 'melting'},
    ];
    for (var i = 0; i < expected.length; i++) {
      if (!_mapStringsEqual(processes[i], expected[i])) return false;
    }
    return true;
  }

  static bool _validNebularSequence(Map<String, Object?> spec) {
    return _stringListEquals(
      spec['stages'],
      const [
        'large slowly spinning cloud of gas and dust',
        'flattened disk',
        'bright center forming the Sun',
        'small clumps forming planets along the disk',
      ],
    );
  }

  static bool _validBoundaryComparison(Map<String, Object?> spec) {
    final boundaries = _mapList(spec['boundaries'], length: 3);
    if (boundaries == null) return false;
    const expected = <Map<String, String>>[
      {
        'name': 'divergent',
        'motion': 'plates moving apart',
        'state': 'magma rising',
      },
      {
        'name': 'convergent',
        'motion': 'plates moving together',
        'state': 'one plate sliding under another',
      },
      {
        'name': 'transform',
        'motion': 'plates sliding past each other horizontally',
        'state': 'sideways motion',
      },
    ];
    for (var i = 0; i < expected.length; i++) {
      if (!_mapStringsEqual(boundaries[i], expected[i])) return false;
    }
    return true;
  }

  static bool _validTransformBoundary(Map<String, Object?> spec) {
    return spec['plateMotion'] == 'opposite horizontal directions' &&
        spec['faultLine'] == true &&
        spec['earthquakeSymbols'] == true;
  }

  static bool _validSeismograph(Map<String, Object?> spec) {
    return spec['firstArrival'] == 'P wave' &&
        spec['secondArrival'] == 'S wave' &&
        spec['timeGapMeaning'] == 'proportional to distance';
  }

  static bool _validWaterCycle(Map<String, Object?> spec) {
    return _stringListEquals(
      spec['steps'],
      const [
        'Sun heats ocean',
        'evaporation',
        'water vapor rises',
        'condensation into clouds',
        'precipitation over mountains',
        'runoff to ocean',
        'groundwater to ocean',
      ],
    );
  }

  static bool _validAtmosphere(Map<String, Object?> spec) {
    return _stringListEquals(
          spec['layersGroundUp'],
          const [
            'troposphere',
            'stratosphere',
            'mesosphere',
            'thermosphere',
            'exosphere',
          ],
        ) &&
        spec['ozoneLayerWithin'] == 'stratosphere';
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

  static bool _mapStringsEqual(
    Map<String, Object?> actual,
    Map<String, String> expected,
  ) {
    for (final entry in expected.entries) {
      if (actual[entry.key] != entry.value) return false;
    }
    return true;
  }

  static bool _stringListEquals(Object? value, List<String> expected) {
    if (value is! List || value.length != expected.length) return false;
    for (var i = 0; i < expected.length; i++) {
      if (value[i] != expected[i]) return false;
    }
    return true;
  }

  static bool _numListEquals(Object? value, List<num> expected) {
    if (value is! List || value.length != expected.length) return false;
    for (var i = 0; i < expected.length; i++) {
      final actual = value[i];
      if (actual is! num || !actual.isFinite || actual != expected[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 270,
      child: CustomPaint(
        size: Size.infinite,
        painter: _EarthSciencePainter(
          type: type,
          spec: spec,
          ink: colors.ink,
          muted: colors.inkMuted,
          faint: colors.ruleFaint,
          background: colors.background,
          labelStyle: context.textStyles.bodySmall.copyWith(color: colors.ink),
          smallStyle: context.textStyles.bodySmall.copyWith(
            color: colors.inkMuted,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _EarthSciencePainter extends CustomPainter {
  const _EarthSciencePainter({
    required this.type,
    required this.spec,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.background,
    required this.labelStyle,
    required this.smallStyle,
  });

  final String type;
  final Map<String, Object?> spec;
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
      case 'seasonal-orbit':
        _drawSeasonalOrbit(canvas, size);
      case 'earth-motion-triptych':
        _drawMotionTriptych(canvas, size);
      case 'seasonal-tilt-comparison':
        _drawSeasonalTilt(canvas, size);
      case 'sidereal-solar-day':
        _drawSiderealDay(canvas, size);
      case 'earth-subsystems':
        _drawSubsystems(canvas, size);
      case 'moon-phases':
        _drawMoonPhases(canvas, size);
      case 'half-life-halving':
        _drawHalfLife(canvas, size, const [1, .5, .25, .125]);
      case 'stratigraphy-stack':
        _drawStratigraphy(canvas, size);
      case 'half-life-billion-years':
        _drawHalfLife(canvas, size, const [1, .5, .25]);
      case 'comet-tail':
        _drawComet(canvas, size);
      case 'seismic-core':
        _drawSeismicCore(canvas, size);
      case 'rock-cycle':
        _drawRockCycle(canvas, size);
      case 'nebular-sequence':
        _drawNebular(canvas, size);
      case 'plate-boundary-comparison':
        _drawBoundaryComparison(canvas, size);
      case 'transform-boundary':
        _drawTransform(canvas, size);
      case 'seismograph-arrivals':
        _drawSeismograph(canvas, size);
      case 'water-cycle':
        _drawWaterCycle(canvas, size);
      case 'atmosphere-layers':
        _drawAtmosphere(canvas, size);
    }
  }

  void _drawSeasonalOrbit(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 125);
    final orbit = Rect.fromCenter(
      center: center,
      width: size.width * .72,
      height: 170,
    );
    canvas.drawOval(orbit, _faintStroke);
    _sun(canvas, center, 22);
    final earths = <Offset>[
      Offset(orbit.left, center.dy),
      Offset(center.dx, orbit.top),
      Offset(orbit.right, center.dy),
      Offset(center.dx, orbit.bottom),
    ];
    for (final earth in earths) {
      _earthWithAxis(canvas, earth, 15);
    }
    _text(
      canvas,
      'toward Sun',
      earths[0] + const Offset(0, 23),
      maxWidth: 78,
    );
    _text(
      canvas,
      'away from Sun',
      earths[2] + const Offset(0, 23),
      maxWidth: 85,
    );
    _text(
      canvas,
      'axis stays pointed the same way',
      Offset(center.dx, 238),
      maxWidth: 190,
      mutedText: true,
    );
  }

  void _drawMotionTriptych(Canvas canvas, Size size) {
    final panelWidth = size.width / 3;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(panelWidth * i, 18),
        Offset(panelWidth * i, 245),
        _faintStroke,
      );
    }
    final centers = <Offset>[
      Offset(panelWidth * .5, 105),
      Offset(panelWidth * 1.5, 105),
      Offset(panelWidth * 2.5, 105),
    ];
    _earthWithAxis(canvas, centers[0], 25);
    _arcArrow(canvas, Rect.fromCircle(center: centers[0], radius: 38), -.8, 4.5);
    _text(canvas, 'rotation', centers[0] + const Offset(0, 54));
    _text(
      canvas,
      'day/night',
      centers[0] + const Offset(0, 76),
      mutedText: true,
    );

    _sun(canvas, centers[1] + const Offset(-30, 0), 14);
    final orbit = Rect.fromCenter(center: centers[1], width: 82, height: 55);
    canvas.drawOval(orbit, _faintStroke);
    _earthWithAxis(canvas, centers[1] + const Offset(40, 0), 12);
    _arrow(
      canvas,
      centers[1] + const Offset(-2, -30),
      centers[1] + const Offset(22, -36),
    );
    _text(canvas, 'revolution', centers[1] + const Offset(0, 54));
    _text(
      canvas,
      'seasons',
      centers[1] + const Offset(0, 76),
      mutedText: true,
    );

    _earthWithAxis(canvas, centers[2], 25);
    canvas.drawOval(
      Rect.fromCenter(
        center: centers[2] + const Offset(5, -32),
        width: 58,
        height: 17,
      ),
      _faintStroke,
    );
    _arcArrow(
      canvas,
      Rect.fromCenter(
        center: centers[2] + const Offset(5, -32),
        width: 58,
        height: 17,
      ),
      .2,
      4.7,
    );
    _text(canvas, 'precession', centers[2] + const Offset(0, 54));
    _text(
      canvas,
      'axis wobble',
      centers[2] + const Offset(0, 76),
      mutedText: true,
    );
  }

  void _drawSeasonalTilt(Canvas canvas, Size size) {
    final sun = Offset(size.width / 2, 115);
    _sun(canvas, sun, 25);
    final left = Offset(size.width * .2, 115);
    final right = Offset(size.width * .8, 115);
    _earthWithAxis(canvas, left, 22);
    _earthWithAxis(canvas, right, 22);
    for (var d = -22.0; d <= 22; d += 11) {
      _arrow(
        canvas,
        Offset(sun.dx - 27, sun.dy + d),
        Offset(left.dx + 24, left.dy + d * .55),
      );
      _arrow(
        canvas,
        Offset(sun.dx + 27, sun.dy + d),
        Offset(right.dx - 24, right.dy + d * .55),
      );
    }
    _text(
      canvas,
      '23.5°',
      left + const Offset(17, -51),
      maxWidth: 50,
      mutedText: true,
    );
    _text(
      canvas,
      'toward Sun (summer)',
      left + const Offset(0, 48),
      maxWidth: 115,
    );
    _text(
      canvas,
      'away from Sun (winter)',
      right + const Offset(0, 48),
      maxWidth: 115,
    );
    _text(
      canvas,
      'different sunlight angles',
      Offset(size.width / 2, 225),
      maxWidth: 170,
      mutedText: true,
    );
  }

  void _drawSiderealDay(Canvas canvas, Size size) {
    final sun = Offset(size.width * .72, 135);
    _sun(canvas, sun, 24);
    final a = Offset(size.width * .25, 150);
    final b = Offset(size.width * .37, 82);
    canvas.drawArc(
      Rect.fromCenter(center: sun, width: size.width * .95, height: 230),
      math.pi * .72,
      .36,
      false,
      _faintStroke,
    );
    _earthWithAxis(canvas, a, 18);
    _earthWithAxis(canvas, b, 18);
    for (var x = 35.0; x < size.width - 30; x += 42) {
      _star(canvas, Offset(x, 24), 3);
    }
    _text(
      canvas,
      'distant stars',
      Offset(size.width / 2, 4),
      maxWidth: 100,
      mutedText: true,
    );
    _arcArrow(canvas, Rect.fromCircle(center: b, radius: 31), -.45, 4.9);
    _arcArrow(canvas, Rect.fromCircle(center: b, radius: 38), 4.2, .35);
    _text(
      canvas,
      'one spin relative to stars',
      b + const Offset(-2, 45),
      maxWidth: 120,
    );
    _text(
      canvas,
      'a few extra degrees',
      b + const Offset(70, -31),
      maxWidth: 90,
      mutedText: true,
    );
    _text(
      canvas,
      'solar day slightly longer',
      Offset(size.width / 2, 226),
      maxWidth: 170,
    );
  }

  void _drawSubsystems(Canvas canvas, Size size) {
    const groundY = 176.0;
    canvas.drawLine(
      const Offset(20, groundY),
      Offset(size.width - 20, groundY),
      _stroke,
    );
    final ocean = Path()
      ..moveTo(20, groundY)
      ..lineTo(size.width * .45, groundY)
      ..lineTo(size.width * .45, 135)
      ..quadraticBezierTo(size.width * .27, 126, 20, 140)
      ..close();
    canvas.drawPath(ocean, _faintStroke);
    _text(
      canvas,
      'hydrosphere',
      Offset(size.width * .25, 142),
      maxWidth: 90,
    );
    _text(
      canvas,
      'lithosphere',
      Offset(size.width * .72, 183),
      maxWidth: 90,
    );
    canvas.drawArc(
      Rect.fromLTWH(35, 28, size.width - 70, 110),
      math.pi,
      math.pi,
      false,
      _faintStroke,
    );
    canvas.drawArc(
      Rect.fromLTWH(50, 42, size.width - 100, 82),
      math.pi,
      math.pi,
      false,
      _faintStroke,
    );
    _text(
      canvas,
      'atmosphere',
      Offset(size.width / 2, 42),
      maxWidth: 90,
    );
    _tree(canvas, Offset(size.width * .64, groundY));
    _animal(canvas, Offset(size.width * .8, groundY - 2));
    _text(
      canvas,
      'biosphere',
      Offset(size.width * .72, 119),
      maxWidth: 88,
    );
    _text(
      canvas,
      'plants/animals across land, water, and air',
      Offset(size.width / 2, 224),
      maxWidth: 220,
      mutedText: true,
    );
  }

  void _drawMoonPhases(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 128);
    final radiusX = size.width * .31;
    const radiusY = 83.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      _faintStroke,
    );
    _earth(canvas, center, 17);
    final sun = Offset(20, center.dy);
    _sun(canvas, sun, 13);
    _arrow(
      canvas,
      const Offset(39, 128),
      Offset(center.dx - radiusX - 18, 128),
    );
    _text(
      canvas,
      'Sunlight',
      const Offset(54, 97),
      maxWidth: 60,
      mutedText: true,
    );
    const names = <String>[
      'new moon',
      'waxing crescent',
      'first quarter',
      'waxing gibbous',
      'full moon',
      'waning gibbous',
      'last quarter',
      'waning crescent',
    ];
    for (var i = 0; i < 8; i++) {
      final angle = math.pi + i * math.pi / 4;
      final p = Offset(
        center.dx + math.cos(angle) * radiusX,
        center.dy - math.sin(angle) * radiusY,
      );
      _moonOrbital(canvas, p, 9);
      final labelOffset = Offset(
        p.dx + math.cos(angle) * 15,
        p.dy - math.sin(angle) * 15 - 6,
      );
      _text(
        canvas,
        names[i],
        labelOffset,
        maxWidth: 74,
        mutedText: true,
      );
      _phaseIcon(canvas, Offset(p.dx, p.dy + 18), 6, i);
    }
    _text(
      canvas,
      'small discs show the view from Earth',
      Offset(size.width / 2, 244),
      maxWidth: 180,
      mutedText: true,
    );
  }

  void _drawHalfLife(Canvas canvas, Size size, List<double> fractions) {
    final labels = fractions.length == 4
        ? const ['1', '1/2', '1/4', '1/8']
        : const ['100%', '50%', '25%'];
    final barWidth = math.min(
      78.0,
      (size.width - 42) / fractions.length - 10,
    );
    for (var i = 0; i < fractions.length; i++) {
      final x = 22 + i * ((size.width - 44) / fractions.length);
      final rect = Rect.fromLTWH(x, 85, barWidth, 74);
      canvas.drawRect(rect, _faintStroke);
      final parentRect = Rect.fromLTWH(x, 85, barWidth * fractions[i], 74);
      canvas.drawRect(
        parentRect,
        Paint()..color = ink.withValues(alpha: .16),
      );
      canvas.drawRect(parentRect, _stroke);
      _text(
        canvas,
        labels[i],
        Offset(x + barWidth / 2, 59),
        maxWidth: barWidth,
      );
      if (i > 0) {
        _text(
          canvas,
          i == 1 ? '1 half-life' : '$i half-lives',
          Offset(x + barWidth / 2, 170),
          maxWidth: barWidth + 8,
          mutedText: true,
        );
      }
    }
    if (fractions.length == 4) {
      _text(
        canvas,
        'radioactive parent',
        Offset(size.width * .28, 214),
        maxWidth: 120,
      );
      _text(
        canvas,
        'stable daughter remainder',
        Offset(size.width * .72, 214),
        maxWidth: 140,
        mutedText: true,
      );
    } else {
      _text(
        canvas,
        'half-life = 1 billion years',
        Offset(size.width / 2, 211),
        maxWidth: 170,
      );
      _text(
        canvas,
        '25% remaining → 2 billion years',
        Offset(size.width / 2, 233),
        maxWidth: 190,
        mutedText: true,
      );
    }
  }

  void _drawStratigraphy(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * .22, 40, size.width * .56, 184);
    const labels = ['Z', 'Y', 'X', 'W'];
    for (var i = 0; i < 4; i++) {
      final layer = Rect.fromLTWH(
        rect.left,
        rect.top + i * 46,
        rect.width,
        46,
      );
      canvas.drawRect(layer, i.isEven ? _faintStroke : _stroke);
      _text(
        canvas,
        labels[i],
        layer.center - const Offset(0, 9),
        maxWidth: 36,
      );
    }
    _text(
      canvas,
      'youngest',
      Offset(rect.right + 43, rect.top + 10),
      maxWidth: 65,
    );
    _arrow(
      canvas,
      Offset(rect.right + 24, rect.top + 32),
      Offset(rect.right + 24, rect.bottom - 20),
    );
    _text(
      canvas,
      'oldest',
      Offset(rect.right + 43, rect.bottom - 21),
      maxWidth: 60,
    );
  }

  void _drawComet(Canvas canvas, Size size) {
    final sun = Offset(size.width / 2, 132);
    _sun(canvas, sun, 23);
    final orbit = Rect.fromCenter(
      center: sun,
      width: size.width * .72,
      height: 175,
    );
    canvas.drawOval(orbit, _faintStroke);
    final positions = <Offset>[
      Offset(orbit.left + 30, sun.dy - 47),
      Offset(orbit.right - 28, sun.dy + 50),
    ];
    for (final p in positions) {
      canvas.drawCircle(p, 7, _stroke);
      final outward = p - sun;
      final length = math.sqrt(
        outward.dx * outward.dx + outward.dy * outward.dy,
      );
      final unit = Offset(outward.dx / length, outward.dy / length);
      _arrow(canvas, p + unit * 8, p + unit * 58);
      _text(
        canvas,
        'tail away from Sun',
        p + unit * 69 + const Offset(0, -8),
        maxWidth: 90,
        mutedText: true,
      );
    }
  }

  void _drawSeismicCore(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 126);
    canvas.drawCircle(center, 92, _stroke);
    canvas.drawCircle(center, 58, _faintStroke);
    canvas.drawCircle(center, 28, _faintStroke);
    _text(
      canvas,
      'liquid outer core',
      center + const Offset(0, -10),
      maxWidth: 80,
      mutedText: true,
    );
    final quake = center + const Offset(-84, -37);
    _star(canvas, quake, 7);
    _text(
      canvas,
      'earthquake',
      quake + const Offset(-32, -25),
      maxWidth: 70,
      mutedText: true,
    );

    final pPath = Path()
      ..moveTo(quake.dx, quake.dy)
      ..quadraticBezierTo(
        center.dx - 28,
        center.dy - 45,
        center.dx + 4,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + 42,
        center.dy + 47,
        center.dx + 81,
        center.dy + 43,
      );
    canvas.drawPath(pPath, _stroke);
    _text(
      canvas,
      'P bends through',
      center + const Offset(78, 43),
      maxWidth: 75,
    );

    final sEnd = center + const Offset(-44, 37);
    final sPath = Path()
      ..moveTo(quake.dx, quake.dy)
      ..quadraticBezierTo(
        center.dx - 69,
        center.dy + 15,
        sEnd.dx,
        sEnd.dy,
      );
    canvas.drawPath(sPath, _stroke);
    canvas.drawLine(
      sEnd + const Offset(-5, -5),
      sEnd + const Offset(5, 5),
      _stroke,
    );
    canvas.drawLine(
      sEnd + const Offset(-5, 5),
      sEnd + const Offset(5, -5),
      _stroke,
    );
    _text(
      canvas,
      'S stops',
      sEnd + const Offset(-38, 11),
      maxWidth: 60,
    );
    _text(
      canvas,
      'S-wave shadow zone',
      Offset(size.width / 2, 235),
      maxWidth: 130,
      mutedText: true,
    );
  }

  void _drawRockCycle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 128);
    const labels = <String>[
      'magma',
      'igneous rock',
      'sediment',
      'sedimentary rock',
      'metamorphic rock',
    ];
    const process = <String>[
      'cooling',
      'weathering',
      'compacting',
      'heat + pressure',
      'melting',
    ];
    final points = <Offset>[];
    for (var i = 0; i < labels.length; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / labels.length;
      points.add(
        center + Offset(math.cos(angle) * 105, math.sin(angle) * 82),
      );
    }
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      _arrow(canvas, a + (b - a) * .18, b - (b - a) * .18);
      _text(
        canvas,
        process[i],
        (a + b) / 2 + const Offset(0, -8),
        maxWidth: 82,
        mutedText: true,
      );
      canvas.drawCircle(a, 24, _faintStroke);
      _text(
        canvas,
        labels[i],
        a - const Offset(0, 10),
        maxWidth: 72,
      );
    }
    _arrow(
      canvas,
      points[1] + const Offset(0, 19),
      points[4] - const Offset(0, 19),
    );
    _text(
      canvas,
      'heat + pressure',
      center + const Offset(-2, -10),
      maxWidth: 95,
      mutedText: true,
    );
    _text(
      canvas,
      'any rock can melt → magma',
      Offset(size.width / 2, 246),
      maxWidth: 170,
      mutedText: true,
    );
  }

  void _drawNebular(Canvas canvas, Size size) {
    final w = size.width / 4;
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(w * i, 35),
        Offset(w * i, 215),
        _faintStroke,
      );
      _arrow(
        canvas,
        Offset(w * i - 14, 123),
        Offset(w * i + 14, 123),
      );
    }
    final centers = List<Offset>.generate(
      4,
      (i) => Offset(w * (i + .5), 115),
    );
    for (var i = 0; i < 24; i++) {
      final angle = i * .83;
      final r = 8 + (i % 7) * 5;
      canvas.drawCircle(
        centers[0] + Offset(math.cos(angle) * r, math.sin(angle) * r),
        1.4,
        Paint()..color = ink,
      );
    }
    _arcArrow(
      canvas,
      Rect.fromCircle(center: centers[0], radius: 38),
      .4,
      4.2,
    );
    canvas.drawOval(
      Rect.fromCenter(center: centers[1], width: 76, height: 33),
      _stroke,
    );
    for (var i = 0; i < 14; i++) {
      final angle = i * .7;
      canvas.drawCircle(
        centers[1] + Offset(math.cos(angle) * 28, math.sin(angle) * 10),
        1.3,
        Paint()..color = ink,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: centers[2], width: 80, height: 30),
      _faintStroke,
    );
    _sun(canvas, centers[2], 14);
    canvas.drawOval(
      Rect.fromCenter(center: centers[3], width: 80, height: 30),
      _faintStroke,
    );
    _sun(canvas, centers[3], 12);
    for (final dx in [-32.0, -20.0, 23.0, 34.0]) {
      canvas.drawCircle(
        centers[3] + Offset(dx, dx.sign * 7),
        3,
        _stroke,
      );
    }
    const captions = <String>[
      'slow cloud',
      'flattened disk',
      'Sun forms',
      'planet clumps',
    ];
    for (var i = 0; i < 4; i++) {
      _text(
        canvas,
        captions[i],
        centers[i] + const Offset(0, 61),
        maxWidth: w - 10,
        mutedText: true,
      );
    }
  }

  void _drawBoundaryComparison(Canvas canvas, Size size) {
    final w = size.width / 3;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(w * i, 28),
        Offset(w * i, 238),
        _faintStroke,
      );
    }
    _boundaryPanel(
      canvas,
      Rect.fromLTWH(6, 54, w - 12, 145),
      'divergent',
    );
    _boundaryPanel(
      canvas,
      Rect.fromLTWH(w + 6, 54, w - 12, 145),
      'convergent',
    );
    _boundaryPanel(
      canvas,
      Rect.fromLTWH(w * 2 + 6, 54, w - 12, 145),
      'transform',
    );
  }

  void _boundaryPanel(Canvas canvas, Rect rect, String name) {
    _text(
      canvas,
      name,
      Offset(rect.center.dx, rect.top - 23),
      maxWidth: rect.width,
    );
    final midY = rect.center.dy;
    if (name == 'divergent') {
      canvas.drawRect(
        Rect.fromLTWH(
          rect.left + 8,
          midY - 12,
          rect.width * .42,
          34,
        ),
        _stroke,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          rect.center.dx + 5,
          midY - 12,
          rect.width * .42,
          34,
        ),
        _stroke,
      );
      _arrow(
        canvas,
        Offset(rect.center.dx - 8, midY - 29),
        Offset(rect.left + 17, midY - 29),
      );
      _arrow(
        canvas,
        Offset(rect.center.dx + 8, midY - 29),
        Offset(rect.right - 17, midY - 29),
      );
      _arrow(
        canvas,
        Offset(rect.center.dx, rect.bottom - 10),
        Offset(rect.center.dx, midY + 5),
      );
      _text(
        canvas,
        'magma rising',
        Offset(rect.center.dx, rect.bottom - 3),
        maxWidth: rect.width - 10,
        mutedText: true,
      );
    } else if (name == 'convergent') {
      final leftPlate = Path()
        ..moveTo(rect.left + 8, midY - 10)
        ..lineTo(rect.center.dx + 7, midY - 10)
        ..lineTo(rect.center.dx + 41, midY + 39)
        ..lineTo(rect.center.dx + 25, midY + 45)
        ..lineTo(rect.center.dx - 8, midY + 16)
        ..lineTo(rect.left + 8, midY + 16)
        ..close();
      canvas.drawPath(leftPlate, _stroke);
      canvas.drawRect(
        Rect.fromLTWH(
          rect.center.dx - 2,
          midY - 10,
          rect.width * .47,
          27,
        ),
        _stroke,
      );
      _arrow(
        canvas,
        Offset(rect.left + 15, midY - 29),
        Offset(rect.center.dx - 7, midY - 29),
      );
      _arrow(
        canvas,
        Offset(rect.right - 15, midY - 29),
        Offset(rect.center.dx + 7, midY - 29),
      );
      _text(
        canvas,
        'one plate slides under',
        Offset(rect.center.dx, rect.bottom - 4),
        maxWidth: rect.width - 8,
        mutedText: true,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(
          rect.left + 10,
          midY - 30,
          rect.width * .38,
          72,
        ),
        _stroke,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          rect.center.dx + 4,
          midY - 30,
          rect.width * .38,
          72,
        ),
        _stroke,
      );
      _arrow(
        canvas,
        Offset(rect.left + 19, midY - 43),
        Offset(rect.center.dx - 12, midY - 43),
      );
      _arrow(
        canvas,
        Offset(rect.right - 19, midY + 55),
        Offset(rect.center.dx + 12, midY + 55),
      );
      canvas.drawLine(
        Offset(rect.center.dx, midY - 35),
        Offset(rect.center.dx, midY + 47),
        _faintStroke,
      );
      _text(
        canvas,
        'slide past',
        Offset(rect.center.dx, rect.bottom - 2),
        maxWidth: rect.width - 8,
        mutedText: true,
      );
    }
  }

  void _drawTransform(Canvas canvas, Size size) {
    final faultX = size.width / 2;
    final left = Rect.fromLTWH(36, 62, faultX - 43, 132);
    final right = Rect.fromLTWH(
      faultX + 7,
      62,
      size.width - faultX - 43,
      132,
    );
    canvas.drawRect(left, _stroke);
    canvas.drawRect(right, _stroke);
    _dashedLine(canvas, Offset(faultX, 42), Offset(faultX, 214));
    _arrow(
      canvas,
      Offset(left.center.dx, 43),
      Offset(left.center.dx - 58, 43),
    );
    _arrow(
      canvas,
      Offset(right.center.dx, 213),
      Offset(right.center.dx + 58, 213),
    );
    for (final y in [89.0, 127.0, 168.0]) {
      _star(canvas, Offset(faultX, y), 7);
    }
    _text(
      canvas,
      'fault line',
      Offset(faultX + 39, 112),
      maxWidth: 66,
      mutedText: true,
    );
    _text(
      canvas,
      'opposite horizontal directions',
      Offset(size.width / 2, 235),
      maxWidth: 190,
    );
  }

  void _drawSeismograph(Canvas canvas, Size size) {
    const y = 130.0;
    canvas.drawLine(
      const Offset(24, y),
      Offset(size.width - 24, y),
      _faintStroke,
    );
    final pX = size.width * .32;
    final sX = size.width * .62;
    final path = Path()..moveTo(24, y);
    for (var x = 25.0; x < size.width - 24; x += 3) {
      var amp = 2.0;
      if (x >= pX && x < sX) amp = 8;
      if (x >= sX) amp = 18;
      path.lineTo(x, y + math.sin(x * .36) * amp);
    }
    canvas.drawPath(path, _stroke);
    _dashedLine(canvas, Offset(pX, 65), Offset(pX, 189));
    _dashedLine(canvas, Offset(sX, 65), Offset(sX, 189));
    _text(canvas, 'P wave first', Offset(pX, 42), maxWidth: 75);
    _text(canvas, 'S wave later', Offset(sX, 42), maxWidth: 75);
    _arrow(canvas, Offset(pX + 7, 207), Offset(sX - 7, 207));
    _arrow(canvas, Offset(sX - 7, 207), Offset(pX + 7, 207));
    _text(
      canvas,
      'time gap ∝ distance',
      Offset((pX + sX) / 2, 216),
      maxWidth: 125,
      mutedText: true,
    );
  }

  void _drawWaterCycle(Canvas canvas, Size size) {
    const base = 198.0;
    final oceanRect = Rect.fromLTWH(20, base - 34, size.width * .39, 34);
    canvas.drawRect(oceanRect, _faintStroke);
    _text(
      canvas,
      'ocean',
      oceanRect.center - const Offset(0, 8),
      maxWidth: 60,
    );
    final mountain = Path()
      ..moveTo(size.width * .53, base)
      ..lineTo(size.width * .73, 102)
      ..lineTo(size.width * .94, base)
      ..close();
    canvas.drawPath(mountain, _stroke);
    _sun(canvas, const Offset(50, 50), 16);
    _cloud(canvas, Offset(size.width * .59, 67));
    _cloud(canvas, Offset(size.width * .73, 72));
    _arrow(
      canvas,
      Offset(size.width * .25, base - 40),
      Offset(size.width * .32, 92),
    );
    _text(
      canvas,
      'evaporation',
      Offset(size.width * .22, 111),
      maxWidth: 85,
      mutedText: true,
    );
    _arrow(
      canvas,
      Offset(size.width * .39, 88),
      Offset(size.width * .55, 75),
    );
    _text(
      canvas,
      'condensation',
      Offset(size.width * .49, 44),
      maxWidth: 95,
      mutedText: true,
    );
    _arrow(
      canvas,
      Offset(size.width * .68, 89),
      Offset(size.width * .72, 133),
    );
    _text(
      canvas,
      'precipitation',
      Offset(size.width * .79, 108),
      maxWidth: 88,
      mutedText: true,
    );
    _arrow(
      canvas,
      Offset(size.width * .73, 139),
      Offset(size.width * .48, base - 12),
    );
    _text(
      canvas,
      'runoff',
      Offset(size.width * .57, 168),
      maxWidth: 60,
      mutedText: true,
    );
    final groundwater = Path()
      ..moveTo(size.width * .76, base + 11)
      ..quadraticBezierTo(
        size.width * .48,
        base + 35,
        size.width * .3,
        base + 10,
      );
    canvas.drawPath(groundwater, _faintStroke);
    _arrow(
      canvas,
      Offset(size.width * .48, base + 28),
      Offset(size.width * .31, base + 11),
    );
    _text(
      canvas,
      'groundwater',
      Offset(size.width * .58, base + 28),
      maxWidth: 85,
      mutedText: true,
    );
  }

  void _drawAtmosphere(Canvas canvas, Size size) {
    const layers = <String>[
      'exosphere',
      'thermosphere',
      'mesosphere',
      'stratosphere',
      'troposphere',
    ];
    final rect = Rect.fromLTWH(size.width * .23, 20, size.width * .54, 220);
    final h = rect.height / layers.length;
    for (var i = 0; i < layers.length; i++) {
      final layer = Rect.fromLTWH(
        rect.left,
        rect.top + i * h,
        rect.width,
        h,
      );
      canvas.drawRect(layer, _faintStroke);
      _text(
        canvas,
        layers[i],
        layer.center - const Offset(0, 9),
        maxWidth: 115,
      );
      if (layers[i] == 'stratosphere') {
        final ozoneY = layer.top + layer.height * .58;
        _dashedLine(
          canvas,
          Offset(layer.left + 16, ozoneY),
          Offset(layer.right - 16, ozoneY),
        );
        _text(
          canvas,
          'ozone layer',
          Offset(layer.right + 46, ozoneY - 8),
          maxWidth: 75,
          mutedText: true,
        );
      }
    }
    _text(
      canvas,
      'ground level',
      Offset(rect.left - 46, rect.bottom - 8),
      maxWidth: 70,
      mutedText: true,
    );
    canvas.drawLine(
      Offset(rect.left - 4, rect.bottom),
      Offset(rect.right + 4, rect.bottom),
      _stroke,
    );
  }

  void _earthWithAxis(Canvas canvas, Offset center, double radius) {
    _earth(canvas, center, radius);
    final v = Offset(radius * .65, -radius * 1.55);
    canvas.drawLine(center - v, center + v, _stroke);
  }

  void _earth(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, _fill);
    canvas.drawCircle(center, radius, _stroke);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * .62),
      -.8,
      1.7,
      false,
      _faintStroke,
    );
    canvas.drawLine(
      center + Offset(-radius * .8, 0),
      center + Offset(radius * .8, 0),
      _faintStroke,
    );
  }

  void _sun(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, _fill);
    canvas.drawCircle(center, radius, _stroke);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final a = center +
          Offset(math.cos(angle), math.sin(angle)) * (radius + 4);
      final b = center +
          Offset(math.cos(angle), math.sin(angle)) * (radius + 11);
      canvas.drawLine(a, b, _faintStroke);
    }
  }

  void _moonOrbital(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(center, radius, _fill);
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - radius,
        center.dx + radius,
        center.dy + radius,
      ),
      Paint()..color = ink.withValues(alpha: .18),
    );
    canvas.restore();
    canvas.drawCircle(center, radius, _stroke);
  }

  void _phaseIcon(Canvas canvas, Offset center, double radius, int phase) {
    final darkPaint = Paint()..color = ink.withValues(alpha: .28);
    canvas.drawCircle(center, radius, darkPaint);

    if (phase == 4) {
      canvas.drawCircle(center, radius, _fill);
    } else if (phase != 0) {
      final rightIlluminated = phase < 4;
      final terminatorBulge = switch (phase) {
        1 => .72,
        2 => 0.0,
        3 => -.72,
        5 => .72,
        6 => 0.0,
        7 => -.72,
        _ => 0.0,
      };
      final disc = Rect.fromCircle(center: center, radius: radius);
      final illuminated = Path()
        ..moveTo(center.dx, center.dy - radius)
        ..arcTo(
          disc,
          -math.pi / 2,
          rightIlluminated ? math.pi : -math.pi,
          false,
        )
        ..cubicTo(
          center.dx + terminatorBulge * radius,
          center.dy + radius * .55,
          center.dx + terminatorBulge * radius,
          center.dy - radius * .55,
          center.dx,
          center.dy - radius,
        )
        ..close();
      canvas.drawPath(illuminated, _fill);
    }

    canvas.drawCircle(center, radius, _stroke);
  }

  void _tree(Canvas canvas, Offset base) {
    canvas.drawLine(base, base + const Offset(0, -32), _stroke);
    canvas.drawCircle(
      base + const Offset(0, -43),
      15,
      _faintStroke,
    );
  }

  void _animal(Canvas canvas, Offset base) {
    canvas.drawOval(
      Rect.fromCenter(
        center: base + const Offset(0, -12),
        width: 28,
        height: 14,
      ),
      _stroke,
    );
    canvas.drawCircle(
      base + const Offset(17, -18),
      6,
      _stroke,
    );
    canvas.drawLine(
      base + const Offset(-7, -5),
      base + const Offset(-7, 3),
      _stroke,
    );
    canvas.drawLine(
      base + const Offset(7, -5),
      base + const Offset(7, 3),
      _stroke,
    );
  }

  void _cloud(Canvas canvas, Offset center) {
    final path = Path()
      ..moveTo(center.dx - 28, center.dy + 8)
      ..cubicTo(
        center.dx - 31,
        center.dy - 4,
        center.dx - 17,
        center.dy - 13,
        center.dx - 8,
        center.dy - 8,
      )
      ..cubicTo(
        center.dx - 1,
        center.dy - 23,
        center.dx + 20,
        center.dy - 18,
        center.dx + 21,
        center.dy - 5,
      )
      ..cubicTo(
        center.dx + 37,
        center.dy - 5,
        center.dx + 39,
        center.dy + 11,
        center.dx + 25,
        center.dy + 13,
      )
      ..lineTo(center.dx - 20, center.dy + 13)
      ..close();
    canvas.drawPath(path, _faintStroke);
  }

  void _star(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final r = i.isEven ? radius : radius * .35;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, _stroke);
  }

  void _arrow(Canvas canvas, Offset from, Offset to) {
    canvas.drawLine(from, to, _stroke);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const head = 7.0;
    canvas.drawLine(
      to,
      to - Offset(math.cos(angle - .55), math.sin(angle - .55)) * head,
      _stroke,
    );
    canvas.drawLine(
      to,
      to - Offset(math.cos(angle + .55), math.sin(angle + .55)) * head,
      _stroke,
    );
  }

  void _arcArrow(Canvas canvas, Rect rect, double start, double sweep) {
    canvas.drawArc(rect, start, sweep, false, _stroke);
    final end = start + sweep;
    final center = rect.center;
    final p = Offset(
      center.dx + math.cos(end) * rect.width / 2,
      center.dy + math.sin(end) * rect.height / 2,
    );
    final tangent = end + (sweep >= 0 ? math.pi / 2 : -math.pi / 2);
    canvas.drawLine(
      p,
      p - Offset(math.cos(tangent - .55), math.sin(tangent - .55)) * 7,
      _stroke,
    );
    canvas.drawLine(
      p,
      p - Offset(math.cos(tangent + .55), math.sin(tangent + .55)) * 7,
      _stroke,
    );
  }

  void _dashedLine(Canvas canvas, Offset from, Offset to) {
    final delta = to - from;
    final distance = delta.distance;
    if (distance == 0) return;
    final unit = delta / distance;
    for (var d = 0.0; d < distance; d += 8) {
      final end = math.min(d + 4, distance);
      canvas.drawLine(
        from + unit * d,
        from + unit * end,
        _faintStroke,
      );
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset center, {
    double maxWidth = 100,
    bool mutedText = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: mutedText ? smallStyle : labelStyle,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
    )..layout(maxWidth: maxWidth);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, 0),
    );
  }

  @override
  bool shouldRepaint(covariant _EarthSciencePainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.spec != spec ||
        oldDelegate.ink != ink ||
        oldDelegate.muted != muted ||
        oldDelegate.faint != faint ||
        oldDelegate.background != background ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.smallStyle != smallStyle;
  }
}
