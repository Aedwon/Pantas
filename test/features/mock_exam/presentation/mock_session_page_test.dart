import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../../helpers/pump_app.dart';

// ignore_for_file: avoid_dynamic_calls

void main() {
  testWidgets('session page renders current question and countdown',
      (tester) async {
    const mockQuestion = HydratedMockQuestion(
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
      ),
      overrides: [
        hydratedMockQuestionProvider
            .overrideWith((ref, id) => Future.value(mockQuestion)),
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
      ),
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => Future.value()),
      ],
    );

    expect(find.byIcon(Icons.pause), findsNothing);
  });

  testWidgets('answer tap and flag toggle call handlers', (tester) async {
    int? answer;
    var flagged = false;
    const mockQuestion = HydratedMockQuestion(
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
      ),
      overrides: [
        hydratedMockQuestionProvider
            .overrideWith((ref, id) => Future.value(mockQuestion)),
      ],
    );

    await tester.tap(find.text('A'));
    // The flag moved into the pager when the app bar became the clock
    // alone.
    await tester.tap(find.byKey(const ValueKey('mock-flag')));

    expect(answer, 0);
    expect(flagged, isTrue);
  });

  Future<void> pumpPaper(
    WidgetTester tester, {
    required bool strictMode,
    bool pauseWarningSeen = false,
    VoidCallback? onPause,
    ValueChanged<bool>? onWarningSeen,
  }) async {
    await tester.pumpAppWithProviders(
      MockSessionPage(
        state: _state(strictMode: strictMode),
        remainingInPart: const Duration(minutes: 10),
        partPosition: 1,
        partTotal: 2,
        canGoPrevious: false,
        canGoNext: true,
        onPrevious: () {},
        onNext: () {},
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: onPause ?? () {},
        pauseWarningSeen: pauseWarningSeen,
        onPauseWarningSeenChanged: onWarningSeen,
      ),
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => Future.value()),
      ],
    );
  }

  Future<void> pressSystemBack(WidgetTester tester) async {
    final widgetsAppState = tester.state<State<WidgetsApp>>(
      find.byType(WidgetsApp),
    ) as dynamic;
    await widgetsAppState.didPopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('system back acts like pause, warning first', (tester) async {
    var paused = 0;
    await pumpPaper(tester, strictMode: false, onPause: () => paused++);

    await pressSystemBack(tester);

    expect(find.text("Real exams don't pause."), findsOneWidget);
    expect(
      find.text(
        'Use this only when you really have to. The clock stops, but you '
        "won't get this during the real exam.",
      ),
      findsOneWidget,
    );
    expect(paused, 0);
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(paused, 1);
  });

  testWidgets('system back pauses at once once the warning has been seen',
      (tester) async {
    var paused = 0;
    await pumpPaper(
      tester,
      strictMode: false,
      pauseWarningSeen: true,
      onPause: () => paused++,
    );

    await pressSystemBack(tester);

    expect(find.text("Real exams don't pause."), findsNothing);
    expect(paused, 1);
  });

  testWidgets('keeping going from the warning does not pause', (tester) async {
    var paused = 0;
    await pumpPaper(tester, strictMode: false, onPause: () => paused++);

    await pressSystemBack(tester);
    await tester.tap(find.text('Keep Going'));
    await tester.pumpAndSettle();

    expect(find.text("Real exams don't pause."), findsNothing);
    expect(paused, 0);
  });

  testWidgets('pause warning stores only the selected suppression choice',
      (tester) async {
    final seen = <bool>[];
    var paused = 0;
    await pumpPaper(
      tester,
      strictMode: false,
      onPause: () => paused++,
      onWarningSeen: seen.add,
    );
    await pressSystemBack(tester);
    await tester.tap(find.text("Don't show this again"));
    await tester.pump();
    expect(seen, isEmpty);
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(seen, [true]);
    expect(paused, 1);
  });

  testWidgets('system back is blocked in strict mode', (tester) async {
    var paused = 0;
    await pumpPaper(tester, strictMode: true, onPause: () => paused++);

    await pressSystemBack(tester);

    expect(find.text("Real exams don't pause."), findsNothing);
    expect(find.text('Leave mock?'), findsNothing);
    expect(paused, 0);
    expect(find.byType(MockSessionPage), findsOneWidget);
    expect(
      find.text('Strict mode is on. Back is off until you submit.'),
      findsOneWidget,
    );
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
