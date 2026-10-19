import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';

// MK_Paper: the tap lands, the old question leaves left over 260ms while the
// new one enters from the right over 280ms, starting 80ms after the old one.
// Both use the house curve. The counter changes at 150ms, with no fade.
HydratedMockQuestion _question(String id) => HydratedMockQuestion(
      Question(
        id: id,
        version: 1,
        examIds: const [],
        topicId: 'topic',
        language: 'en',
        stem: 'Stem of $id',
        explanation: 'Explanation.',
        choices: const [
          Choice(id: 'a', label: 'A', text: 'One', isCorrect: true),
          Choice(id: 'b', label: 'B', text: 'Two', isCorrect: false),
        ],
      ),
      null,
    );

class _Harness extends StatefulWidget {
  const _Harness({required this.still});
  final bool still;
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(disableAnimations: widget.still),
      child: MockSessionPage(
        state: MockSessionInProgress(
          attemptId: 'a',
          durationSeconds: 3600,
          questionIds: const ['q1', 'q2', 'q3'],
          currentIndex: index,
          elapsedSeconds: 0,
          answers: const {},
          flags: const {},
          strictMode: false,
        ),
        remainingInPart: const Duration(minutes: 48),
        partPosition: index + 1,
        partTotal: 3,
        canGoPrevious: index > 0,
        canGoNext: index < 2,
        onPrevious: () => setState(() => index--),
        onNext: () => setState(() => index++),
        onAnswer: (_) {},
        onToggleFlag: () {},
        onPause: () {},
        onGoTo: (i) => setState(() => index = i),
      ),
    );
  }
}

Widget _app({bool still = false}) => ProviderScope(
      overrides: [
        hydratedMockQuestionProvider
            .overrideWith((ref, id) async => _question(id)),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: _Harness(still: still),
      ),
    );

Finder _swapOut() =>
    find.byKey(const ValueKey('paper-swap-out'), skipOffstage: false);

Finder _swapIn() =>
    find.byKey(const ValueKey('paper-swap-in'), skipOffstage: false);

Finder _stem(String id) => find.text('Stem of $id', skipOffstage: false);

Offset _offset(WidgetTester tester, String key) {
  final transform = tester.widget<Transform>(
    find
        .descendant(
          of: find.byKey(ValueKey(key), skipOffstage: false),
          matching: find.byType(Transform, skipOffstage: false),
        )
        .first,
  );
  return Offset(transform.transform.getTranslation().x, 0);
}

double _opacity(WidgetTester tester, String key) => tester
    .widget<Opacity>(find.byKey(ValueKey(key), skipOffstage: false))
    .opacity;

void main() {
  testWidgets('next slides the old question out and the new one in',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(_stem('q1'), findsOneWidget);
    expect(_swapOut(), findsNothing);

    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pump();
    expect(_stem('q1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(_swapOut(), findsOneWidget);
    expect(_swapIn(), findsOneWidget);

    // At 80ms the old question has moved, the new one has not started.
    await tester.pump(const Duration(milliseconds: 79));
    final out80 = PantasCurves.houseOut.transform(80 / 260);
    expect(_offset(tester, 'paper-swap-out').dx, closeTo(-24 * out80, .5));
    expect(_offset(tester, 'paper-swap-in').dx, closeTo(24, .001));
    expect(_opacity(tester, 'paper-swap-in'), closeTo(0, .001));

    // At 150ms the counter has already changed.
    await tester.pump(const Duration(milliseconds: 70));
    expect(find.text('2 of 3'), findsOneWidget);
    final in150 = PantasCurves.houseOut.transform((150 - 80) / 280);
    expect(_offset(tester, 'paper-swap-in').dx, closeTo(24 * (1 - in150), .5));
    expect(_opacity(tester, 'paper-swap-in'), closeTo(in150, .01));

    // The old question is gone by 260ms and the new one rests at 360ms.
    await tester.pump(const Duration(milliseconds: 110));
    expect(_opacity(tester, 'paper-swap-out'), closeTo(0, .001));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(_swapOut(), findsNothing);
    expect(_stem('q1'), findsNothing);
    expect(_stem('q2'), findsOneWidget);
  });

  testWidgets('going back or jumping from the grid changes at once',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-prev')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(_swapOut(), findsNothing);
    await tester.pumpAndSettle();
    expect(_stem('q1'), findsOneWidget);
  });

  testWidgets('with reduced motion the next question is simply there',
      (tester) async {
    await tester.pumpWidget(_app(still: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(_swapOut(), findsNothing);
    await tester.pumpAndSettle();
    expect(_stem('q2'), findsOneWidget);
    expect(_stem('q1'), findsNothing);
  });
}
