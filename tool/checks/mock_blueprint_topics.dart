// Every topic in a mock blueprint must resolve to questions for that exam.
//
// The blueprint names exam-specific ids and the local pools keep the shared
// ones, so the id is resolved by the real MockSampler rather than a copy of its
// mapping. A topic that resolves to nothing is skipped silently at sampling
// time and the student gets a short paper.
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/data/mock_sampler.dart';

import 'check.dart';
import 'content_snapshot.dart';

/// Findings that are known. Key: `blueprint|topic`.
const _accepted = <String, String>{
  'mock_blueprint_acet|topic_upcat_data_interpretation':
      'OPEN: the bank has no ACET question for this topic yet. CSE is the '
          'launch exam. Reported Nov 5',
  'mock_blueprint_acet|topic_upcat_verbal_logic':
      'OPEN: the bank has no ACET question for this topic yet. CSE is the '
          'launch exam. Reported Nov 5',
};

class MockBlueprintTopicsCheck extends Check {
  const MockBlueprintTopicsCheck();

  @override
  String get name => 'mock-blueprint-topics';

  @override
  String get origin =>
      'Oct to Nov 2026: blueprint topic ids did not match the question pools, '
      'so a mock could not fill';

  @override
  List<Violation> run(String root) =>
      findUnresolvedTopics(ContentSnapshot.load(root));
}

List<Violation> findUnresolvedTopics(ContentSnapshot content) {
  final violations = <Violation>[];
  final sampler = MockSampler();
  for (final blueprint in content.blueprints) {
    final pools = <String, List<String>>{};
    for (final question in content.questions) {
      if (question.examIds.contains(blueprint.examId)) {
        (pools[question.topicId] ??= []).add(question.id);
      }
    }
    for (final section in blueprint.sections) {
      for (final topicId in section.topicIds) {
        try {
          sampler.sample(
            sections: [
              BlueprintSection(
                id: section.id,
                name: section.id,
                questionCount: 1,
                suggestedMinutes: 1,
                topicIds: [topicId],
                topicWeights: const {},
              ),
            ],
            poolsByTopic: pools,
            recentlySampledQuestionIds: const {},
            seed: 1,
          );
        } on MockSamplingException {
          violations.add(
            Violation(
              '${blueprint.id}/${section.id}',
              '$topicId resolves to no question for ${blueprint.examId}',
              acceptedBecause: _accepted['${blueprint.id}|$topicId'],
            ),
          );
        }
      }
    }
  }
  return violations;
}
