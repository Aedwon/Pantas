import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../goldens/golden_harness.dart';

/// Offscreen figure sheets for checking generated abstract reasoning figures
/// by eye: one sheet per figure kind and theme, 12 samples each.
///
/// Regenerate (the PNGs land in docs/superpowers/verification):
///   flutter test --tags golden --run-skipped --update-goldens \
///     test/tool/generator/figure_sheets_test.dart
const _typesDir = 'content/types/reasoning/spatial-abstract-reasoning';
const _kinds = ['figure-series', 'shape-row', 'figure-matrix'];
const _seed = 20261117;
const _samples = 12;
const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

class _Sample {
  _Sample(this.typeId, this.variant);
  final String typeId;
  final Map<String, Object?> variant;
}

/// Every variant of every type directory, grouped by the stem figure kind.
Map<String, Map<String, List<Map<String, Object?>>>> _load() {
  final out = <String, Map<String, List<Map<String, Object?>>>>{};
  final files = Directory(_typesDir)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.variants.yaml'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final id = file.uri.pathSegments.last.replaceAll('.variants.yaml', '');
    final variants = <Map<String, Object?>>[];
    for (final line in file.readAsLinesSync()) {
      if (!line.startsWith('  - ')) continue;
      variants.add(
        (jsonDecode(line.substring(4)) as Map).cast<String, Object?>(),
      );
    }
    final kind = (variants.first['figureSpec'] as Map)['kind'] as String;
    (out[kind] ??= {})[id] = variants;
  }
  return out;
}

/// Index 0 of each type, then seeded picks spread across the types.
List<_Sample> _pick(Map<String, List<Map<String, Object?>>> types) {
  final rng = Random(_seed);
  final ids = types.keys.toList();
  final picked = <_Sample>[
    for (final id in ids) _Sample(id, types[id]!.first),
  ];
  final used = {for (final id in ids) id: <int>{0}};
  var round = 0;
  while (picked.length < _samples) {
    final id = ids[round % ids.length];
    round++;
    final list = types[id]!;
    if (used[id]!.length >= list.length) continue;
    int i;
    do {
      i = rng.nextInt(list.length);
    } while (!used[id]!.add(i));
    picked.add(_Sample(id, list[i]));
  }
  return picked.take(_samples).toList();
}

String _shortId(String id) =>
    id.replaceFirst('qt-spatial-abstract-reasoning-', '');

/// Draws one series item with the real painter. The series spec needs two
/// items at least, so a single choice figure cannot go through the registry.
class _ItemPainter extends CustomPainter {
  _ItemPainter(this.item, this.palette);
  final SeriesItem item;
  final SeriesPalette palette;

  @override
  void paint(Canvas canvas, Size size) => FigureSeriesFigure.paintItem(
        canvas,
        item,
        size.center(Offset.zero),
        36,
        palette,
      );

  @override
  bool shouldRepaint(_ItemPainter old) => true;
}

/// The stem: a full spec through the registry.
Widget _stem(Map<String, Object?> spec) =>
    FigureRegistry.build(spec) ?? const Text('NO FIGURE');

/// A choice figure: a single item map.
Widget _choice(BuildContext context, String kind, Map<String, Object?> item) {
  if (kind == 'shape-row') {
    // A shape row needs two shapes; draw two and show the first.
    final row = FigureRegistry.build({
      'kind': 'shape-row',
      'shapes': <Object?>[item, item],
    });
    if (row == null) return const Text('NO FIGURE');
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 0.5,
        child: SizedBox(width: 280, child: row),
      ),
    );
  }
  final parsed = FigureSeriesFigure.parseItem(item);
  if (parsed == null) return const Text('NO FIGURE');
  return SizedBox(
    width: 92,
    height: 92,
    child: CustomPaint(
      painter: _ItemPainter(parsed, SeriesPalette.of(context, [parsed])),
    ),
  );
}

Widget _sample(BuildContext context, String kind, _Sample s) {
  final ink = Theme.of(context).colorScheme.onSurface;
  TextStyle style(double size, {FontWeight w = FontWeight.w400, double a = 1}) =>
      TextStyle(
        fontFamily: 'Geist',
        fontSize: size,
        fontWeight: w,
        color: ink.withValues(alpha: a),
      );
  final choices = (s.variant['choices'] as List).cast<Map>();
  return SizedBox(
    width: 640,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_shortId(s.typeId)}  #${s.variant['index']}',
          style: style(12, w: FontWeight.w600, a: 0.7),
        ),
        const SizedBox(height: 4),
        _stem((s.variant['figureSpec'] as Map).cast<String, Object?>()),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < choices.length; i++)
              SizedBox(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_letters[i]}${choices[i]['correct'] == true ? '  key' : ''}',
                        style: style(12, w: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      if (choices[i]['figure'] != null)
                        SizedBox(
                          height: 100,
                          child: FittedBox(
                            alignment: Alignment.topLeft,
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: 140,
                              child: _choice(
                                context,
                                kind,
                                (choices[i]['figure'] as Map)
                                    .cast<String, Object?>(),
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '${choices[i]['text']}',
                            style: style(14, w: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text('${choices[i]['text']}', style: style(10, a: 0.6)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

void main() {
  final byKind = _load();
  for (final kind in _kinds) {
    for (final dark in [false, true]) {
      final name = '$kind-${dark ? 'dark' : 'light'}';
      testWidgets(
        '$name figure sheet',
        (tester) async {
          await loadGoldenFonts();
          goldenFileComparator = TolerantGoldenComparator(
            Uri.parse(
              '${(goldenFileComparator as LocalFileComparator).basedir}x',
            ),
          );
          tester.view
            ..physicalSize = const Size(2000, 4000)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final samples = _pick(byKind[kind]!);
          final key = GlobalKey();
          await tester.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? buildDarkTheme() : buildLightTheme(),
              home: Material(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: RepaintBoundary(
                    key: key,
                    child: Builder(
                      builder: (context) => ColoredBox(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Wrap(
                            spacing: 32,
                            runSpacing: 24,
                            children: [
                              for (final s in samples) _sample(context, kind, s),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 600));
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byKey(key),
            matchesGoldenFile(
              '../../../docs/superpowers/verification/'
              'question-generator-sheets/$name.png',
            ),
          );
        },
        tags: goldenTag,
      );
    }
  }
}
