// A geometry type may sit in the figure column only if its labels fit a 260 px
// plate without wrapping, clipping or sitting on one another. Every spec of
// every shipped lesson is drawn that way.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/figure_highlight.dart';
import 'package:pantas/core/ui/figures/figure_classes.dart';
import 'package:pantas/core/ui/figures/geometry_diagram_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../goldens/golden_harness.dart';

final _marker = RegExp(r'<!--\s*FIGURE:\s*(\{.*?\})\s*-->', dotAll: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGoldenFonts);

  final specs = <String, List<Map<String, Object?>>>{};
  for (final file in Directory('content/lessons')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))) {
    for (final m in _marker.allMatches(file.readAsStringSync())) {
      final spec = jsonDecode(m.group(1)!) as Map<String, Object?>;
      if (spec['kind'] != 'geometry-diagram') continue;
      specs
          .putIfAbsent(figureClassKey(spec['kind'], spec['type']), () => [])
          .add(spec);
    }
  }

  for (final entry in specs.entries) {
    testWidgets('${entry.key}: labels fit a 260 px plate or the type is wide',
        (tester) async {
      final problems = <String>{};
      for (final spec in entry.value) {
        final figure = GeometryDiagramFigure.fromSpec(spec)!;
        await tester.pumpWidget(
          MaterialApp(
            theme: buildLightTheme(web: true),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 260,
                  child: FigureHighlightFor(figure: 0, child: figure),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        problems.addAll(
          tester
              .state<GeometryDiagramFigureState>(
                find.byType(GeometryDiagramFigure),
              )
              .labelProblems,
        );
      }
      if (wideFigureTypes.contains(entry.key)) return;
      expect(
        problems,
        isEmpty,
        reason: '${entry.key} needs $problems at 260 px: move it to the wide '
            'list in figure_classes.dart',
      );
    });
  }
}
