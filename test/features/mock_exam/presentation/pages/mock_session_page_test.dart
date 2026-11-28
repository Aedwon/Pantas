import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:pantas/features/mock_exam/presentation/proctor_toast.dart';

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
  }) {
    return ProviderScope(
      overrides: [
        hydratedMockQuestionProvider.overrideWith((ref, id) => null),
      ],
      child: MaterialApp(
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
        ),
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
    final header = find.byKey(const ValueKey('mock-header'));
    expect(
      find.descendant(of: header, matching: find.byType(IconButton)),
      findsOneWidget,
    );
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

    expect(find.byType(FloatingBar), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.descendant(
              of: find.byKey(const ValueKey('mock-next')),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.descendant(
              of: find.byKey(const ValueKey('mock-prev')),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
    expect(find.byKey(const ValueKey('mock-next')), findsOneWidget);
  });

  testWidgets('nothing on the page reveals an outcome', (tester) async {
    await tester.pumpWidget(harness(state: stateAt(0)));

    expect(find.text('✓'), findsNothing);
    expect(find.text('✕'), findsNothing);
    expect(find.textContaining('Correct'), findsNothing);
  });

  // Board MK_Paper header: 50 high, 8 px sides, grid 44 / 1fr / 44 (U12).
  testWidgets('the phone header is 50 high with 8 px sides', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      harness(state: stateAt(0), remainingInPart: const Duration(minutes: 9)),
    );
    final header = find.byKey(const ValueKey('mock-header'));
    expect(tester.getSize(header).height, 50);
    final pause = tester.getRect(find.byKey(const Key('mock-pause')));
    expect(390 - pause.right, 8);
    expect(tester.getCenter(find.text('09:00')).dx, closeTo(195, 0.5));
  });

  // Board MK_Proctor: a 44 px pill that floats 12 px above the bar for 2.5
  // seconds, over the question list, which never moves (U5).
  testWidgets('a proctor warning is a 2.5 s pill over the list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final hostKey = GlobalKey<_ProctorHostState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hydratedMockQuestionProvider.overrideWith((ref, id) => null),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: _ProctorHost(key: hostKey, state: stateAt(0)),
        ),
      ),
    );
    final listBefore = tester.getRect(find.byType(ListView));
    final barTop = tester.getTopLeft(find.byType(FloatingBar)).dy;
    hostKey.currentState!.setRemaining(const Duration(minutes: 10));
    await tester.pump();
    await tester.pump();

    expect(find.text('10:00'), findsOneWidget);
    const copy = '10 minutes left in this subject.';
    expect(find.text(copy), findsOneWidget);
    final box = tester.getRect(find.byType(ProctorToast));
    // The test font is wider than Geist, so the line may wrap here; on a
    // phone the pill is 44 high (its minimum height) with the one line.
    expect(box.height, greaterThanOrEqualTo(44));
    expect(
      tester
          .widget<Container>(
            find.descendant(
              of: find.byType(ProctorToast),
              matching: find.byType(Container),
            ),
          )
          .constraints!
          .minHeight,
      44,
    );
    expect(box.left, 16);
    expect(box.right, 374);
    expect(barTop - box.bottom, 12);
    expect(tester.getRect(find.byType(ListView)), listBefore);
    await tester.pump(const Duration(milliseconds: 2400));
    expect(find.text(copy), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(copy), findsNothing);
    expect(tester.getRect(find.byType(ListView)), listBefore);
  });
}

class _ProctorHost extends StatefulWidget {
  const _ProctorHost({required this.state, super.key});

  final MockSessionInProgress state;

  @override
  State<_ProctorHost> createState() => _ProctorHostState();
}

class _ProctorHostState extends State<_ProctorHost> {
  Duration _remaining = const Duration(minutes: 10, seconds: 1);

  void setRemaining(Duration value) {
    setState(() => _remaining = value);
  }

  @override
  Widget build(BuildContext context) {
    return MockSessionPage(
      state: widget.state,
      remainingInPart: _remaining,
      partPosition: 1,
      partTotal: 40,
      canGoPrevious: false,
      canGoNext: true,
      onPrevious: () {},
      onNext: () {},
      onAnswer: (_) {},
      onToggleFlag: () {},
      onPause: () {},
    );
  }
}
