import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_session_controller.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';

class SessionHost extends StatefulWidget {
  const SessionHost({
    required this.strictMode,
    required this.atLastItemOfPart,
    super.key,
  });

  final bool strictMode;
  final bool atLastItemOfPart;

  @override
  State<SessionHost> createState() => _SessionHostState();
}

class _SessionHostState extends State<SessionHost> {
  late MockSessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MockSessionController.initial(
      attemptId: 'test-1',
      durationSeconds: 1800,
      questionIds: const ['q1', 'q2', 'q3'],
      parts: const [
        MockSessionPart(name: 'Part 1', startIndex: 0, count: 2, minutes: 30),
        MockSessionPart(name: 'Part 2', startIndex: 2, count: 1, minutes: 30),
      ],
      strictMode: widget.strictMode,
    );
    if (widget.atLastItemOfPart) {
      _controller.goTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _controller.state;
    if (current is! MockSessionInProgress) {
      return const SizedBox();
    }
    return MockSessionPage(
      state: current,
      remainingInPart: _controller.remainingInPart,
      partPosition:
          current.currentIndex - _controller.currentPart.startIndex + 1,
      partTotal: _controller.currentPart.count,
      canGoPrevious: _controller.canGoPrevious,
      canGoNext: _controller.canGoNext,
      onPrevious: () => setState(() => _controller.goPrevious()),
      onNext: () => setState(() => _controller.goNext()),
      onAnswer: (_) {},
      onToggleFlag: () {},
      onPause: () {},
      onEndPartEarly: () => setState(() => _controller.endPartEarly()),
    );
  }
}

void main() {
  Widget buildSession({
    required bool strictMode,
    required bool atLastItemOfPart,
  }) {
    return ProviderScope(
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => null),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: SessionHost(
          strictMode: strictMode,
          atLastItemOfPart: atLastItemOfPart,
        ),
      ),
    );
  }

  Future<void> pumpSession(
    WidgetTester tester, {
    required bool strictMode,
    required bool atLastItemOfPart,
  }) async {
    await tester.pumpWidget(
      buildSession(
        strictMode: strictMode,
        atLastItemOfPart: atLastItemOfPart,
      ),
    );
  }

  testWidgets('with strict off, next on the last item offers to end the part',
      (tester) async {
    await pumpSession(tester, strictMode: false, atLastItemOfPart: true);
    await tester.tap(find.byKey(const Key('mock-next')));
    await tester.pumpAndSettle();
    expect(find.text('End Part 1 now?'), findsOneWidget);
    expect(find.textContaining("doesn't carry over"), findsOneWidget);
  });

  testWidgets('with strict on, next is disabled and the reason is shown',
      (tester) async {
    await pumpSession(tester, strictMode: true, atLastItemOfPart: true);
    expect(
      find.text('Part 1 runs to the end of its time. Strict mode is on.'),
      findsOneWidget,
    );
    final next = tester.widget<InkWell>(find.byKey(const Key('mock-next')));
    expect(next.onTap, isNull);
  });

  testWidgets('the strict line appears only on the last item of a part',
      (tester) async {
    await pumpSession(tester, strictMode: true, atLastItemOfPart: false);
    expect(find.textContaining('runs to the end of its time'), findsNothing);
  });

  test('ending early forfeits the remaining time and never banks it', () {
    final controller = MockSessionController.initial(
      attemptId: 'test-1',
      durationSeconds: 3600,
      questionIds: const ['q1', 'q2', 'q3'],
      parts: const [
        MockSessionPart(name: 'Part 1', startIndex: 0, count: 2, minutes: 30),
        MockSessionPart(name: 'Part 2', startIndex: 2, count: 1, minutes: 30),
      ],
    );
    // ignore: cascade_invocations
    controller.tickTo(22 * 60);
    // ignore: cascade_invocations
    controller.endPartEarly();
    expect(controller.currentPartIndex, 1);
    expect(controller.remainingInPart, const Duration(minutes: 30));
  });
}
