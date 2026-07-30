import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

void main() {
  test('allocates questions by topic weights using Hamilton remainders', () {
    final sampler = MockSampler();
    final sample = sampler.sample(
      sections: [
        const BlueprintSection(
          id: 's1',
          name: 'Section 1',
          questionCount: 5,
          suggestedMinutes: 10,
          topicIds: ['a', 'b'],
          topicWeights: {'a': 2, 'b': 1},
        ),
      ],
      poolsByTopic: {
        'a': ['a1', 'a2', 'a3', 'a4'],
        'b': ['b1', 'b2', 'b3'],
      },
      recentlySampledQuestionIds: const {},
      seed: 1,
    );

    final section = sample.sections.single;
    expect(section.questionIds.where((id) => id.startsWith('a')), hasLength(3));
    expect(section.questionIds.where((id) => id.startsWith('b')), hasLength(2));
  });

  test('uses uniform weights when topicWeights is absent', () {
    final sampler = MockSampler();
    const section = BlueprintSection(
      id: 's1',
      name: 'Section 1',
      questionCount: 4,
      suggestedMinutes: 10,
      topicIds: ['a', 'b'],
      topicWeights: {'a': 1, 'b': 1},
    );

    final sample = sampler.sample(
      sections: [section],
      poolsByTopic: {
        'a': ['a1', 'a2'],
        'b': ['b1', 'b2'],
      },
      recentlySampledQuestionIds: const {},
      seed: 2,
    );

    expect(
      sample.sections.single.questionIds.where((id) => id.startsWith('a')),
      hasLength(2),
    );
    expect(
      sample.sections.single.questionIds.where((id) => id.startsWith('b')),
      hasLength(2),
    );
  });

  test('excludes questions from recent mocks when possible', () {
    final sampler = MockSampler();
    final sample = sampler.sample(
      sections: [_singleTopicSection(questionCount: 2)],
      poolsByTopic: {
        'topic': ['old1', 'old2', 'new1', 'new2'],
      },
      recentlySampledQuestionIds: {'old1', 'old2'},
      seed: 3,
    );

    expect(
      sample.sections.single.questionIds,
      unorderedEquals(['new1', 'new2']),
    );
  });

  test('falls back to unfiltered pool when recency filter would underfill', () {
    final sampler = MockSampler();
    final sample = sampler.sample(
      sections: [_singleTopicSection(questionCount: 3)],
      poolsByTopic: {
        'topic': ['old1', 'old2', 'new1'],
      },
      recentlySampledQuestionIds: {'old1', 'old2'},
      seed: 4,
    );

    expect(sample.sections.single.questionIds, hasLength(3));
    expect(sample.partiallyFulfilled, isFalse);
  });

  test('returns partiallyFulfilled when pool is still short', () {
    final sampler = MockSampler();
    final sample = sampler.sample(
      sections: [_singleTopicSection(questionCount: 3)],
      poolsByTopic: {
        'topic': ['q1', 'q2'],
      },
      recentlySampledQuestionIds: const {},
      seed: 5,
    );

    expect(sample.sections.single.questionIds, hasLength(2));
    expect(sample.partiallyFulfilled, isTrue);
    expect(sample.expectedQuestionCount, 3);
    expect(sample.actualQuestionCount, 2);
  });

  test('throws when a section has zero available questions', () {
    final sampler = MockSampler();

    expect(
      () => sampler.sample(
        sections: [_singleTopicSection(questionCount: 3)],
        poolsByTopic: const {'topic': []},
        recentlySampledQuestionIds: const {},
        seed: 6,
      ),
      throwsA(isA<MockSamplingException>()),
    );
  });

  test('same seed produces same sampled order', () {
    final sampler = MockSampler();
    final args = (
      sections: [_singleTopicSection(questionCount: 3)],
      poolsByTopic: {
        'topic': ['q1', 'q2', 'q3', 'q4'],
      },
      recentlySampledQuestionIds: const <String>{},
      seed: 7,
    );

    final first = sampler.sample(
      sections: args.sections,
      poolsByTopic: args.poolsByTopic,
      recentlySampledQuestionIds: args.recentlySampledQuestionIds,
      seed: args.seed,
    );
    final second = sampler.sample(
      sections: args.sections,
      poolsByTopic: args.poolsByTopic,
      recentlySampledQuestionIds: args.recentlySampledQuestionIds,
      seed: args.seed,
    );

    expect(
      first.sections.single.questionIds,
      second.sections.single.questionIds,
    );
  });
}

BlueprintSection _singleTopicSection({required int questionCount}) {
  return BlueprintSection(
    id: 's1',
    name: 'Section 1',
    questionCount: questionCount,
    suggestedMinutes: 10,
    topicIds: const ['topic'],
    topicWeights: const {'topic': 1},
  );
}
