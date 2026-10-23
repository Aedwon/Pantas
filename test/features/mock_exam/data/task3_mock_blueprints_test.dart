import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  YamlMap load(String name) =>
      loadYaml(File('content/mock/$name.yaml').readAsStringSync()) as YamlMap;

  test('Task 3 authors the three approved built-in mock blueprints', () {
    final pro = load('cse_pro');
    final sub = load('cse_sub');
    final acet = load('acet');

    expect(pro['exam'], 'exam_cse_pro');
    expect(pro['sectionalTiming'], 'roamable');
    expect(pro['totalPublishedItems'], 170);
    expect((pro['sections'] as YamlList).length, 4);

    expect(sub['exam'], 'exam_cse_sub');
    expect(sub['sectionalTiming'], 'roamable');
    expect(sub['totalPublishedItems'], 165);
    expect((sub['sections'] as YamlList).length, 4);

    expect(acet['exam'], 'exam_acet');
    expect(acet['sectionalTiming'], 'sectional');
    expect(acet['totalPublishedItems'], 270);
    expect((acet['sections'] as YamlList).length, 3);
  });

  test('unresolved Task 3 figures carry the approved placeholder marker', () {
    for (final name in ['cse_pro', 'cse_sub']) {
      final sections = load(name)['sections'] as YamlList;
      for (final raw in sections) {
        final section = raw as YamlMap;
        final count = section['questionCount'] as YamlMap;
        expect(count['placeholder'], isTrue);
        expect((count['placeholderNote'] as String).trim(), isNotEmpty);
      }
    }

    final acetSections = load('acet')['sections'] as YamlList;
    final aptitude = acetSections
        .cast<YamlMap>()
        .singleWhere((section) => section['id'] == 'aptitude');
    final minutes = aptitude['sectionalMinutes'] as YamlMap;
    expect(minutes['placeholder'], isTrue);
    expect((minutes['placeholderNote'] as String).trim(), isNotEmpty);
  });
}
