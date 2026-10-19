// JSON mapping for the mock paper sampler. Pure Dart, no dart:js_interop, so
// the Dart VM reference run and the compiled JS use the same code.
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/data/mock_sampler.dart';

/// Input: {sectionsJson: string, poolsByTopic, passageSetsByTopic,
/// recentlySampledQuestionIds, seed}. `sectionsJson` is the blueprint's own JSON string.
/// Seed is an integer below 2^32 so that the Dart
/// VM and JavaScript agree on the number.
Map<String, Object?> sampleMockFromJson(Map<String, Object?> j) {
  final sections = BlueprintSection.parseList(j['sectionsJson']! as String);
  final sample = MockSampler().sample(
    sections: sections,
    poolsByTopic: {
      for (final e in (j['poolsByTopic']! as Map<String, Object?>).entries)
        e.key: [for (final q in e.value! as List<Object?>) q! as String],
    },
    recentlySampledQuestionIds: {
      for (final q in j['recentlySampledQuestionIds']! as List<Object?>)
        q! as String,
    },
    seed: (j['seed']! as num).toInt(),
    passageSetsByTopic: j['passageSetsByTopic'] == null
        ? null
        : {
            for (final t
                in (j['passageSetsByTopic']! as Map<String, Object?>).entries)
              t.key: {
                for (final p in (t.value! as Map<String, Object?>).entries)
                  p.key: [for (final q in p.value! as List<Object?>) q! as String],
              },
          },
  );
  return {
    'expectedQuestionCount': sample.expectedQuestionCount,
    'sections': [
      for (final s in sample.sections)
        {'sectionId': s.sectionId, 'name': s.name, 'questionIds': s.questionIds},
    ],
  };
}
