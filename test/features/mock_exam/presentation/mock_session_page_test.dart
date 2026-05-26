import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

// ignore_for_file: avoid_dynamic_calls

void main() {
  testWidgets('session page renders current question and countdown',
      (tester) async {
    await tester.pumpApp(
      MockSessionPage(
        state: _state(elapsedSeconds: 60),
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: () {},
        onShowNavigator: () {},
      ),
    );

    expect(find.text('q1'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
  });

  testWidgets('pause button is hidden in strict mode', (tester) async {
    await tester.pumpApp(
      MockSessionPage(
        state: _state(strictMode: true),
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: () {},
        onShowNavigator: () {},
      ),
    );

    expect(find.byIcon(Icons.pause), findsNothing);
  });

  testWidgets('answer tap and flag toggle call handlers', (tester) async {
    int? answer;
    var flagged = false;
    await tester.pumpApp(
      MockSessionPage(
        state: _state(),
        onAnswer: (value) => answer = value,
        onToggleFlag: () => flagged = true,
        onPause: () {},
        onShowNavigator: () {},
      ),
    );

    await tester.tap(find.text('A'));
    await tester.tap(find.byIcon(Icons.flag_outlined));

    expect(answer, 0);
    expect(flagged, isTrue);
  });

  testWidgets('system back shows leave mock confirmation', (tester) async {
    await tester.pumpApp(
      MockSessionPage(
        state: _state(),
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: () {},
        onShowNavigator: () {},
      ),
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
