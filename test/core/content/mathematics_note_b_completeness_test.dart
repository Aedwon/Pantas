import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('every repaired Mathematics wrong choice has Note B', () {
    const algebraRoot = 'content/questions/mathematics/algebra';
    const dataRoot = 'content/questions/mathematics/data-interpretation';
    const geometryRoot = 'content/questions/mathematics/geometry';
    const calculusRoot =
        'content/questions/mathematics/precalculus-basic-calculus';
    const paths = <String>[
      '$algebraRoot/radicals-and-rationalization.yaml',
      '$algebraRoot/systems-of-equations.yaml',
      '$algebraRoot/word-problems.yaml',
      '$dataRoot/tables-and-charts.yaml',
      '$geometryRoot/basic-geometric-concepts.yaml',
      '$geometryRoot/circles.yaml',
      '$geometryRoot/logic-and-reasoning.yaml',
      '$geometryRoot/measurement.yaml',
      '$geometryRoot/parallel-perpendicular-lines.yaml',
      '$geometryRoot/quadrilaterals-and-polygons.yaml',
      '$geometryRoot/triangles.yaml',
      '$calculusRoot/basic-derivatives.yaml',
      '$calculusRoot/basic-integrals.yaml',
      '$calculusRoot/conic-sections.yaml',
      '$calculusRoot/limits-and-continuity.yaml',
    ];
    final missing = <String>[];

    for (final path in paths) {
      final file = File(path);
      final root = loadYaml(file.readAsStringSync()) as YamlMap;
      final questions = root['questions'] as YamlList;
      for (final questionNode in questions.nodes) {
        final question = questionNode.value as YamlMap;
        final id = question['id'] as String;
        final choices = question['choices'] as YamlList;
        for (final choiceNode in choices.nodes) {
          final choice = choiceNode.value as YamlMap;
          if (choice['correct'] == true) {
            continue;
          }
          final rationale = choice['rationale'];
          if (rationale is! String || rationale.trim().isEmpty) {
            missing.add('$id: ${choice['text']}');
          }
        }
      }
    }

    expect(
      missing,
      isEmpty,
      reason: 'A repaired wrong answer must have Note B. Repair the '
          'distractor if it has no defensible misconception.\n'
          '${missing.join('\n')}',
    );
  });
}
