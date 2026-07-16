import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_session_state.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/mock_floating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MockSessionInProgress stateAt(
    int index, {
    int elapsed = 0,
    bool strict = false,
  }) {
    return MockSessionInProgress(
      attemptId: 'att_1',
      durationSeconds: 180 * 60,
      questionIds: [for (var i = 0; i < 70; i += 1) 'q_$i'],
      currentIndex: index,
      elapsedSeconds: elapsed,
      answers: const {},
      flags: const {},
      strictMode: strict,
    );
  }

  Widget harness({
    required MockSessionInProgress state,
    Duration remainingInPart = const Duration(minutes: 30),
    int partPosition = 1,
    int partTotal = 40,
    bool canGoPrevious = true,
    bool canGoNext = true,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    VoidCallback? onGrid,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: MockSessionPage(
        state: state,
        remainingInPart: remainingInPart,
        partPosition: partPosition,
        partTotal: partTotal,
        canGoPrevious: canGoPrevious,
        canGoNext: canGoNext,
        onPrevious: onPrevious ?? () {},
        onNext: onNext ?? () {},
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: () {},
        onShowNavigator: onGrid ?? () {},
      ),
    );
  }

  testWidgets('the app bar carries the clock alone', (tester) async {
    await tester.pumpWidget(
      harness(state: stateAt(0), remainingInPart: const Duration(minutes: 29)),
    );

    expect(find.text('29:00'), findsOneWidget);
    // No title: the clock must never be hunted for. Mock Plan 3 gives the
    // pause control the trailing edge and nothing else joins it there.
    expect(find.text('1 of 70'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byKey(const ValueKey('mock-pause')), findsOneWidget);
  });

  testWidgets('the clock counts the part, not the exam', (tester) async {
    await tester.pumpWidget(
      harness(
        state: stateAt(0, elapsed: 60),
        remainingInPart: const Duration(minutes: 12, seconds: 30),
      ),
    );

    expect(find.text('12:30'), findsOneWidget);
    expect(find.text('179:00'), findsNothing);
  });

  testWidgets('the pager counts the part', (tester) async {
    await tester.pumpWidget(
      harness(state: stateAt(41), partPosition: 2, partTotal: 30),
    );

    expect(find.text('2 of 30'), findsOneWidget);
  });

  testWidgets('at a part boundary the controls dim rather than vanish',
      (tester) async {
    await tester.pumpWidget(
      harness(state: stateAt(39), canGoNext: false),
    );

    final bar = tester.widget<MockFloatingBar>(find.byType(MockFloatingBar));
    expect(bar.onNext, isNull);
    expect(bar.onPrevious, isNotNull);
    expect(find.byKey(const ValueKey('mock-next')), findsOneWidget);
  });

  testWidgets('nothing on the page reveals an outcome', (tester) async {
    await tester.pumpWidget(harness(state: stateAt(0)));

    expect(find.text('✓'), findsNothing);
    expect(find.text('✕'), findsNothing);
    expect(find.textContaining('Correct'), findsNothing);
  });
}
