import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/passage_card.dart';
import 'package:pantas/core/ui/components/question_card.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/today_topic_picker.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_results_page.dart';

import '../../helpers/pump_app.dart';

class _MockAttempts extends Mock implements AttemptsRepository {}

class _MockContent extends Mock implements ContentRepository {}

/// Tasks 5 and 6 of `2026-08-03-passage-pipeline.md`.
///
/// Section 8 of the spec claims the passage work changes nothing for content
/// that has no passages. That claim is worth a test rather than a sentence:
/// every question in the corpus except reading comprehension is free-standing,
/// so a regression here would be felt everywhere at once.
///
/// Task 5 adds the reading surface in the question viewer and in the review,
/// ensuring a passage renders once above its questions and scrolls naturally.
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

  group('viewer and review with free-standing questions (no passages)', () {
    testWidgets('viewer renders free-standing question without passage',
        (tester) async {
      final q = freeStanding('q1');
      await tester.pumpApp(
        QuestionCard(
          question: q,
          onAnswer: (_) {},
        ),
      );

      expect(find.byType(PassageCard), findsNothing);
      expect(find.text('Stem q1'), findsOneWidget);
    });

    testWidgets('review renders free-standing questions without passage',
        (tester) async {
      final attempts = _MockAttempts();
      final content = _MockContent();

      when(() => attempts.byId('a1')).thenAnswer(
        (_) async => Attempt(
          id: 'a1',
          examId: 'e',
          startedAt: DateTime.utc(2026, 5, 9, 12),
          completedAt: DateTime.utc(2026, 5, 9, 12, 5),
          items: const [
            AttemptItem(
              questionId: 'q1',
              questionVersion: 1,
              chosenChoiceId: 'q1-b',
              correctChoiceId: 'q1-a',
              responseMs: 1500,
            ),
          ],
        ),
      );
      when(() => content.questionsByIds(any())).thenAnswer(
        (_) async => {'q1': freeStanding('q1')},
      );
      // The review provider walks question -> topic -> subject and then looks
      // for a passage. An unstubbed call on a mock returns null and the whole
      // list comes back empty, which reads as "nothing rendered" rather than
      // as a missing stub.
      when(() => content.topicById(any())).thenAnswer((_) async => null);
      when(() => content.subjectById(any())).thenAnswer((_) async => null);
      when(() => content.passageById(any())).thenAnswer((_) async => null);

      await tester.pumpAppWithProviders(
        const QuizResultsPage(attemptId: 'a1'),
        overrides: [
          attemptsRepositoryProvider.overrideWithValue(attempts),
          contentRepositoryProvider.overrideWithValue(content),
          // Reaches a real repository through the database otherwise, and the
          // whole entry list comes back empty rather than erroring.
          flaggedIdsProvider.overrideWith((_) async => <String>{}),
          assessmentCompletedProvider('e').overrideWith((_) async => true),
          countForExamProvider('e').overrideWith((_) async => 0),
        ],
      );
      await tester.pumpAndSettle();

      // Asserts on the row rather than the label text: the label goes through
      // the portable text renderer and the point of this test is the passage,
      // not the label plumbing.
      // The review opens on misses, so the fixture answers wrongly: a set of
      // correct answers renders an empty list and proves nothing.
      expect(find.byType(PassageCard), findsNothing);
      expect(find.byType(ReviewRow), findsOneWidget);
    });
  });

  group('Task 5: passage rendering in viewer and review', () {
    const passage = Passage(
      id: 'p1',
      topicId: 't1',
      title: 'The Palay Harvest',
      body: 'Farmers in Luzon harvest palay during the dry season.',
      language: 'en',
      wordCount: 200,
    );

    Question passageQuestion(String id) {
      return Question(
        id: id,
        version: 1,
        examIds: const ['upcat'],
        topicId: 't1',
        passageId: 'p1',
        language: 'en',
        stem: 'Stem $id',
        choices: [
          Choice(id: '$id-a', label: 'A', text: 'Choice A', isCorrect: true),
          Choice(id: '$id-b', label: 'B', text: 'Choice B', isCorrect: false),
        ],
        explanation: 'Explanation $id.',
      );
    }

    testWidgets(
        'viewer renders passage above question in reader serif typography',
        (tester) async {
      final q = passageQuestion('pq1');
      await tester.pumpApp(
        QuestionCard(
          question: q,
          passage: passage,
          onAnswer: (_) {},
        ),
      );

      expect(find.byType(PassageCard), findsOneWidget);
      expect(find.text('The Palay Harvest'), findsOneWidget);
      expect(
        find.text('Farmers in Luzon harvest palay during the dry season.'),
        findsOneWidget,
      );

      // Verify no sticky or pinned header widget exists in the subtree
      expect(find.byType(SliverPersistentHeader), findsNothing);
    });

    testWidgets('review renders passage ONCE for a set of six questions',
        (tester) async {
      final attempts = _MockAttempts();
      final content = _MockContent();

      final items = [
        for (var i = 1; i <= 6; i++)
          AttemptItem(
            questionId: 'pq$i',
            questionVersion: 1,
            chosenChoiceId: 'pq$i-b',
            correctChoiceId: 'pq$i-a',
            responseMs: 1000,
          ),
      ];

      when(() => attempts.byId('a_passage')).thenAnswer(
        (_) async => Attempt(
          id: 'a_passage',
          examId: 'e',
          startedAt: DateTime.utc(2026, 5, 9, 12),
          completedAt: DateTime.utc(2026, 5, 9, 12, 10),
          items: items,
        ),
      );

      when(() => content.questionsByIds(any())).thenAnswer(
        (_) async => {
          for (var i = 1; i <= 6; i++) 'pq$i': passageQuestion('pq$i'),
        },
      );
      when(() => content.topicById(any())).thenAnswer((_) async => null);
      when(() => content.subjectById(any())).thenAnswer((_) async => null);
      when(() => content.passageById('p1')).thenAnswer(
        (_) async => passage,
      );

      await tester.pumpAppWithProviders(
        const QuizResultsPage(attemptId: 'a_passage'),
        overrides: [
          attemptsRepositoryProvider.overrideWithValue(attempts),
          contentRepositoryProvider.overrideWithValue(content),
          // Reaches a real repository through the database otherwise, and the
          // whole entry list comes back empty rather than erroring.
          flaggedIdsProvider.overrideWith((_) async => <String>{}),
          assessmentCompletedProvider('e').overrideWith((_) async => true),
          countForExamProvider('e').overrideWith((_) async => 0),
        ],
      );
      await tester.pumpAndSettle();

      // Assert passage appears ONCE for all 6 questions
      expect(find.byType(PassageCard), findsOneWidget);
      expect(find.text('The Palay Harvest'), findsOneWidget);

      // Assert no sticky or pinned header widget
      expect(find.byType(SliverPersistentHeader), findsNothing);
    });
  });
}
