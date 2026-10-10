import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/biology_diagram_figure.dart';
import 'package:pantas/core/ui/figures/chemistry_diagram_figure.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/figures/physics_mechanics_diagram_figure.dart';
import 'package:pantas/core/ui/figures/reading_diagram_figure.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  final cases = <_FigureCase>[
    const _FigureCase(
      key: 'reading-comprehension/text-types/short-stories-and-novels#1',
      requiredField: 'stages',
      spec: <String, Object?>{
        'kind': 'reading-diagram',
        'type': 'plot-arc',
        'illustrationKey':
            'reading-comprehension/text-types/short-stories-and-novels#1',
        'shape': 'rise-peak-fall',
        'stages': <String>[
          'introduction',
          'rising action',
          'climax',
          'resolution',
        ],
      },
    ),
    const _FigureCase(
      key: 'reading-comprehension/text-types/speeches#1',
      requiredField: 'appeals',
      spec: <String, Object?>{
        'kind': 'reading-diagram',
        'type': 'rhetorical-appeals',
        'illustrationKey': 'reading-comprehension/text-types/speeches#1',
        'source': 'podium',
        'target': 'audience',
        'appeals': <Object?>[
          <String, Object?>{'label': 'ethos', 'meaning': 'credibility'},
          <String, Object?>{'label': 'pathos', 'meaning': 'emotion'},
          <String, Object?>{'label': 'logos', 'meaning': 'logic'},
        ],
      },
    ),
    const _FigureCase(
      key: 'science/biology/botany#1',
      requiredField: 'vascular',
      spec: <String, Object?>{
        'kind': 'biology-diagram',
        'type': 'stem-tissues',
        'illustrationKey': 'science/biology/botany#1',
        'outer': 'dermal tissue',
        'vascular': <String, Object?>{
          'label': 'vascular tissue',
          'components': <String>['xylem', 'phloem'],
        },
        'ground': 'ground tissue',
      },
    ),
    const _FigureCase(
      key: 'science/biology/cell-biology#1',
      requiredField: 'proteinFlow',
      spec: <String, Object?>{
        'kind': 'biology-diagram',
        'type': 'cell-protein-flow',
        'illustrationKey': 'science/biology/cell-biology#1',
        'labels': <String>[
          'nucleus',
          'mitochondria',
          'ribosomes',
          'rough ER',
          'smooth ER',
          'Golgi apparatus',
        ],
        'proteinFlow': <String>['ribosomes', 'rough ER', 'Golgi apparatus'],
      },
    ),
    const _FigureCase(
      key: 'science/biology/cellular-metabolism#1',
      requiredField: 'photosynthesis',
      spec: <String, Object?>{
        'kind': 'biology-diagram',
        'type': 'photosynthesis-respiration-cycle',
        'illustrationKey': 'science/biology/cellular-metabolism#1',
        'photosynthesis': <String, Object?>{
          'organelle': 'chloroplast',
          'inputs': <String>['carbon dioxide', 'water', 'sunlight'],
          'outputs': <String>['glucose', 'oxygen'],
        },
        'respiration': <String, Object?>{
          'organelle': 'mitochondrion',
          'inputs': <String>['glucose', 'oxygen'],
          'outputs': <String>['carbon dioxide', 'water', 'ATP'],
        },
        'loopsBack': true,
      },
    ),
    const _FigureCase(
      key: 'science/biology/cellular-metabolism#2',
      requiredField: 'organelles',
      spec: <String, Object?>{
        'kind': 'biology-diagram',
        'type': 'organelle-comparison',
        'illustrationKey': 'science/biology/cellular-metabolism#2',
        'organelles': <Object?>[
          <String, Object?>{
            'name': 'chloroplast',
            'shape': 'disc',
            'appearance': 'green',
            'process': 'photosynthesis',
          },
          <String, Object?>{
            'name': 'mitochondrion',
            'shape': 'bean',
            'appearance': 'folded inner membranes/cristae',
            'process': 'cellular respiration',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/biology/cellular-reproduction#1',
      requiredField: 'stages',
      spec: <String, Object?>{
        'kind': 'biology-diagram',
        'type': 'mitosis-stages',
        'illustrationKey': 'science/biology/cellular-reproduction#1',
        'stages': <Object?>[
          <String, Object?>{
            'phase': 'prophase',
            'state': 'condensing chromosomes',
          },
          <String, Object?>{
            'phase': 'metaphase',
            'state': 'chromosomes lined up in the middle',
          },
          <String, Object?>{
            'phase': 'anaphase',
            'state': 'chromosomes pulled to opposite ends',
          },
          <String, Object?>{
            'phase': 'telophase',
            'state': 'two forming nuclei',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/biology/ecology#1',
      requiredField: 'levels',
      spec: <String, Object?>{
        'kind': 'biology-diagram',
        'type': 'energy-pyramid',
        'illustrationKey': 'science/biology/ecology#1',
        'levels': <Object?>[
          <String, Object?>{'label': 'producers', 'energy': '100%'},
          <String, Object?>{'label': 'primary consumers', 'energy': '10%'},
          <String, Object?>{'label': 'secondary consumers', 'energy': '1%'},
          <String, Object?>{'label': 'tertiary consumers', 'energy': '0.1%'},
        ],
      },
    ),
    const _FigureCase(
      key: 'science/biology/evolution#1',
      requiredField: 'selection',
      spec: <String, Object?>{
        'kind': 'biology-diagram',
        'type': 'natural-selection-generations',
        'illustrationKey': 'science/biology/evolution#1',
        'generations': 3,
        'trait': 'beak shape',
        'selection': 'better match to available food becomes more common',
        'lessSuited': 'rarer over time',
      },
    ),
    const _FigureCase(
      key: 'science/biology/human-anatomy-physiology#1',
      requiredField: 'flows',
      spec: <String, Object?>{
        'kind': 'biology-diagram',
        'type': 'heart-circulation',
        'illustrationKey': 'science/biology/human-anatomy-physiology#1',
        'layout': 'atria-above-ventricles',
        'chambers': <String>['atrium', 'atrium', 'ventricle', 'ventricle'],
        'flows': <Object?>[
          <String, Object?>{'label': 'pulmonary', 'destination': 'lungs'},
          <String, Object?>{'label': 'systemic', 'destination': 'body'},
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/acids-bases-ph#1',
      requiredField: 'examples',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'ph-scale',
        'illustrationKey': 'science/chemistry/acids-bases-ph#1',
        'min': 0,
        'max': 14,
        'neutral': 7,
        'regions': <String>['acidic', 'neutral', 'basic'],
        'examples': <Object?>[
          <String, Object?>{'label': 'lemon juice', 'ph': 2},
          <String, Object?>{'label': 'pure water', 'ph': 7},
          <String, Object?>{'label': 'soap', 'ph': 10},
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/atomic-structure#1',
      requiredField: 'nucleus',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'atom-particles',
        'illustrationKey': 'science/chemistry/atomic-structure#1',
        'nucleus': <String>['proton (+)', 'neutron (neutral)'],
        'orbiting': <String>['electron (-)'],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/chemical-bonding#1',
      requiredField: 'bondTypes',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'bond-types',
        'illustrationKey': 'science/chemistry/chemical-bonding#1',
        'bondTypes': <Object?>[
          <String, Object?>{
            'label': 'ionic',
            'participants': <String>['metal', 'nonmetal'],
            'electronAction': 'transfer',
            'result': 'positive and negative ions',
          },
          <String, Object?>{
            'label': 'covalent',
            'participants': <String>['nonmetal', 'nonmetal'],
            'electronAction': 'share a pair of electrons',
          },
          <String, Object?>{
            'label': 'metallic',
            'participants': <String>['metal atoms'],
            'electronAction': 'sea of free-moving electrons',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/gas-laws#1',
      requiredField: 'laws',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'gas-laws-gallery',
        'illustrationKey': 'science/chemistry/gas-laws#1',
        'laws': <Object?>[
          <String, Object?>{
            'label': "Boyle's",
            'scene': 'piston compressed',
          },
          <String, Object?>{
            'label': "Charles's",
            'scene': 'balloon expands when heated',
          },
          <String, Object?>{
            'label': "Gay-Lussac's",
            'scene': 'sealed rigid can, pressure rises when heated',
          },
          <String, Object?>{
            'label': "Avogadro's",
            'scene': 'container grows as more gas particles are added',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/history-of-the-atom#1',
      requiredField: 'models',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'atomic-models',
        'illustrationKey': 'science/chemistry/history-of-the-atom#1',
        'models': <Object?>[
          <String, Object?>{'label': 'Dalton', 'model': 'solid sphere'},
          <String, Object?>{
            'label': 'Thomson',
            'model': 'plum pudding with embedded electrons',
          },
          <String, Object?>{
            'label': 'Rutherford',
            'model': 'electrons orbiting a tiny dense nucleus',
          },
          <String, Object?>{
            'label': 'modern',
            'model': 'electron cloud around a nucleus',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/matter#1',
      requiredField: 'states',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'particle-states',
        'illustrationKey': 'science/chemistry/matter#1',
        'states': <Object?>[
          <String, Object?>{
            'label': 'solid',
            'arrangement': 'tightly packed fixed grid',
          },
          <String, Object?>{
            'label': 'liquid',
            'arrangement': 'close together disordered',
          },
          <String, Object?>{
            'label': 'gas',
            'arrangement': 'spread far apart moving freely',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/periodic-table#1',
      requiredField: 'regions',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'periodic-regions',
        'illustrationKey': 'science/chemistry/periodic-table#1',
        'regions': <Object?>[
          <String, Object?>{'label': 'metals', 'location': 'left and center'},
          <String, Object?>{'label': 'nonmetals', 'location': 'far right'},
          <String, Object?>{
            'label': 'metalloids',
            'location': 'staircase boundary',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/quantum-numbers-electron-configuration#1',
      requiredField: 'orbitals',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'orbital-shapes',
        'illustrationKey':
            'science/chemistry/quantum-numbers-electron-configuration#1',
        'orbitals': <Object?>[
          <String, Object?>{'label': 's', 'shape': 'sphere', 'capacity': 2},
          <String, Object?>{'label': 'p', 'shape': 'dumbbell', 'capacity': 6},
          <String, Object?>{
            'label': 'd',
            'shape': 'four-lobed cloverleaf',
            'capacity': 10,
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/solutions#1',
      requiredField: 'measures',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'solution-concentration',
        'illustrationKey': 'science/chemistry/solutions#1',
        'solute': 'sugar',
        'solvent': 'water',
        'measures': <String>[
          'molarity',
          'molality',
          'percent by mass',
          'percent by volume',
        ],
      },
    ),
    const _FigureCase(
      key: 'science/chemistry/thermodynamics-and-kinetics#1',
      requiredField: 'profiles',
      spec: <String, Object?>{
        'kind': 'chemistry-diagram',
        'type': 'reaction-energy',
        'illustrationKey': 'science/chemistry/thermodynamics-and-kinetics#1',
        'profiles': <Object?>[
          <String, Object?>{
            'label': 'exothermic',
            'reactants': 'high',
            'products': 'lower',
            'energy': 'released',
          },
          <String, Object?>{
            'label': 'endothermic',
            'reactants': 'low',
            'products': 'higher',
            'energy': 'absorbed',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/physics/dynamics#1',
      requiredField: 'laws',
      spec: <String, Object?>{
        'kind': 'physics-mechanics-diagram',
        'type': 'newton-laws',
        'illustrationKey': 'science/physics/dynamics#1',
        'laws': <Object?>[
          <String, Object?>{
            'label': 'first law',
            'scene': 'book motionless on table',
            'relationship': 'balanced forces',
          },
          <String, Object?>{
            'label': 'second law',
            'scene': 'hand pushing cart',
            'relationship': 'force arrow and acceleration arrow',
          },
          <String, Object?>{
            'label': 'third law',
            'scene': 'swimmer pushes water backward',
            'relationship': 'water pushes swimmer forward equally',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/physics/fluid-mechanics#1',
      requiredField: 'cases',
      spec: <String, Object?>{
        'kind': 'physics-mechanics-diagram',
        'type': 'buoyancy-comparison',
        'illustrationKey': 'science/physics/fluid-mechanics#1',
        'cases': <Object?>[
          <String, Object?>{
            'state': 'floating',
            'density': 'less dense than water',
            'buoyantForce': 'equal to weight',
          },
          <String, Object?>{
            'state': 'sinking',
            'density': 'denser than water',
            'buoyantForce': 'smaller than weight',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/physics/gravity-and-keplers-laws#2',
      requiredField: 'near',
      spec: <String, Object?>{
        'kind': 'physics-mechanics-diagram',
        'type': 'kepler-equal-areas',
        'illustrationKey': 'science/physics/gravity-and-keplers-laws#2',
        'orbit': 'ellipse',
        'sunPosition': 'one focus',
        'interval': 'equal time',
        'near': <String, Object?>{'arc': 'longer', 'speed': 'faster'},
        'far': <String, Object?>{'arc': 'shorter', 'speed': 'slower'},
        'areas': 'equal',
      },
    ),
    const _FigureCase(
      key: 'science/physics/gravity-and-keplers-laws#3',
      requiredField: 'perihelion',
      spec: <String, Object?>{
        'kind': 'physics-mechanics-diagram',
        'type': 'orbital-speed',
        'illustrationKey': 'science/physics/gravity-and-keplers-laws#3',
        'orbit': 'ellipse',
        'sunPosition': 'one focus',
        'perihelion': <String, Object?>{
          'distance': 'near',
          'velocityArrow': 'long',
          'speed': 'fast',
        },
        'aphelion': <String, Object?>{
          'distance': 'far',
          'velocityArrow': 'short',
          'speed': 'slow',
        },
      },
    ),
    const _FigureCase(
      key: 'science/physics/kinematics#1',
      requiredField: 'velocityTrend',
      spec: <String, Object?>{
        'kind': 'physics-mechanics-diagram',
        'type': 'accelerated-motion',
        'illustrationKey': 'science/physics/kinematics#1',
        'path': 'straight road',
        'moments': 3,
        'velocityTrend': 'increasing',
        'acceleration': 'constant',
      },
    ),
    const _FigureCase(
      key: 'science/physics/momentum-and-impulse#1',
      requiredField: 'cases',
      spec: <String, Object?>{
        'kind': 'physics-mechanics-diagram',
        'type': 'impulse-duration',
        'illustrationKey': 'science/physics/momentum-and-impulse#1',
        'impulse': 'same',
        'cases': <Object?>[
          <String, Object?>{
            'surface': 'hard surface',
            'force': 'large',
            'time': 'very short',
          },
          <String, Object?>{
            'surface': 'airbag',
            'force': 'smaller',
            'time': 'longer',
          },
        ],
      },
    ),
    const _FigureCase(
      key: 'science/physics/work-energy-power#1',
      requiredField: 'points',
      spec: <String, Object?>{
        'kind': 'physics-mechanics-diagram',
        'type': 'mechanical-energy',
        'illustrationKey': 'science/physics/work-energy-power#1',
        'system': 'pendulum',
        'points': <Object?>[
          <String, Object?>{
            'position': 'high',
            'potential': 'all',
            'kinetic': 'zero',
          },
          <String, Object?>{
            'position': 'midpoint',
            'potential': 'some',
            'kinetic': 'some',
          },
          <String, Object?>{
            'position': 'low',
            'potential': 'zero',
            'kinetic': 'all',
          },
        ],
        'totalEnergy': 'constant',
      },
    ),
  ];

  test('all 27 original-code-a specs parse and required fields are enforced',
      () {
    expect(cases, hasLength(27));
    expect(cases.map((item) => item.key).toSet(), hasLength(27));

    for (final item in cases) {
      expect(_parse(item.spec), isNotNull, reason: item.key);

      final malformed = Map<String, Object?>.from(item.spec)
        ..remove(item.requiredField);
      expect(_parse(malformed), isNull, reason: '${item.key} malformed');
    }
  });

  test('Kepler equal-area spec locks the corrected arc relationship', () {
    final item = cases.singleWhere(
      (item) => item.key == 'science/physics/gravity-and-keplers-laws#2',
    );
    final near = item.spec['near']! as Map<String, Object?>;
    final far = item.spec['far']! as Map<String, Object?>;

    expect(item.spec['orbit'], 'ellipse');
    expect(item.spec['sunPosition'], 'one focus');
    expect(item.spec['interval'], 'equal time');
    expect(item.spec['areas'], 'equal');
    expect(near['arc'], 'longer');
    expect(near['speed'], 'faster');
    expect(far['arc'], 'shorter');
    expect(far['speed'], 'slower');
    expect(PhysicsMechanicsDiagramFigure.fromSpec(item.spec), isNotNull);
  });

  testWidgets('all 27 figures paint a frame in light and dark themes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final palette in const [AppColors.light, AppColors.dark]) {
      for (final item in cases) {
        await _pumpFigure(tester, item.spec, palette);
        expect(tester.takeException(), isNull, reason: item.key);
      }
    }
  });

  testWidgets('pH scale paints a continuous transition', (tester) async {
    final item = cases.singleWhere(
      (item) => item.key == 'science/chemistry/acids-bases-ph#1',
    );
    final image = await _renderFigure(tester, item.spec, AppColors.light);
    const left = 18.0;
    final step = (image.width - 36) / 14;
    final samples = <int>{};
    for (var i = 0; i < 14; i++) {
      samples.add(
        image.pixel(left + (i + 0.5) * step, 91).toARGB32(),
      );
    }

    expect(samples.length, greaterThanOrEqualTo(12));
  });

  testWidgets('periodic table paints three distinct regions', (tester) async {
    final item = cases.singleWhere(
      (item) => item.key == 'science/chemistry/periodic-table#1',
    );
    final image = await _renderFigure(tester, item.spec, AppColors.light);
    final cellWidth = (image.width - 44) / 18;
    final colors = <int>{
      image.pixel(22 + cellWidth * 5.5, 24 + 20 * 4.5).toARGB32(),
      image.pixel(22 + cellWidth * 13.5, 24 + 20 * 3.5).toARGB32(),
      image.pixel(22 + cellWidth * 16.5, 24 + 20 * 3.5).toARGB32(),
    };

    expect(colors, hasLength(3));
    expect(colors, isNot(contains(AppColors.light.surface.toARGB32())));
  });

  testWidgets('second-law panel includes a line-drawn pushing hand', (
    tester,
  ) async {
    final item = cases.singleWhere(
      (item) => item.key == 'science/physics/dynamics#1',
    );
    final image = await _renderFigure(tester, item.spec, AppColors.light);

    expect(
      image.countNear(
            AppColors.light.ink,
            const Rect.fromLTRB(145, 93, 174, 109),
          ) +
          image.countNear(
            AppColors.light.ink,
            const Rect.fromLTRB(145, 116, 174, 132),
          ),
      greaterThan(10),
    );
    expect(
      image.countNear(
        AppColors.light.ink,
        const Rect.fromLTRB(145, 93, 174, 109),
      ),
      greaterThan(0),
    );
  });

  testWidgets('constant-acceleration indicator is visibly curved', (
    tester,
  ) async {
    final item = cases.singleWhere(
      (item) => item.key == 'science/physics/kinematics#1',
    );
    final image = await _renderFigure(tester, item.spec, AppColors.light);
    final occupiedRows = <int>{};
    for (var y = 24; y <= 56; y++) {
      if (image.countNear(
            AppColors.light.board,
            Rect.fromLTRB(80, y.toDouble(), 310, y + 1.0),
          ) >
          0) {
        occupiedRows.add(y);
      }
    }

    expect(occupiedRows.length, greaterThan(12));
  });

  testWidgets('first-item labels do not use decorative board green', (
    tester,
  ) async {
    final speech = cases.singleWhere(
      (item) => item.key == 'reading-comprehension/text-types/speeches#1',
    );
    final bonding = cases.singleWhere(
      (item) => item.key == 'science/chemistry/chemical-bonding#1',
    );
    final speechImage = await _renderFigure(
      tester,
      speech.spec,
      AppColors.light,
    );
    final bondingImage = await _renderFigure(
      tester,
      bonding.spec,
      AppColors.light,
    );

    expect(
      speechImage.countNear(
        AppColors.light.board,
        Rect.fromLTWH(0, 0, speechImage.width.toDouble(), 210),
      ),
      0,
    );
    expect(
      bondingImage.countNear(
        AppColors.light.board,
        const Rect.fromLTWH(0, 0, 130, 38),
      ),
      0,
    );
  });

  testWidgets('Kepler Sun remains at the ellipse focus', (tester) async {
    final item = cases.singleWhere(
      (item) => item.key == 'science/physics/gravity-and-keplers-laws#2',
    );
    final image = await _renderFigure(tester, item.spec, AppColors.light);
    final orbitWidth = image.width * 0.72;
    final orbitHeight = _mathMin(230 * 0.54, orbitWidth * 0.62);
    final a = orbitWidth / 2;
    final b = orbitHeight / 2;
    final c = _mathSqrt(a * a - b * b);
    final focus = Offset(image.width * 0.5 - c, 230 * 0.47);

    expect(
      image.countNear(
        AppColors.light.board,
        Rect.fromCircle(center: focus, radius: 8),
      ),
      greaterThan(70),
    );
  });
}

double _mathMin(double a, double b) => a < b ? a : b;

double _mathSqrt(double value) {
  var estimate = value;
  for (var i = 0; i < 20; i++) {
    estimate = (estimate + value / estimate) / 2;
  }
  return estimate;
}

Future<void> _pumpFigure(
  WidgetTester tester,
  Map<String, Object?> spec,
  AppColors palette,
) async {
  await tester.pumpWidget(
    MaterialApp(
      themeAnimationDuration: Duration.zero,
      theme: ThemeData(
        extensions: [palette, AppTextStyles.create()],
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
  AppColors palette,
) async {
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      themeAnimationDuration: Duration.zero,
      theme: ThemeData(
        extensions: [palette, AppTextStyles.create()],
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

Object? _parse(Map<String, Object?> spec) {
  return switch (spec['kind']) {
    ReadingDiagramFigure.kind => ReadingDiagramFigure.fromSpec(spec),
    BiologyDiagramFigure.kind => BiologyDiagramFigure.fromSpec(spec),
    ChemistryDiagramFigure.kind => ChemistryDiagramFigure.fromSpec(spec),
    PhysicsMechanicsDiagramFigure.kind =>
      PhysicsMechanicsDiagramFigure.fromSpec(spec),
    _ => null,
  };
}

class _FigureCase {
  const _FigureCase({
    required this.key,
    required this.requiredField,
    required this.spec,
  });

  final String key;
  final String requiredField;
  final Map<String, Object?> spec;
}
