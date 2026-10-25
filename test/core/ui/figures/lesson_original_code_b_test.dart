import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/earth_science_diagram_figure.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/figures/physics_energy_diagram_figure.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

void main() {
  const cases = <_FigureCase>[
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'seasonal-orbit',
        'illustrationKey': 'science/earth-science-astronomy/earths-motions#1',
        'earthPositions': 4,
        'axisDirection': 'constant',
        'hemisphereTilt': ['toward Sun', 'away from Sun'],
      },
      'earthPositions',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'earth-motion-triptych',
        'illustrationKey': 'science/earth-science-astronomy/earths-motions#2',
        'motions': [
          {'name': 'rotation', 'effect': 'day/night', 'motion': 'spin on axis'},
          {
            'name': 'revolution',
            'effect': 'seasons',
            'motion': 'orbit Sun with tilted axis',
          },
          {
            'name': 'precession',
            'effect': 'axis wobble',
            'motion': 'slow wobble',
          },
        ],
      },
      'motions',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'seasonal-tilt-comparison',
        'illustrationKey': 'science/earth-science-astronomy/earths-motions#3',
        'earthPositions': 2,
        'axisTiltDegrees': 23.5,
        'northernHemisphereStates': [
          'toward Sun (summer)',
          'away from Sun (winter)',
        ],
        'sunlightAngles': 'different',
      },
      'axisTiltDegrees',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'sidereal-solar-day',
        'illustrationKey': 'science/earth-science-astronomy/earths-motions#4',
        'earthPositions': 2,
        'siderealReference': 'distant stars',
        'extraRotation': 'a few extra degrees',
        'result': 'solar day slightly longer',
      },
      'extraRotation',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'earth-subsystems',
        'illustrationKey':
            'science/earth-science-astronomy/earths-subsystems#1',
        'features': [
          {'label': 'lithosphere', 'feature': 'rocky ground'},
          {'label': 'hydrosphere', 'feature': 'ocean water'},
          {'label': 'atmosphere', 'feature': 'surrounding air'},
          {
            'label': 'biosphere',
            'feature': 'plants/animals living across all three',
          },
        ],
      },
      'features',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'moon-phases',
        'illustrationKey':
            'science/earth-science-astronomy/eclipses-and-moon-phases#1',
        'moonPositions': 8,
        'sunlightFrom': 'one side',
        'phaseNames': [
          'new moon',
          'waxing crescent',
          'first quarter',
          'waxing gibbous',
          'full moon',
          'waning gibbous',
          'last quarter',
          'waning crescent',
        ],
        'showEarthView': true,
      },
      'phaseNames',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'half-life-halving',
        'illustrationKey':
            'science/earth-science-astronomy/fossils-and-geologic-time#1',
        'halfLifeSteps': 3,
        'parentFractions': ['1', '1/2', '1/4', '1/8'],
        'daughterMaterial': 'stable remainder',
      },
      'parentFractions',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'stratigraphy-stack',
        'illustrationKey':
            'science/earth-science-astronomy/fossils-and-geologic-time#2',
        'layersBottomToTop': ['W', 'X', 'Y', 'Z'],
        'oldest': 'W',
        'youngest': 'Z',
      },
      'layersBottomToTop',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'half-life-billion-years',
        'illustrationKey':
            'science/earth-science-astronomy/fossils-and-geologic-time#3',
        'parentPercentages': [100, 50, 25],
        'halfLife': '1 billion years',
        'halfLifeLabels': ['1 half-life', '2 half-lives'],
        'result': '2 billion years',
      },
      'parentPercentages',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'comet-tail',
        'illustrationKey': 'science/earth-science-astronomy/heavenly-bodies#1',
        'orbitShape': 'oval',
        'cometPositions': 2,
        'tailDirection': 'away from Sun',
      },
      'tailDirection',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'seismic-core',
        'illustrationKey':
            'science/earth-science-astronomy/layers-of-the-earth#3',
        'sWaveBehavior': 'stops at liquid outer core',
        'pWaveBehavior': 'bends through liquid outer core',
        'shadowZone': 'S-wave',
      },
      'sWaveBehavior',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'rock-cycle',
        'illustrationKey':
            'science/earth-science-astronomy/minerals-and-rocks#1',
        'stages': [
          'magma',
          'igneous rock',
          'sediment',
          'sedimentary rock',
          'metamorphic rock',
        ],
        'processes': [
          {'from': 'magma', 'to': 'igneous rock', 'label': 'cooling'},
          {
            'from': 'igneous rock',
            'to': 'sediment',
            'label': 'weathering',
          },
          {
            'from': 'sediment',
            'to': 'sedimentary rock',
            'label': 'compacting',
          },
          {
            'from': 'any rock',
            'to': 'metamorphic rock',
            'label': 'heat and pressure',
          },
          {'from': 'any rock', 'to': 'magma', 'label': 'melting'},
        ],
      },
      'processes',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'nebular-sequence',
        'illustrationKey':
            'science/earth-science-astronomy/origin-of-the-universe#1',
        'stages': [
          'large slowly spinning cloud of gas and dust',
          'flattened disk',
          'bright center forming the Sun',
          'small clumps forming planets along the disk',
        ],
      },
      'stages',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'plate-boundary-comparison',
        'illustrationKey': 'science/earth-science-astronomy/plate-tectonics#1',
        'boundaries': [
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
        ],
      },
      'boundaries',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'transform-boundary',
        'illustrationKey': 'science/earth-science-astronomy/plate-tectonics#2',
        'plateMotion': 'opposite horizontal directions',
        'faultLine': true,
        'earthquakeSymbols': true,
      },
      'plateMotion',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'seismograph-arrivals',
        'illustrationKey': 'science/earth-science-astronomy/plate-tectonics#3',
        'firstArrival': 'P wave',
        'secondArrival': 'S wave',
        'timeGapMeaning': 'proportional to distance',
      },
      'timeGapMeaning',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'water-cycle',
        'illustrationKey':
            'science/earth-science-astronomy/water-cycle-oceanography#1',
        'steps': [
          'Sun heats ocean',
          'evaporation',
          'water vapor rises',
          'condensation into clouds',
          'precipitation over mountains',
          'runoff to ocean',
          'groundwater to ocean',
        ],
      },
      'steps',
    ),
    _FigureCase(
      {
        'kind': 'earth-science-diagram',
        'type': 'atmosphere-layers',
        'illustrationKey':
            'science/earth-science-astronomy/weather-and-climate#1',
        'layersGroundUp': [
          'troposphere',
          'stratosphere',
          'mesosphere',
          'thermosphere',
          'exosphere',
        ],
        'ozoneLayerWithin': 'stratosphere',
      },
      'layersGroundUp',
    ),
    _FigureCase(
      {
        'kind': 'physics-energy-diagram',
        'type': 'electric-field-pairs',
        'illustrationKey': 'science/physics/electricity-and-magnetism#1',
        'cases': [
          {
            'charges': ['positive', 'positive'],
            'fieldLines': 'point away from each',
            'force': 'repel',
          },
          {
            'charges': ['positive', 'negative'],
            'fieldLines': 'connect positive to negative',
            'force': 'attract',
          },
        ],
      },
      'cases',
    ),
    _FigureCase(
      {
        'kind': 'physics-energy-diagram',
        'type': 'series-parallel-circuit',
        'illustrationKey': 'science/physics/electricity-and-magnetism#2',
        'bulbsPerCircuit': 2,
        'seriesPath': 'single loop one after another',
        'parallelPath': 'separate side-by-side branches',
        'batteryShown': true,
      },
      'seriesPath',
    ),
    _FigureCase(
      {
        'kind': 'physics-energy-diagram',
        'type': 'ohms-law-circuit',
        'illustrationKey': 'science/physics/electricity-and-magnetism#3',
        'resistanceOhms': 10,
        'currentAmps': 2,
        'voltageLabel': '?',
      },
      'resistanceOhms',
    ),
    _FigureCase(
      {
        'kind': 'physics-energy-diagram',
        'type': 'circuit-failure',
        'illustrationKey': 'science/physics/electricity-and-magnetism#4',
        'seriesOutcome': 'other bulb goes dark',
        'parallelOutcome': 'other bulb stays lit',
        'burnedOutBulbsPerCircuit': 1,
      },
      'seriesOutcome',
    ),
    _FigureCase(
      {
        'kind': 'physics-energy-diagram',
        'type': 'lens-comparison',
        'illustrationKey': 'science/physics/light-and-optics#2',
        'convexBehavior': 'parallel rays bend inward to one focus point',
        'concaveBehavior': 'parallel rays spread outward',
      },
      'convexBehavior',
    ),
    _FigureCase(
      {
        'kind': 'physics-energy-diagram',
        'type': 'heat-transfer-triptych',
        'illustrationKey': 'science/physics/thermodynamics#1',
        'panels': [
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
        ],
      },
      'panels',
    ),
    _FigureCase(
      {
        'kind': 'physics-energy-diagram',
        'type': 'doppler-ambulance',
        'illustrationKey': 'science/physics/waves-and-sound#4',
        'source': 'moving ambulance',
        'ahead': {'wavelength': 'shorter', 'pitch': 'higher'},
        'behind': {'wavelength': 'longer', 'pitch': 'lower'},
      },
      'ahead',
    ),
  ];

  test('Task 3 owns exactly 18 Earth Science and 7 Physics Energy keys', () {
    expect(
      cases.where((entry) => entry.spec['kind'] == 'earth-science-diagram'),
      hasLength(18),
    );
    expect(
      cases.where((entry) => entry.spec['kind'] == 'physics-energy-diagram'),
      hasLength(7),
    );
    final keys = cases
        .map((entry) => entry.spec['illustrationKey'])
        .whereType<String>()
        .toSet();
    expect(keys, hasLength(25));
  });

  test('all 25 frozen specs resolve', () {
    for (final entry in cases) {
      expect(
        _fromSpec(entry.spec),
        isNotNull,
        reason: entry.spec['illustrationKey']! as String,
      );
    }
  });

  test('every private type rejects a missing required field', () {
    for (final entry in cases) {
      final malformed = <String, Object?>{...entry.spec}
        ..remove(entry.requiredField);
      expect(
        _fromSpec(malformed),
        isNull,
        reason: '${entry.spec['illustrationKey']} accepted without '
            '${entry.requiredField}',
      );
    }
  });

  testWidgets('all 25 figures paint a frame in light and dark themes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final palette in const [PantasColors.light, PantasColors.dark]) {
      for (final entry in cases) {
        await _pumpFigure(tester, entry.spec, palette);
        expect(
          tester.takeException(),
          isNull,
          reason: entry.spec['illustrationKey']! as String,
        );
      }
    }
  });

  testWidgets('both transform figures use a horizontal fault', (tester) async {
    final comparison = cases.singleWhere(
      (entry) =>
          entry.spec['illustrationKey'] ==
          'science/earth-science-astronomy/plate-tectonics#1',
    );
    final dedicated = cases.singleWhere(
      (entry) =>
          entry.spec['illustrationKey'] ==
          'science/earth-science-astronomy/plate-tectonics#2',
    );
    final comparisonImage = await _renderFigure(
      tester,
      comparison.spec,
      PantasColors.light,
    );
    final dedicatedImage = await _renderFigure(
      tester,
      dedicated.spec,
      PantasColors.light,
    );

    expect(
      comparisonImage.countNear(
        PantasColors.light.fill,
        const Rect.fromLTWH(276, 124, 102, 5),
      ),
      greaterThan(30),
    );
    expect(
      dedicatedImage.countNear(
        PantasColors.light.fill,
        const Rect.fromLTWH(38, 125, 314, 6),
      ),
      greaterThan(120),
    );
    expect(
      comparisonImage.countNear(
        PantasColors.light.label,
        const Rect.fromLTWH(279, 97, 16, 16),
      ),
      greaterThan(2),
    );
    expect(
      comparisonImage.countNear(
        PantasColors.light.label,
        const Rect.fromLTWH(358, 141, 16, 16),
      ),
      greaterThan(2),
    );
    expect(
      dedicatedImage.countNear(
        PantasColors.light.label,
        const Rect.fromLTWH(83, 79, 16, 16),
      ),
      greaterThan(2),
    );
    expect(
      dedicatedImage.countNear(
        PantasColors.light.label,
        const Rect.fromLTWH(291, 160, 16, 16),
      ),
      greaterThan(2),
    );
  });

  testWidgets('comet orbit puts the Sun at an ellipse focus', (tester) async {
    final item = cases.singleWhere(
      (entry) =>
          entry.spec['illustrationKey'] ==
          'science/earth-science-astronomy/heavenly-bodies#1',
    );
    final image = await _renderFigure(tester, item.spec, PantasColors.light);
    final a = image.width * 0.72 / 2;
    const b = 175 / 2;
    final c = _sqrt(a * a - b * b);
    final focus = Offset(image.width / 2 - c, 132);

    expect(
      image.countNear(
        PantasColors.light.label,
        Rect.fromCircle(center: focus, radius: 25),
      ),
      greaterThan(50),
    );
  });

  testWidgets('Moon phase lighting keeps the corrected geometry', (
    tester,
  ) async {
    final item = cases.singleWhere(
      (entry) =>
          entry.spec['illustrationKey'] ==
          'science/earth-science-astronomy/eclipses-and-moon-phases#1',
    );
    final image = await _renderFigure(tester, item.spec, PantasColors.light);
    final newMoon = image.pixel(195 - 390 * 0.31, 146);
    final fullMoon = image.pixel(195 + 390 * 0.31, 146);

    expect(_luminance(newMoon), lessThan(_luminance(fullMoon)));
  });
}

