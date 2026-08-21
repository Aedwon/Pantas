import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../../helpers/pump_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';

// ignore_for_file: avoid_dynamic_calls

void main() {
  testWidgets('session page renders current question and countdown',
      (tester) async {
    final mockQuestion = const HydratedMockQuestion(
      Question(
        id: 'q1',
        version: 1,
        examIds: [],
        language: 'en',
        topicId: 't1',
        stem: 'Question 1',
        choices: [
          Choice(id: 'c1', label: 'A', text: 'Choice A', isCorrect: false),
          Choice(id: 'c2', label: 'B', text: 'Choice B', isCorrect: false),
        ],
        explanation: '',
      ),
      null,
    );

    await tester.pumpAppWithProviders(
      MockSessionPage(
        state: _state(elapsedSeconds: 60),
        remainingInPart: const Duration(minutes: 9),
        partPosition: 1,
        partTotal: 2,
        canGoPrevious: false,
        canGoNext: true,
        onPrevious: () {},
        onNext: () {},
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: () {},
        onShowNavigator: () {},
      ),
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => Future.value(mockQuestion)),
      ],
    );

    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
  });

  // The app bar carries the clock alone now, so no control sits there in
  // either mode. The pause flow itself is not designed yet.
  testWidgets('no control shares the app bar with the clock', (tester) async {
    await tester.pumpAppWithProviders(
      MockSessionPage(
        state: _state(strictMode: true),
        remainingInPart: const Duration(minutes: 10),
        partPosition: 1,
        partTotal: 2,
        canGoPrevious: false,
        canGoNext: true,
        onPrevious: () {},
        onNext: () {},
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: () {},
        onShowNavigator: () {},
      ),
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => Future.value(null)),
      ],
    );

    expect(find.byIcon(Icons.pause), findsNothing);
  });

  testWidgets('answer tap and flag toggle call handlers', (tester) async {
    int? answer;
    var flagged = false;
    final mockQuestion = const HydratedMockQuestion(
      Question(
        id: 'q1',
        version: 1,
        examIds: [],
        language: 'en',
        topicId: 't1',
        stem: 'Question 1',
        choices: [
          Choice(id: 'c1', label: 'A', text: 'Choice A', isCorrect: false),
          Choice(id: 'c2', label: 'B', text: 'Choice B', isCorrect: false),
        ],
        explanation: '',
      ),
      null,
    );

    await tester.pumpAppWithProviders(
      MockSessionPage(
        state: _state(),
        remainingInPart: const Duration(minutes: 10),
        partPosition: 1,
        partTotal: 2,
        canGoPrevious: false,
        canGoNext: true,
        onPrevious: () {},
        onNext: () {},
        onAnswer: (value) => answer = value,
        onToggleFlag: () => flagged = true,
        onPause: () {},
        onShowNavigator: () {},
      ),
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => Future.value(mockQuestion)),
      ],
    );

    await tester.tap(find.text('A'));
    // The flag moved into the pager when the app bar became the clock
    // alone.
    await tester.tap(find.byKey(const ValueKey('mock-flag')));

    expect(answer, 0);
    expect(flagged, isTrue);
  });

  testWidgets('system back shows leave mock confirmation', (tester) async {
    await tester.pumpAppWithProviders(
      MockSessionPage(
        state: _state(),
        remainingInPart: const Duration(minutes: 10),
        partPosition: 1,
        partTotal: 2,
        canGoPrevious: false,
        canGoNext: true,
        onPrevious: () {},
        onNext: () {},
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: () {},
        onShowNavigator: () {},
      ),
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => Future.value(null)),
      ],
    );

    final widgetsAppState = tester.state<State<WidgetsApp>>(
      find.byType(WidgetsApp),
    ) as dynamic;
    await widgetsAppState.didPopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Leave mock?'), findsOneWidget);
  });
}

MockSessionInProgress _state({
  int elapsedSeconds = 0,
  bool strictMode = false,
}) {
  return MockSessionInProgress(
    attemptId: 'mock_1',
    durationSeconds: 600,
    questionIds: const ['q1', 'q2'],
    currentIndex: 0,
    elapsedSeconds: elapsedSeconds,
    answers: const {},
    flags: const {},
    strictMode: strictMode,
  );
}
