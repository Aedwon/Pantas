// Fake data for the Mock exam screens, lifted from
// test/features/mock_exam/presentation/mock_ds_matrix_test.dart.
import 'package:flutter/widgets.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

HydratedMockQuestion hydratedMockQuestion() => const HydratedMockQuestion(
      Question(
        id: 'q1',
        version: 1,
        examIds: [],
        topicId: 't',
        language: 'en',
        stem: 'Which statement follows from the information given?',
        explanation: 'Explanation.',
        choices: [
          Choice(
            id: 'a',
            label: 'A',
            text: 'The first answer.',
            isCorrect: true,
          ),
          Choice(
            id: 'b',
            label: 'B',
            text: 'The second answer.',
            isCorrect: false,
          ),
          Choice(
            id: 'c',
            label: 'C',
            text: 'The third answer.',
            isCorrect: false,
          ),
          Choice(
            id: 'd',
            label: 'D',
            text: 'The fourth answer.',
            isCorrect: false,
          ),
        ],
      ),
      null,
    );

/// The mock session page on question 5 of 40, one answered, one flagged.
Widget mockSessionPage() => MockSessionPage(
      state: MockSessionInProgress(
        attemptId: 'a',
        durationSeconds: 5400,
        questionIds: [for (var i = 1; i <= 40; i++) 'q$i'],
        currentIndex: 4,
        elapsedSeconds: 0,
        answers: const {'q1': MockAnswer(selectedIndex: 1, atSec: 5)},
        flags: const {'q5'},
        strictMode: false,
      ),
      remainingInPart: const Duration(minutes: 29),
      partLength: const Duration(minutes: 90),
      partPosition: 5,
      partTotal: 40,
      partName: 'Numerical Ability',
      canGoPrevious: true,
      canGoNext: true,
      onPrevious: () {},
      onNext: () {},
      onAnswer: (_) {},
      onToggleFlag: () {},
      onPause: () {},
      onSubmitExam: () {},
      onEndPartEarly: () {},
      upcomingParts: const [
        MockUpcomingPart(number: 2, name: 'Science', count: 30),
      ],
    );
