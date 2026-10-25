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
    if (illustrationKey is! String || illustrationKey.trim().isEmpty) {
      return null;
    }

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
      _earthWithAxis(
        canvas,
        earth,
        15,
        showEquator: true,
        showNorthMarker: true,
      );
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
      'N hemisphere; axis stays pointed the same way',
      Offset(center.dx, 238),
      maxWidth: 230,
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
    _earthWithAxis(
      canvas,
      centers[0],
      25,
      dayNight: true,
      showEquator: true,
    );
    _arcArrow(
      canvas,
      Rect.fromCircle(center: centers[0], radius: 38),
      -.8,
      4.5,
    );
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
    _earthWithAxis(
      canvas,
      centers[1] + const Offset(40, 0),
      16,
      showEquator: true,
    );
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

    _earthWithAxis(canvas, centers[2], 25, showEquator: true);
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
    for (var d = -22.0; d <= 22; d += 11) {
      _arrow(
        canvas,
        Offset(sun.dx - 27, sun.dy + d),
        Offset(left.dx + 24, left.dy + d * .1),
      );
      _arrow(
        canvas,
        Offset(sun.dx + 27, sun.dy + d),
        Offset(right.dx - 22, right.dy + d * 1.8),
      );
    }
    _earthWithAxis(
      canvas,
      left,
      22,
      showEquator: true,
      showNorthMarker: true,
    );
    _earthWithAxis(
      canvas,
      right,
      22,
      showEquator: true,
      showNorthMarker: true,
    );
    _text(
      canvas,
      '23.5°',
      left + const Offset(17, -51),
      maxWidth: 50,
      mutedText: true,
    );
    _text(
      canvas,
      'N hemisphere',
      left + const Offset(-14, -70),
      maxWidth: 88,
      mutedText: true,
    );
    _text(
      canvas,
      'N hemisphere',
      right + const Offset(14, -70),
      maxWidth: 88,
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
    canvas
      ..drawLine(
        left + const Offset(22, -9),
        left + const Offset(22, 9),
        _faintStroke,
      )
      ..drawLine(
        right + const Offset(-20, -9),
        right + const Offset(-20, 9),
        _faintStroke,
      );
    _text(
      canvas,
      'direct incidence',
      left + const Offset(0, 85),
      maxWidth: 105,
      mutedText: true,
    );
    _text(
      canvas,
      'oblique incidence',
      right + const Offset(0, 85),
      maxWidth: 105,
      mutedText: true,
    );
    _text(
      canvas,
      'summer direct rays; winter oblique rays',
      Offset(size.width / 2, 225),
      maxWidth: 240,
      mutedText: true,
    );
  }

  void _drawSiderealDay(Canvas canvas, Size size) {
    final sun = Offset(size.width * .72, 135);
    _sun(canvas, sun, 24);
    final a = Offset(size.width * .25, 150);
    final b = Offset(size.width * .37, 82);
    final orbit = Rect.fromCenter(
      center: sun,
      width: size.width * .95,
      height: 230,
    );
    canvas.drawArc(orbit, math.pi * .72, .36, false, _faintStroke);
    _earthWithAxis(canvas, a, 18, showSurfaceMarker: true);
    _earthWithAxis(canvas, b, 18, showSurfaceMarker: true);
    final firstMarker = _surfaceMarker(a, 18);
    final secondMarker = _surfaceMarker(b, 18);
    _dashedLine(canvas, firstMarker, Offset(firstMarker.dx, 27));
    _dashedLine(canvas, secondMarker, sun);
    _text(
      canvas,
      'same point on Earth',
      Offset(size.width * .23, 30),
      maxWidth: 110,
      mutedText: true,
    );
    _text(
      canvas,
      'Sun alignment',
      Offset(size.width * .58, 88),
      maxWidth: 90,
      mutedText: true,
    );
    _arcArrow(canvas, orbit, math.pi * .72, .36);
    for (var x = 35.0; x < size.width - 30; x += 42) {
      _star(canvas, Offset(x, 24), 3);
    }
    _text(
      canvas,
      'distant stars',
      Offset(size.width / 2, 4),
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
    final earth = Path()
      ..moveTo(42, 190)
      ..quadraticBezierTo(size.width / 2, 54, size.width - 42, 190)
      ..lineTo(size.width - 42, 210)
      ..lineTo(42, 210)
      ..close();
    canvas.drawPath(earth, _stroke);
    final ocean = Path()
      ..moveTo(74, 177)
      ..quadraticBezierTo(118, 157, 166, 174)
      ..lineTo(178, 201)
      ..lineTo(74, 201)
      ..close();
    canvas
      ..drawPath(ocean, Paint()..color = ink.withValues(alpha: .08))
      ..drawPath(ocean, _faintStroke);
    final air = Rect.fromLTWH(32, 18, size.width - 64, 154);
    canvas
      ..drawArc(air, math.pi, math.pi, false, _faintStroke)
      ..drawArc(
        Rect.fromLTWH(48, 31, size.width - 96, 128),
        math.pi,
        math.pi,
        false,
        _faintStroke,
      );
    _text(canvas, 'atmosphere', Offset(size.width / 2, 34), maxWidth: 90);
    _text(canvas, 'hydrosphere', const Offset(123, 181), maxWidth: 92);
    _text(canvas, 'lithosphere', const Offset(252, 190), maxWidth: 92);
    _tree(canvas, const Offset(280, 190));
    _animal(canvas, const Offset(300, 199));
    _fish(canvas, const Offset(120, 190));
    _bird(canvas, const Offset(272, 87));
    _text(canvas, 'biosphere', const Offset(280, 103), maxWidth: 82);
    _text(
      canvas,
      'life on land, in water, and in air',
      Offset(size.width / 2, 234),
      maxWidth: 220,
      mutedText: true,
    );
  }

  void _drawMoonPhases(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 128);
    final radiusX = size.width * .31;
    const radiusY = 75.0;
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
      final phaseCenter = p + const Offset(0, 18);
      _phaseIcon(canvas, phaseCenter, 7, i);
      final labelOffset = switch (i) {
        0 => const Offset(48, 172),
        1 => const Offset(70, 209),
        2 => const Offset(195, 230),
        3 => const Offset(320, 209),
        4 => const Offset(347, 121),
        5 => const Offset(320, 50),
        6 => const Offset(195, 6),
        _ => const Offset(70, 50),
      };
      _text(
        canvas,
        names[i],
        labelOffset,
        maxWidth: 82,
        mutedText: true,
      );
    }
    _text(
      canvas,
      'outer discs: view from Earth',
      Offset(size.width / 2, 249),
      maxWidth: 190,
      mutedText: true,
    );
  }

  void _drawHalfLife(Canvas canvas, Size size, List<double> fractions) {
    final labels = fractions.length == 4
        ? const ['1', '1/2', '1/4', '1/8']
        : const ['100%', '50%', '25%'];
    final barWidth = math.min<double>(
      78,
      (size.width - 42) / fractions.length - 10,
    );
    for (var i = 0; i < fractions.length; i++) {
      final x = 22 + i * ((size.width - 44) / fractions.length);
      final rect = Rect.fromLTWH(x, 85, barWidth, 74);
      canvas
        ..drawRect(rect, Paint()..color = ink.withValues(alpha: .08))
        ..drawRect(rect, _faintStroke);
      final parentRect = Rect.fromLTWH(x, 85, barWidth * fractions[i], 74);
      canvas
        ..drawRect(
          parentRect,
          Paint()..color = ink.withValues(alpha: .25),
        )
        ..drawRect(parentRect, _stroke);
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
        Offset(size.width * .28, 213),
        maxWidth: 120,
      );
      canvas
        ..drawRect(
          Rect.fromLTWH(size.width * .07, 215, 12, 10),
          Paint()..color = ink.withValues(alpha: .25),
        )
        ..drawRect(
          Rect.fromLTWH(size.width * .07, 215, 12, 10),
          _faintStroke,
        );
      _text(
        canvas,
        'stable daughter remainder',
        Offset(size.width * .72, 213),
        maxWidth: 140,
        mutedText: true,
      );
      canvas
        ..drawRect(
          Rect.fromLTWH(size.width * .52, 215, 12, 10),
          Paint()..color = ink.withValues(alpha: .08),
        )
        ..drawRect(
          Rect.fromLTWH(size.width * .52, 215, 12, 10),
          _faintStroke,
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
        '25% remaining = 2 billion years',
        Offset(size.width / 2, 233),
        maxWidth: 190,
        mutedText: true,
      );
    }
  }

  void _drawStratigraphy(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * .22, 40, size.width * .56, 184);
    const labels = ['Z', 'Y', 'X', 'W'];
    canvas.drawRect(rect, Paint()..color = ink.withValues(alpha: .06));
    for (var i = 0; i < 4; i++) {
      final top = rect.top + i * 46;
      if (i > 0) {
        canvas.drawLine(
          Offset(rect.left, top),
          Offset(rect.right, top),
          _faintStroke,
        );
      }
      _text(
        canvas,
        labels[i],
        Offset(rect.center.dx, top + 15),
        maxWidth: 36,
      );
    }
    canvas.drawRect(rect, _stroke);
    final bracketX = rect.right + 26;
    canvas
      ..drawLine(
        Offset(bracketX - 8, rect.top),
        Offset(bracketX, rect.top),
        _faintStroke,
      )
      ..drawLine(
        Offset(bracketX, rect.top),
        Offset(bracketX, rect.bottom),
        _faintStroke,
      )
      ..drawLine(
        Offset(bracketX - 8, rect.bottom),
        Offset(bracketX, rect.bottom),
        _faintStroke,
      );
    _text(
      canvas,
      'youngest',
      Offset(bracketX + 37, rect.top + 2),
      maxWidth: 65,
    );
    _text(
      canvas,
      'oldest',
      Offset(bracketX + 34, rect.bottom - 16),
      maxWidth: 60,
    );
  }

  void _drawComet(Canvas canvas, Size size) {
    final orbit = Rect.fromCenter(
      center: Offset(size.width / 2, 132),
      width: size.width * .72,
      height: 175,
    );
    final a = orbit.width / 2;
    final b = orbit.height / 2;
    final c = math.sqrt(a * a - b * b);
    final sun = Offset(orbit.center.dx - c, orbit.center.dy);
    canvas.drawOval(orbit, _faintStroke);
    final positions = <Offset>[
      _ellipsePoint(orbit, math.pi * .74),
      _ellipsePoint(orbit, math.pi * 1.84),
    ];
    _sun(canvas, sun, 23);
    for (final p in positions) {
      final outward = p - sun;
      final length = math.sqrt(
        outward.dx * outward.dx + outward.dy * outward.dy,
      );
      final unit = Offset(outward.dx / length, outward.dy / length);
      final side = Offset(-unit.dy, unit.dx);
      final tailStart = p + unit * 4;
      final tailEnd = p + unit * 54;
      final tail = Path()
        ..moveTo(tailStart.dx + side.dx * 4, tailStart.dy + side.dy * 4)
        ..quadraticBezierTo(
          p.dx + unit.dx * 27 + side.dx * 2,
          p.dy + unit.dy * 27 + side.dy * 2,
          tailEnd.dx,
          tailEnd.dy,
        )
        ..quadraticBezierTo(
          p.dx + unit.dx * 27 - side.dx * 2,
          p.dy + unit.dy * 27 - side.dy * 2,
          tailStart.dx - side.dx * 4,
          tailStart.dy - side.dy * 4,
        )
        ..close();
      canvas
        ..drawPath(tail, Paint()..color = ink.withValues(alpha: .12))
        ..drawPath(tail, _faintStroke)
        ..drawCircle(p, 9, _faintStroke)
        ..drawCircle(p, 4, Paint()..color = ink.withValues(alpha: .26));
      for (final offset in [1.0, -1.0]) {
        final wisp = Path()
          ..moveTo(
            p.dx + unit.dx * 6 + side.dx * offset * 3,
            p.dy + unit.dy * 6 + side.dy * offset * 3,
          )
          ..quadraticBezierTo(
            p.dx + unit.dx * 28 + side.dx * offset * 7,
            p.dy + unit.dy * 28 + side.dy * offset * 7,
            p.dx + unit.dx * 58 + side.dx * offset * 11,
            p.dy + unit.dy * 58 + side.dy * offset * 11,
          );
        canvas.drawPath(wisp, _faintStroke);
      }
      final labelPoint = p.dy < orbit.center.dy
          ? const Offset(305, 42)
          : const Offset(150, 228);
      _text(
        canvas,
        'tail away from Sun',
        labelPoint,
        maxWidth: 90,
        mutedText: true,
      );
    }
  }

  Offset _ellipsePoint(Rect ellipse, double angle) {
    return Offset(
      ellipse.center.dx + ellipse.width / 2 * math.cos(angle),
      ellipse.center.dy + ellipse.height / 2 * math.sin(angle),
    );
  }

  void _drawSeismicCore(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 126);
    final shadowZone = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + 88, center.dy - 34)
      ..arcTo(
        Rect.fromCircle(center: center, radius: 92),
        -.37,
        .74,
        false,
      )
      ..close();
    canvas
      ..drawPath(
        shadowZone,
        Paint()..color = ink.withValues(alpha: .08),
      )
      ..drawCircle(center, 92, _stroke)
      ..drawCircle(center, 58, _faintStroke)
      ..drawCircle(center, 28, _faintStroke);
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

    final pTargets = <Offset>[
      center + const Offset(79, -39),
      center + const Offset(87, 0),
      center + const Offset(76, 42),
    ];
    for (final target in pTargets) {
      final entry = center + Offset(-43, (target.dy - center.dy) * .62);
      final exit = center + Offset(44, (target.dy - center.dy) * .76);
      final path = Path()
        ..moveTo(quake.dx, quake.dy)
        ..quadraticBezierTo(
          center.dx - 67,
          entry.dy - 20,
          entry.dx,
          entry.dy,
        )
        ..quadraticBezierTo(
          center.dx,
          target.dy < center.dy ? center.dy - 30 : center.dy + 30,
          exit.dx,
          exit.dy,
        )
        ..quadraticBezierTo(
          center.dx + 68,
          target.dy - 10,
          target.dx,
          target.dy,
        );
      canvas.drawPath(path, _stroke);
      _arrow(
        canvas,
        exit - const Offset(12, 0),
        exit,
      );
    }
    _text(
      canvas,
      'P waves bend through core',
      center + const Offset(70, 52),
      maxWidth: 125,
    );

    final sEnds = <Offset>[
      center + const Offset(-44, -38),
      center + const Offset(-55, 0),
      center + const Offset(-43, 40),
    ];
    for (final sEnd in sEnds) {
      final sPath = Path()
        ..moveTo(quake.dx, quake.dy)
        ..quadraticBezierTo(
          center.dx - 76,
          sEnd.dy - 24,
          sEnd.dx,
          sEnd.dy,
        );
      canvas.drawPath(sPath, _stroke);
      _cross(canvas, sEnd, 5);
    }
    _text(
      canvas,
      'S waves stop',
      center + const Offset(-76, 51),
      maxWidth: 92,
    );
    _text(
      canvas,
      'S-wave shadow zone',
      center + const Offset(0, 218),
      maxWidth: 130,
      mutedText: true,
    );
    _bracket(
      canvas,
      center + const Offset(88, -34),
      center + const Offset(88, 34),
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
        center + Offset(math.cos(angle) * 103, math.sin(angle) * 76),
      );
    }
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      _arcArrow(
        canvas,
        Rect.fromCenter(center: center, width: 188, height: 142),
        -math.pi / 2 + i * 2 * math.pi / labels.length + .18,
        2 * math.pi / labels.length - .36,
      );
      _text(
        canvas,
        process[i],
        center +
            Offset(
              math.cos(-math.pi / 2 + (i + .5) * 2 * math.pi / labels.length) *
                  121,
              math.sin(-math.pi / 2 + (i + .5) * 2 * math.pi / labels.length) *
                  94,
            ),
        maxWidth: 88,
        mutedText: true,
      );
      canvas
        ..drawCircle(a, 25, Paint()..color = background)
        ..drawCircle(a, 25, _faintStroke);
      _text(
        canvas,
        labels[i],
        a - const Offset(0, 12),
        maxWidth: 72,
      );
    }
    for (final point in [points[1], points[3], points[4]]) {
      final direction = points[0] - point;
      final unit = direction / direction.distance;
      final start = point + unit * 27;
      final end = points[0] - unit * 25;
      _arrow(canvas, start, end);
    }
    _text(
      canvas,
      'any rock can melt to magma',
      Offset(size.width / 2, 246),
      maxWidth: 190,
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
    canvas.drawOval(
      Rect.fromCenter(center: centers[0], width: 74, height: 58),
      _faintStroke,
    );
    for (var i = 0; i < 42; i++) {
      final angle = i * .73;
      final radialX = 7 + (i * 17 % 32);
      final radialY = 5 + (i * 11 % 22);
      canvas.drawCircle(
        centers[0] +
            Offset(math.cos(angle) * radialX, math.sin(angle) * radialY),
        1.2 + (i % 3) * .3,
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
    _arcArrow(
      canvas,
      Rect.fromCenter(center: centers[1], width: 88, height: 40),
      .35,
      3.9,
    );
    canvas.drawOval(
      Rect.fromCenter(center: centers[2], width: 80, height: 30),
      _faintStroke,
    );
    _sun(canvas, centers[2], 14);
    for (var i = 0; i < 10; i++) {
      final angle = i * .7;
      canvas.drawCircle(
        centers[2] + Offset(math.cos(angle) * 28, math.sin(angle) * 10),
        1.2,
        Paint()..color = ink,
      );
    }
    _arcArrow(
      canvas,
      Rect.fromCenter(center: centers[2], width: 92, height: 42),
      .35,
      3.9,
    );
    canvas.drawOval(
      Rect.fromCenter(center: centers[3], width: 80, height: 30),
      _faintStroke,
    );
    _sun(canvas, centers[3], 12);
    for (final dx in [-30.0, -15.0, 13.0, 30.0]) {
      canvas.drawCircle(
        centers[3] + Offset(dx, dx.sign * 7),
        3,
        _stroke,
      );
    }
    const captions = <String>[
      'gas + dust cloud',
      'flattened disk',
      'Sun forms',
      'clumps in disk',
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
      canvas
        ..drawRect(
          Rect.fromLTWH(
            rect.left + 8,
            midY - 12,
            rect.width * .42,
            34,
          ),
          _stroke,
        )
        ..drawRect(
          Rect.fromLTWH(
            rect.center.dx + 5,
            midY - 12,
            rect.width * .42,
            34,
          ),
          _stroke,
        );
      final plume = Path()
        ..moveTo(rect.center.dx - 10, rect.bottom - 10)
        ..quadraticBezierTo(
          rect.center.dx - 7,
          midY + 16,
          rect.center.dx,
          midY + 2,
        )
        ..quadraticBezierTo(
          rect.center.dx + 7,
          midY + 16,
          rect.center.dx + 10,
          rect.bottom - 10,
        )
        ..close();
      canvas
        ..drawPath(plume, Paint()..color = ink.withValues(alpha: .14))
        ..drawPath(plume, _faintStroke);
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
      canvas
        ..drawPath(leftPlate, _stroke)
        ..drawRect(
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
      final faultX = rect.center.dx;
      final leftPlate = Path()
        ..moveTo(rect.left + 8, midY - 11)
        ..lineTo(faultX - 3, midY - 11)
        ..lineTo(faultX - 7, midY + 31)
        ..lineTo(rect.left + 8, midY + 31)
        ..close();
      final rightPlate = Path()
        ..moveTo(faultX + 3, midY - 11)
        ..lineTo(rect.right - 8, midY - 11)
        ..lineTo(rect.right - 8, midY + 31)
        ..lineTo(faultX + 7, midY + 31)
        ..close();
      canvas
        ..drawPath(leftPlate, _stroke)
        ..drawPath(rightPlate, _stroke)
        ..drawLine(
          Offset(rect.left + 8, midY),
          Offset(rect.right - 8, midY),
          _faintStroke,
        )
        ..drawLine(
          Offset(faultX, midY - 11),
          Offset(faultX, midY + 31),
          _faintStroke,
        );
      _arrow(
        canvas,
        Offset(faultX - 10, midY - 28),
        Offset(rect.left + 20, midY - 28),
      );
      _arrow(
        canvas,
        Offset(faultX + 10, midY + 22),
        Offset(rect.right - 20, midY + 22),
      );
      for (final y in [midY + 1, midY + 14, midY + 27]) {
        _earthquakeSymbol(canvas, Offset(faultX, y), 5);
      }
      _text(
        canvas,
        'slide past; earthquakes',
        Offset(rect.center.dx, rect.bottom - 2),
        maxWidth: rect.width - 4,
        mutedText: true,
      );
    }
  }

  void _drawTransform(Canvas canvas, Size size) {
    const faultY = 128.5;
    final top = Path()
      ..moveTo(36, 55)
      ..lineTo(size.width - 36, 55)
      ..lineTo(size.width - 36, 119)
      ..lineTo(size.width * .63, 121)
      ..lineTo(size.width * .5, 118)
      ..lineTo(size.width * .36, 121)
      ..lineTo(36, 119)
      ..close();
    final bottom = Path()
      ..moveTo(36, 138)
      ..lineTo(size.width * .36, 136)
      ..lineTo(size.width * .5, 139)
      ..lineTo(size.width * .63, 136)
      ..lineTo(size.width - 36, 138)
      ..lineTo(size.width - 36, 201)
      ..lineTo(36, 201)
      ..close();
    canvas
      ..drawPath(top, _stroke)
      ..drawPath(bottom, _stroke);
    _dashedLine(
      canvas,
      const Offset(38, faultY),
      Offset(size.width - 38, faultY),
    );
    canvas.drawLine(
      const Offset(38, faultY),
      Offset(size.width - 38, faultY),
      _faintStroke,
    );
    _arrow(
      canvas,
      Offset(size.width - 91, 87),
      const Offset(91, 87),
    );
    _arrow(
      canvas,
      const Offset(91, 169),
      Offset(size.width - 91, 169),
    );
    for (final x in [130.0, 195.0, 260.0]) {
      _earthquakeSymbol(canvas, Offset(x, faultY), 7);
    }
    _earthquakeSymbol(canvas, Offset(size.width * .77, faultY + 40), 6);
    _text(
      canvas,
      'fault line',
      Offset(size.width - 67, faultY - 25),
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
    _text(canvas, 'P wave first', Offset(pX, 42), maxWidth: 82);
    _text(canvas, 'S wave later', Offset(sX, 42), maxWidth: 82);
    _arrow(canvas, Offset(pX + 7, 207), Offset(sX - 7, 207));
    _text(
      canvas,
      'time gap proportional to distance',
      Offset((pX + sX) / 2, 216),
      maxWidth: 190,
      mutedText: true,
    );
  }

  void _drawWaterCycle(Canvas canvas, Size size) {
    const base = 202.0;
    final ocean = Path()
      ..moveTo(18, base - 25)
      ..quadraticBezierTo(47, base - 32, 78, base - 25)
      ..quadraticBezierTo(108, base - 18, 145, base - 25)
      ..lineTo(145, base + 8)
      ..lineTo(18, base + 8)
      ..close();
    canvas
      ..drawPath(ocean, Paint()..color = ink.withValues(alpha: .08))
      ..drawPath(ocean, _faintStroke);
    _text(canvas, 'ocean', const Offset(82, 186), maxWidth: 60);
    final mountain = Path()
      ..moveTo(size.width * .41, base)
      ..lineTo(size.width * .53, 158)
      ..lineTo(size.width * .61, 180)
      ..lineTo(size.width * .73, 113)
      ..lineTo(size.width * .95, base)
      ..close();
    canvas
      ..drawPath(mountain, Paint()..color = ink.withValues(alpha: .06))
      ..drawPath(mountain, _stroke)
      ..drawLine(
        Offset(size.width * .53, 158),
        Offset(size.width * .73, 113),
        _faintStroke,
      );
    _sun(canvas, const Offset(50, 50), 16);
    for (var i = 0; i < 3; i++) {
      _arrow(
        canvas,
        Offset(42 + i * 9, 72),
        Offset(60 + i * 9, 145),
      );
    }
    _text(canvas, 'Sun heats ocean', const Offset(116, 46));
    _cloud(canvas, const Offset(224, 64));
    _cloud(canvas, const Offset(286, 66));
    _arrow(
      canvas,
      const Offset(100, 175),
      const Offset(115, 104),
    );
    _text(
      canvas,
      'evaporation',
      const Offset(50, 154),
      maxWidth: 75,
      mutedText: true,
    );
    _text(
      canvas,
      'water vapor rises',
      const Offset(152, 92),
      maxWidth: 105,
      mutedText: true,
    );
    _arrow(
      canvas,
      const Offset(145, 89),
      const Offset(205, 71),
    );
    _text(
      canvas,
      'condensation',
      const Offset(196, 32),
      maxWidth: 95,
      mutedText: true,
    );
    _arrow(
      canvas,
      const Offset(281, 85),
      const Offset(273, 148),
    );
    _text(
      canvas,
      'precipitation',
      const Offset(332, 96),
      maxWidth: 86,
      mutedText: true,
    );
    _arrow(
      canvas,
      const Offset(270, 164),
      const Offset(154, 194),
    );
    _text(
      canvas,
      'runoff to ocean',
      const Offset(175, 164),
      maxWidth: 108,
      mutedText: true,
    );
    final groundwater = Path()
      ..moveTo(size.width * .82, base + 14)
      ..quadraticBezierTo(
        size.width * .56,
        base + 33,
        size.width * .26,
        base + 10,
      );
    canvas.drawPath(groundwater, _faintStroke);
    _arrow(
      canvas,
      Offset(size.width * .49, base + 25),
      Offset(size.width * .28, base + 11),
    );
    _text(
      canvas,
      'groundwater to ocean',
      const Offset(306, 239),
      maxWidth: 135,
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

  void _earthWithAxis(
    Canvas canvas,
    Offset center,
    double radius, {
    bool showEquator = false,
    bool showNorthMarker = false,
    bool dayNight = false,
    bool showSurfaceMarker = false,
  }) {
    _earth(canvas, center, radius, dayNight: dayNight);
    final v = Offset(radius * .65, -radius * 1.55);
    canvas.drawLine(center - v, center + v, _stroke);
    if (showEquator) {
      final equator = Offset(-v.dy, v.dx) / v.distance * radius * .88;
      canvas.drawLine(center - equator, center + equator, _faintStroke);
    }
    if (showNorthMarker) {
      _text(
        canvas,
        'N',
        center + v / v.distance * radius * .52 - const Offset(0, 5),
        maxWidth: 14,
        mutedText: true,
      );
    }
    if (showSurfaceMarker) {
      final marker = _surfaceMarker(center, radius);
      canvas
        ..drawCircle(marker, 3, Paint()..color = ink)
        ..drawCircle(marker, 5, _faintStroke);
    }
  }

  void _earth(
    Canvas canvas,
    Offset center,
    double radius, {
    bool dayNight = false,
  }) {
    canvas.drawCircle(center, radius, _fill);
    if (dayNight) {
      canvas
        ..save()
        ..clipPath(
          Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
        )
        ..drawRect(
          Rect.fromLTWH(
            center.dx,
            center.dy - radius,
            radius,
            radius * 2,
          ),
          Paint()..color = ink.withValues(alpha: .16),
        )
        ..restore();
    }
    canvas
      ..drawCircle(center, radius, _stroke)
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius * .62),
        -.8,
        1.7,
        false,
        _faintStroke,
      );
  }

  Offset _surfaceMarker(Offset center, double radius) {
    return center + Offset(radius * .78, -radius * .18);
  }

  void _sun(Canvas canvas, Offset center, double radius) {
    canvas
      ..drawCircle(center, radius, _fill)
      ..drawCircle(center, radius, _stroke);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final a =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius + 4);
      final b =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius + 11);
      canvas.drawLine(a, b, _faintStroke);
    }
  }

  void _moonOrbital(Canvas canvas, Offset center, double radius) {
    canvas
      ..save()
      ..clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      )
      ..drawCircle(center, radius, _fill)
      ..drawRect(
        Rect.fromLTRB(
          center.dx,
          center.dy - radius,
          center.dx + radius,
          center.dy + radius,
        ),
        Paint()..color = ink.withValues(alpha: .18),
      )
      ..restore()
      ..drawCircle(center, radius, _stroke);
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
    canvas
      ..drawLine(base, base + const Offset(0, -32), _stroke)
      ..drawCircle(
        base + const Offset(0, -43),
        15,
        _faintStroke,
      );
  }

  void _animal(Canvas canvas, Offset base) {
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: base + const Offset(0, -12),
          width: 28,
          height: 14,
        ),
        _stroke,
      )
      ..drawCircle(
        base + const Offset(17, -18),
        6,
        _stroke,
      )
      ..drawLine(
        base + const Offset(-7, -5),
        base + const Offset(-7, 3),
        _stroke,
      )
      ..drawLine(
        base + const Offset(7, -5),
        base + const Offset(7, 3),
        _stroke,
      );
  }

  void _fish(Canvas canvas, Offset center) {
    final body = Rect.fromCenter(center: center, width: 22, height: 12);
    canvas
      ..drawOval(body, _stroke)
      ..drawPath(
        Path()
          ..moveTo(body.left, center.dy)
          ..lineTo(body.left - 9, body.top - 4)
          ..lineTo(body.left - 9, body.bottom + 4)
          ..close(),
        _stroke,
      )
      ..drawCircle(center + const Offset(6, -2), 1.2, Paint()..color = ink);
  }

  void _bird(Canvas canvas, Offset center) {
    final path = Path()
      ..moveTo(center.dx - 12, center.dy)
      ..quadraticBezierTo(
        center.dx - 5,
        center.dy - 7,
        center.dx,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + 7,
        center.dy - 7,
        center.dx + 14,
        center.dy,
      );
    canvas.drawPath(path, _stroke);
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

  void _earthquakeSymbol(Canvas canvas, Offset center, double radius) {
    final path = Path()
      ..moveTo(center.dx - radius, center.dy + radius * .55)
      ..lineTo(center.dx - radius * .35, center.dy - radius * .55)
      ..lineTo(center.dx, center.dy + radius * .15)
      ..lineTo(center.dx + radius * .42, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy + radius * .55);
    canvas
      ..drawPath(path, _stroke)
      ..drawCircle(center, radius * .2, Paint()..color = ink);
  }

  void _cross(Canvas canvas, Offset center, double radius) {
    canvas
      ..drawLine(
        center + Offset(-radius, -radius),
        center + Offset(radius, radius),
        _stroke,
      )
      ..drawLine(
        center + Offset(-radius, radius),
        center + Offset(radius, -radius),
        _stroke,
      );
  }

  void _bracket(Canvas canvas, Offset top, Offset bottom) {
    final x = math.max(top.dx, bottom.dx);
    canvas
      ..drawLine(top, bottom, _faintStroke)
      ..drawLine(top, Offset(x - 7, top.dy), _faintStroke)
      ..drawLine(bottom, Offset(x - 7, bottom.dy), _faintStroke);
  }

  void _arrow(Canvas canvas, Offset from, Offset to) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const head = 7.0;
    canvas
      ..drawLine(from, to, _stroke)
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

  void _arcArrow(Canvas canvas, Rect rect, double start, double sweep) {
    canvas.drawArc(rect, start, sweep, false, _stroke);
    final end = start + sweep;
    final center = rect.center;
    final p = Offset(
      center.dx + math.cos(end) * rect.width / 2,
      center.dy + math.sin(end) * rect.height / 2,
    );
    final tangent = end + (sweep >= 0 ? math.pi / 2 : -math.pi / 2);
    canvas
      ..drawLine(
        p,
        p - Offset(math.cos(tangent - .55), math.sin(tangent - .55)) * 7,
        _stroke,
      )
      ..drawLine(
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
