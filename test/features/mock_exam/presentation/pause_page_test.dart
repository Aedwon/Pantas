import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/answer_row.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';

class MockSessionPageHost extends StatefulWidget {
  const MockSessionPageHost({
    required this.pauseWarningSeen,
    required this.strictMode,
    super.key,
  });

  final bool pauseWarningSeen;
  final bool strictMode;

  @override
  State<MockSessionPageHost> createState() => _MockSessionPageHostState();
}

class _MockSessionPageHostState extends State<MockSessionPageHost> {
  late bool _pauseWarningSeen;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _pauseWarningSeen = widget.pauseWarningSeen;
  }

  @override
  Widget build(BuildContext context) {
    if (_isPaused) {
      return PausePage(
        partName: 'Numerical Ability',
        remaining: const Duration(minutes: 20),
        answered: 10,
        total: 30,
        flagged: 1,
        onResume: () => setState(() => _isPaused = false),
        onDiscard: () {},
      );
    }
    final state = MockSessionInProgress(
      attemptId: 'test-1',
      durationSeconds: 1800,
      questionIds: const ['q1', 'q2'],
      currentIndex: 0,
      elapsedSeconds: 600,
      answers: const {},
      flags: const {},
      strictMode: widget.strictMode,
    );
    return MockSessionPage(
      state: state,
      remainingInPart: const Duration(minutes: 20),
      partPosition: 1,
      partTotal: 30,
      canGoPrevious: false,
      canGoNext: true,
      onPrevious: () {},
      onNext: () {},
      onAnswer: (_) {},
      onToggleFlag: () {},
      pauseWarningSeen: _pauseWarningSeen,
      onPause: () => setState(() => _isPaused = true),
      onPauseWarningSeenChanged: (val) =>
          setState(() => _pauseWarningSeen = val),
      onShowNavigator: () {},
    );
  }
}

void main() {
  Widget buildPaused({
    required Duration remaining,
    VoidCallback? onResume,
    VoidCallback? onDiscard,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: PausePage(
        partName: 'Numerical Ability',
        remaining: remaining,
        answered: 25,
        total: 30,
        flagged: 2,
        onResume: onResume ?? () {},
        onDiscard: onDiscard ?? () {},
      ),
    );
  }

  Future<void> pumpPaused(
    WidgetTester tester, {
    Duration remaining = const Duration(minutes: 20),
    VoidCallback? onResume,
    VoidCallback? onDiscard,
  }) async {
    await tester.pumpWidget(
      buildPaused(
        remaining: remaining,
        onResume: onResume,
        onDiscard: onDiscard,
      ),
    );
  }

  Color rustOf(WidgetTester tester) {
    final context = tester.element(find.byType(PausePage));
    return context.colors.rust;
  }

  Widget buildSession({
    required bool pauseWarningSeen,
    required bool strictMode,
  }) {
    return ProviderScope(
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => null),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: MockSessionPageHost(
          pauseWarningSeen: pauseWarningSeen,
          strictMode: strictMode,
        ),
      ),
    );
  }

  Future<void> pumpSession(
    WidgetTester tester, {
    required bool pauseWarningSeen,
    bool strictMode = false,
  }) async {
    await tester.pumpWidget(
      buildSession(
        pauseWarningSeen: pauseWarningSeen,
        strictMode: strictMode,
      ),
    );
  }

  testWidgets('the paper is not visible while paused', (tester) async {
    await pumpPaused(tester);
    expect(find.textContaining('ratio of boys to girls'), findsNothing);
    expect(find.byType(AnswerRow), findsNothing);
  });

  testWidgets('it shows time left, not time elapsed', (tester) async {
    await pumpPaused(
      tester,
      remaining: const Duration(minutes: 21, seconds: 47),
    );
    expect(find.text('21:47'), findsOneWidget);
    expect(find.text('in this part'), findsOneWidget);
  });

  testWidgets('resume is the only green thing and discard is rust text',
      (tester) async {
    await pumpPaused(tester);
    expect(find.byType(BoardButton), findsOneWidget);
    final discard = tester.widget<Text>(find.text('Discard this mock'));
    expect(discard.style!.color, rustOf(tester));
  });

  testWidgets('the warning fires on the first pause only', (tester) async {
    await pumpSession(tester, pauseWarningSeen: false);
    await tester.tap(find.byKey(const Key('mock-pause')));
    await tester.pumpAndSettle();
    expect(find.text('Real exams do not pause.'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mock-pause')));
    await tester.pumpAndSettle();
    expect(find.text('Real exams do not pause.'), findsNothing);
  });

  testWidgets('strict mode has no pause control at all', (tester) async {
    await pumpSession(tester, strictMode: true, pauseWarningSeen: true);
    expect(find.byKey(const Key('mock-pause')), findsNothing);
  });

  testWidgets('discard takes a rust confirm and does not use up a mock',
      (tester) async {
    await pumpPaused(tester);
    await tester.tap(find.text('Discard this mock'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this mock?'), findsOneWidget);
    expect(find.textContaining('does not use up a mock'), findsOneWidget);
  });
}
