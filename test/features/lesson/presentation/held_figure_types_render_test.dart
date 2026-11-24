// One sheet per figure painter: every figure type of the shipped lessons, drawn
// as in a 300 px plate (260 px inner width), the narrowest the figure column
// gets. A type whose labels clip or overlap, or whose parts are a row of
// three or more panels, belongs on the wide list.
//
//   flutter test --tags golden --run-skipped \
//     test/features/lesson/presentation/held_figure_types_render_test.dart
@Tags(['golden'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/figure_highlight.dart';
import 'package:pantas/core/ui/figures/figure_classes.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../goldens/golden_harness.dart';

final _marker = RegExp(r'<!--\s*FIGURE:\s*(\{.*?\})\s*-->', dotAll: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await loadGoldenFonts();
    for (final family in [
      'Main-Regular',
      'Main-Italic',
      'Math-Italic',
      'AMS-Regular',
    ]) {
      await (FontLoader(
        'packages/flutter_math_fork/KaTeX_${family.split('-').first}',
      )..addFont(
              rootBundle.load(
                'packages/flutter_math_fork/lib/katex_fonts/fonts/'
                'KaTeX_$family.ttf',
              ),
            ))
          .load();
    }
  });

  // The first spec of every type, by kind.
  final byKind = <String, Map<String, Map<String, Object?>>>{};
  for (final file in Directory('content/lessons')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))) {
    for (final m in _marker.allMatches(file.readAsStringSync())) {
      final spec = jsonDecode(m.group(1)!) as Map<String, Object?>;
      final key = figureClassKey(spec['kind'], spec['type']);
      byKind
          .putIfAbsent('${spec['kind']}', () => {})
          .putIfAbsent(key, () => spec);
    }
  }

  final boundary = GlobalKey();
  for (final entry in byKind.entries) {
    testWidgets('sheet ${entry.key}', (tester) async {
      tester.view
        ..physicalSize = const Size(1360, 2400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final keys = entry.value.keys.toList()..sort();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(web: true),
          home: Scaffold(
            backgroundColor: const Color(0xFFF5F5F7),
            body: RepaintBoundary(
              key: boundary,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (final key in keys)
                        SizedBox(
                          width: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wideFigureTypes.contains(key)
                                    ? '$key [WIDE]'
                                    : key,
                                style: const TextStyle(fontSize: 11),
                              ),
                              Container(
                                color: const Color(0xFFFAFAF7),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: Theme(
                                  data: buildLightTheme(),
                                  child: FigureHighlightFor(
                                    figure: 0,
                                    child: FigureRegistry.build(
                                          entry.value[key]!,
                                        ) ??
                                        const Text('unbuilt'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final object =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(boundary));
      final image = (await tester.runAsync(object.toImage))!;
      final bytes = (await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      ))!;
      await tester.runAsync(() async {
        final file = File('build/held-sheets/types/${entry.key}.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes.buffer.asUint8List());
      });
    });
  }
}