double _sqrt(double value) {
  var estimate = value;
  for (var i = 0; i < 20; i++) {
    estimate = (estimate + value / estimate) / 2;
  }
  return estimate;
}

int _luminance(Color color) {
  final argb = color.toARGB32();
  final red = argb >> 16 & 0xff;
  final green = argb >> 8 & 0xff;
  final blue = argb & 0xff;
  return red * 299 + green * 587 + blue * 114;
}

Future<void> _pumpFigure(
  WidgetTester tester,
  Map<String, Object?> spec,
  PantasColors palette,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: [palette, PantasType.create()],
      ),
      home: Scaffold(
        body: SizedBox(
          width: 390,
          child: FigureRegistry.build(spec),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<_RenderedFigure> _renderFigure(
  WidgetTester tester,
  Map<String, Object?> spec,
  PantasColors palette,
) async {
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: [palette, PantasType.create()],
      ),
      home: Align(
        alignment: Alignment.topCenter,
        child: RepaintBoundary(
          key: boundaryKey,
          child: ColoredBox(
            color: palette.surface,
            child: SizedBox(
              width: 390,
              child: FigureRegistry.build(spec),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = boundary.toImageSync();
  final byteData = await tester.runAsync(image.toByteData);
  final result = _RenderedFigure(
    width: image.width,
    height: image.height,
    rgba: byteData!.buffer.asUint8List(),
  );
  image.dispose();
  return result;
}

class _RenderedFigure {
  const _RenderedFigure({
    required this.width,
    required this.height,
    required this.rgba,
  });

  final int width;
  final int height;
  final Uint8List rgba;

  Color pixel(double x, double y) {
    final px = x.round().clamp(0, width - 1);
    final py = y.round().clamp(0, height - 1);
    final offset = (py * width + px) * 4;
    return Color.fromARGB(
      rgba[offset + 3],
      rgba[offset],
      rgba[offset + 1],
      rgba[offset + 2],
    );
  }

  int countNear(Color target, Rect area, {int tolerance = 8}) {
    var count = 0;
    final targetArgb = target.toARGB32();
    final targetRed = targetArgb >> 16 & 0xff;
    final targetGreen = targetArgb >> 8 & 0xff;
    final targetBlue = targetArgb & 0xff;
    final left = area.left.floor().clamp(0, width);
    final top = area.top.floor().clamp(0, height);
    final right = area.right.ceil().clamp(0, width);
    final bottom = area.bottom.ceil().clamp(0, height);
    for (var y = top; y < bottom; y++) {
      for (var x = left; x < right; x++) {
        final offset = (y * width + x) * 4;
        if ((rgba[offset] - targetRed).abs() <= tolerance &&
            (rgba[offset + 1] - targetGreen).abs() <= tolerance &&
            (rgba[offset + 2] - targetBlue).abs() <= tolerance) {
          count++;
        }
      }
    }
    return count;
  }
}

Object? _fromSpec(Map<String, Object?> spec) {
  return switch (spec['kind']) {
    EarthScienceDiagramFigure.kind => EarthScienceDiagramFigure.fromSpec(spec),
    PhysicsEnergyDiagramFigure.kind =>
      PhysicsEnergyDiagramFigure.fromSpec(spec),
    _ => null,
  };
}

class _FigureCase {
  const _FigureCase(this.spec, this.requiredField);

  final Map<String, Object?> spec;
  final String requiredField;
}
