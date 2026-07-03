import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/today_topic_picker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Task 6 of `2026-08-03-passage-pipeline.md`.
///
/// Section 8 of the spec claims the passage work changes nothing for content
/// that has no passages. That claim is worth a test rather than a sentence:
/// every question in the corpus except reading comprehension is free-standing,
/// so a regression here would be felt everywhere at once.
///
/// **Scope, stated because it is smaller than the plan's:** the plan also asks
/// this to cover the viewer and the review. Neither exists yet, and the plan
/// that builds them has not run, so this covers session building and mock
/// sampling only. The remaining two belong with Task 5.
void main() {
  Question freeStanding(String id, {String topicId = 't1'}) {
    return Question(
      id: id,
      version: 1,
      examIds: const ['upcat'],
      topicId: topicId,
      language: 'en',
      stem: 'Stem $id',
      choices: [
        Choice(id: '$id-a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: '$id-b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'Because.',
    );
  }

  group('a session of questions with no passages', () {
    test('fills to the requested length', () {
      final questions = [for (var i = 0; i < 20; i++) freeStanding('q$i')];

      final picked = TodayTopicPicker().pick(
        PickContext(allQuestions: questions, requestedLength: 10),
      );

      expect(picked, hasLength(10));
    });

    test('never repeats a question', () {
      final questions = [for (var i = 0; i < 20; i++) freeStanding('q$i')];

      final picked = TodayTopicPicker().pick(
        PickContext(
          allQuestions: questions,
          dueQuestions: questions.take(8).toList(),
          weaknessQuestions: questions.skip(4).take(8).toList(),
          newQuestions: questions.skip(12).toList(),
          requestedLength: 10,
        ),
      );

      expect(picked.map((q) => q.id).toSet(), hasLength(picked.length));
    });

    test('keeps the due, weakness and new proportions', () {
      final due = [for (var i = 0; i < 10; i++) freeStanding('due$i')];
      final weakness = [for (var i = 0; i < 10; i++) freeStanding('weak$i')];
      final fresh = [for (var i = 0; i < 10; i++) freeStanding('new$i')];

      final picked = TodayTopicPicker().pick(
        PickContext(
          allQuestions: [...due, ...weakness, ...fresh],
          dueQuestions: due,
          weaknessQuestions: weakness,
          newQuestions: fresh,
          requestedLength: 10,
        ),
      );

      expect(picked.where((q) => q.id.startsWith('due')), hasLength(6));
      expect(picked.where((q) => q.id.startsWith('weak')), hasLength(3));
      expect(picked.where((q) => q.id.startsWith('new')), hasLength(1));
    });

    test('honors the topic filter', () {
      final questions = [
        for (var i = 0; i < 10; i++) freeStanding('t1q$i'),
        for (var i = 0; i < 10; i++) freeStanding('t2q$i', topicId: 't2'),
      ];

      final picked = TodayTopicPicker().pick(
        PickContext(
          allQuestions: questions,
          requestedLength: 5,
          topicId: 't2',
        ),
      );

      expect(picked, hasLength(5));
      expect(picked.every((q) => q.topicId == 't2'), isTrue);
    });

    test('returns fewer than requested when the pool is smaller', () {
      final questions = [for (var i = 0; i < 3; i++) freeStanding('q$i')];

      final picked = TodayTopicPicker().pick(
        PickContext(allQuestions: questions, requestedLength: 10),
      );

      expect(picked, hasLength(3));
    });

    test('returns nothing for a request of zero', () {
      final questions = [for (var i = 0; i < 5; i++) freeStanding('q$i')];

      final picked = TodayTopicPicker().pick(
        PickContext(allQuestions: questions, requestedLength: 0),
      );

      expect(picked, isEmpty);
    });
  });

  group('a mock sampled from pools with no passages', () {
    const section = BlueprintSection(
      id: 's1',
      name: 'Section 1',
      questionCount: 5,
      suggestedMinutes: 10,
      topicIds: ['a', 'b'],
      topicWeights: {'a': 2, 'b': 1},
    );
    const pools = {
      'a': ['a1', 'a2', 'a3', 'a4'],
      'b': ['b1', 'b2', 'b3'],
    };

    test('allocates by weight exactly as before', () {
      final sample = MockSampler().sample(
        sections: const [section],
        poolsByTopic: pools,
        recentlySampledQuestionIds: const {},
        seed: 1,
      );

      final sampled = sample.sections.single;
      final fromA = sampled.questionIds.where((id) => id.startsWith('a'));
      final fromB = sampled.questionIds.where((id) => id.startsWith('b'));
      expect(fromA, hasLength(3));
      expect(fromB, hasLength(2));
    });

    test('an empty passage map behaves like no passage map at all', () {
      final without = MockSampler().sample(
        sections: const [section],
        poolsByTopic: pools,
        recentlySampledQuestionIds: const {},
        seed: 7,
      );
      final withEmpty = MockSampler().sample(
        sections: const [section],
        poolsByTopic: pools,
        recentlySampledQuestionIds: const {},
        seed: 7,
        passageSetsByTopic: const {},
      );

      expect(
        withEmpty.sections.single.questionIds,
        equals(without.sections.single.questionIds),
      );
    });

    test('the same seed still gives the same paper', () {
      final first = MockSampler().sample(
        sections: const [section],
        poolsByTopic: pools,
        recentlySampledQuestionIds: const {},
        seed: 42,
      );
      final second = MockSampler().sample(
        sections: const [section],
        poolsByTopic: pools,
        recentlySampledQuestionIds: const {},
        seed: 42,
      );

      expect(
        first.sections.single.questionIds,
        equals(second.sections.single.questionIds),
      );
    });
  });
}
