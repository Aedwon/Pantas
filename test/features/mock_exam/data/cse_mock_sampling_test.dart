import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/data/mock_sampler.dart';
import 'package:yaml/yaml.dart';

void main() {
  for (final exam in ['cse-pro', 'cse-sub']) {
    test('$exam fills each section from its tagged topics', () {
      final blueprint = loadYaml(
        File('content/mock/$exam.yaml').readAsStringSync(),
      ) as YamlMap;
      final sections = BlueprintSection.parseList(
        jsonEncode(blueprint['sections']),
      );
      final pools = <String, List<String>>{};
      final passages = <String, Map<String, List<String>>>{};
      final topicOf = <String, String>{};
      for (final file in Directory('content/questions')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.yaml'))) {
        final doc = loadYaml(file.readAsStringSync()) as YamlMap;
        final meta = doc['meta'] as YamlMap;
        if (!(meta['exams'] as YamlList).contains(exam)) continue;
        final slug = (meta['topic'] as String).replaceAll('-', '_');
        final topic = 'topic_upcat_$slug';
        for (final question in (doc['questions'] as YamlList).cast<YamlMap>()) {
          if (question['isActive'] == false) continue;
          final figure = question['figure'];
          if (figure != null &&
              figure.toString().trim().isNotEmpty &&
              question['figureSpec'] == null) {
            continue;
          }
          final id = question['id'] as String;
          pools.putIfAbsent(topic, () => []).add(id);
          topicOf[id] = topic;
          final passage = question['passage'] as String?;
          if (passage != null) {
            passages
                .putIfAbsent(topic, () => {})
                .putIfAbsent(passage, () => [])
                .add(id);
          }
        }
      }

      final expected = exam == 'cse-pro' ? [20, 55, 35, 45] : [36, 36, 36, 37];
      for (final seed in [1, 42, 2027]) {
        final sample = MockSampler().sample(
          sections: sections,
          poolsByTopic: pools,
          passageSetsByTopic: passages,
          recentlySampledQuestionIds: const {},
          seed: seed,
        );
        expect(sample.sections.map((s) => s.questionIds.length), expected);
        expect(sample.partiallyFulfilled, isFalse);
        final seen = <String>{};
        for (var i = 0; i < sections.length; i++) {
          final allowed = sections[i].topicIds.map(
                (id) => id.replaceFirst(
                  'topic_${exam.replaceAll('-', '_')}_',
                  'topic_upcat_',
                ),
              );
          for (final id in sample.sections[i].questionIds) {
            expect(allowed, contains(topicOf[id]));
            expect(seen.add(id), isTrue, reason: '$id repeats');
          }
        }
      }
    });
  }
}
