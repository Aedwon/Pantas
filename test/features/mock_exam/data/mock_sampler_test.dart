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

  test('finds an unseen exact fit after a greedy passage draw falls short', () {
    const oversizedDraw = ['a1', 'a2', 'a3', 'a4'];
    const first = ['b1', 'b2', 'b3'];
    const second = ['c1', 'c2', 'c3'];
    const recent = ['d1', 'd2'];

    for (var seed = 0; seed < 20; seed++) {
      final sample = _samplePassages(
        count: 6,
        sets: {'a': oversizedDraw, 'b': first, 'c': second, 'd': recent},
        recentlySampled: recent.toSet(),
        seed: seed,
      );
      expect(
        sample.sections.single.questionIds,
        unorderedEquals([
          ...first,
          ...second,
        ]),
        reason: 'seed $seed',
      );
    }
  });

  test('reuses a whole recent passage only when needed for an exact fit', () {
    const unseen = ['a1', 'a2', 'a3'];
    const recent = ['b1', 'b2'];
    const otherRecent = ['c1', 'c2', 'c3', 'c4'];

    final sample = _samplePassages(
      count: 6,
      sets: {'a': unseen, 'b': recent, 'c': otherRecent},
      standalone: ['solo'],
      recentlySampled: {'b1', 'c1'},
    );

    expect(
      sample.sections.single.questionIds,
      unorderedEquals([
        ...unseen,
        ...recent,
        'solo',
      ]),
    );
  });

  test('retains a partial result of whole sets when no exact fit exists', () {
    const first = ['a1', 'a2'];
    const second = ['b1', 'b2'];
    final sample = _samplePassages(
      count: 3,
      sets: {'a': first, 'b': second},
      recentlySampled: {'a1'},
    );

    expect(sample.sections.single.questionIds, unorderedEquals(second));
    expect(sample.partiallyFulfilled, isTrue);
  });

  test('prefers an exact fit with unseen passages and a recent standalone', () {
    const four = ['b1', 'b2', 'b3', 'b4'];
    const three = ['c1', 'c2', 'c3'];
    const recentPassage = ['d1', 'd2', 'd3', 'd4', 'd5'];
    final sample = _samplePassages(
      count: 8,
      sets: {
        'a': ['a1', 'a2', 'a3', 'a4', 'a5', 'a6'],
        'b': four,
        'c': three,
        'd': recentPassage,
      },
      standalone: ['solo'],
      recentlySampled: {...recentPassage, 'solo'},
    );

    expect(
      sample.sections.single.questionIds,
      unorderedEquals([
        ...four,
        ...three,
        'solo',
      ]),
    );
  });
}

MockSample _samplePassages({
  required int count,
  required Map<String, List<String>> sets,
  required Set<String> recentlySampled,
  List<String> standalone = const [],
  int seed = 0,
}) {
  return MockSampler().sample(
    sections: [_singleTopicSection(questionCount: count)],
    poolsByTopic: {
      'topic': [...sets.values.expand((set) => set), ...standalone],
    },
    recentlySampledQuestionIds: recentlySampled,
    passageSetsByTopic: {'topic': sets},
    seed: seed,
  );
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
