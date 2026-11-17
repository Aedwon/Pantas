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
const _kinds = ['figure-series', 'shape-row', 'figure-matrix', 'cube-net'];
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
      variants.add(jsonDecode(line.substring(4))! as Map<String, Object?>);
    }
    final kind = (variants.first['figureSpec']!
        as Map<String, Object?>)['kind']! as String;
    (out[kind] ??= {})[id] = variants;
  }
  return out;
}

/// Every sheet of one kind, picked together so no sample shows twice.
///
/// Each type shows its index 0 first, then seeded picks. Sheet `n` starts
/// `n * 12` types further along (wrapping), so every type appears and a
/// type that returns on a later sheet shows an index not yet used.
List<List<_Sample>> _pickSheets(
  Map<String, List<Map<String, Object?>>> types,
  int sheets,
) {
  final rng = Random(_seed);
  final all = types.keys.toList();
  final order = {
    for (final id in all)
      id: [
        0,
        ...(List<int>.generate(types[id]!.length - 1, (i) => i + 1)
          ..shuffle(rng)),
      ],
  };
  final next = {for (final id in all) id: 0};
  final out = <List<_Sample>>[];
  for (var sheet = 0; sheet < sheets; sheet++) {
    final start = (sheet * _samples) % all.length;
    final ids = [
      for (var i = 0; i < all.length; i++) all[(start + i) % all.length],
    ];
    final picked = <_Sample>[];
    var progress = true;
    while (picked.length < _samples && progress) {
      progress = false;
      for (final id in ids) {
        if (picked.length >= _samples) break;
        if (next[id]! >= order[id]!.length) continue;
        picked.add(_Sample(id, types[id]![order[id]![next[id]!]]));
        next[id] = next[id]! + 1;
        progress = true;
      }
    }
    out.add(picked);
  }
  return out;
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
  void paint(Canvas canvas, Size size) {
    palette.paintPanel(canvas, size);
    FigureSeriesFigure.paintItem(
      canvas,
      item,
      size.center(Offset.zero),
      36,
      palette,
    );
  }

  @override
  bool shouldRepaint(_ItemPainter old) => true;
}

/// The stem: a full spec through the registry.
Widget _stem(Map<String, Object?> spec) =>
    FigureRegistry.build(spec) ?? const Text('NO FIGURE');

/// The items a spec names, for the palette decision.
List<SeriesItem?> _items(Map<String, Object?> spec) {
  final raw = spec['items'] ?? spec['cells'];
  if (raw is! List) return const [];
  return [for (final e in raw) FigureSeriesFigure.parseItem(e)];
}

/// A choice figure: a single item map, drawn on the stem's palette and panel.
Widget _choice(
  BuildContext context,
  String kind,
  Map<String, Object?> item,
  Map<String, Object?> stem,
) {
  if (kind == 'shape-row') {
    // A shape row needs two shapes; draw two and clip to the first slot.
    final row = FigureRegistry.build({
      'kind': 'shape-row',
      'shapes': <Object?>[item, item],
    });
    if (row == null) return const Text('NO FIGURE');
    return ClipRect(
      child: SizedBox(
        width: 140,
        height: 110,
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: 280,
          maxWidth: 280,
          child: SizedBox(width: 280, child: row),
        ),
      ),
    );
  }
  final parsed = FigureSeriesFigure.parseItem(item);
  if (parsed == null) return const Text('NO FIGURE');
  final palette = SeriesPalette.of(context, [..._items(stem), parsed]);
  return SizedBox(
    width: 92,
    height: 92,
    child: CustomPaint(painter: _ItemPainter(parsed, palette)),
  );
}

Widget _sample(BuildContext context, String kind, _Sample s) {
  final ink = Theme.of(context).colorScheme.onSurface;
  TextStyle style(
    double size, {
    FontWeight w = FontWeight.w400,
    double a = 1,
  }) =>
      TextStyle(
        fontFamily: 'Geist',
        fontSize: size,
        fontWeight: w,
        color: ink.withValues(alpha: a),
      );
  final choices =
      (s.variant['choices']! as List<Object?>).cast<Map<String, Object?>>();
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
        _stem(s.variant['figureSpec']! as Map<String, Object?>),
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
                        '${_letters[i]}'
                        '${choices[i]['correct'] == true ? '  key' : ''}',
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
                                choices[i]['figure']! as Map<String, Object?>,
                                s.variant['figureSpec']!
                                    as Map<String, Object?>,
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
    final sheets = (byKind[kind]!.length / _samples).ceil();
    final picks = _pickSheets(byKind[kind]!, sheets);
    for (var sheet = 0; sheet < sheets; sheet++) {
      for (final dark in [false, true]) {
        final name = '$kind-${dark ? 'dark' : 'light'}'
            '${sheet == 0 ? '' : '-${sheet + 1}'}';
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
            final samples = picks[sheet];
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
                                for (final s in samples)
                                  _sample(context, kind, s),
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
}
