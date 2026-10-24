import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';

// October20 approved motion: mirrored 380ms,40px slides; 200ms grid crossfade.
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

    await tester.pump(const Duration(milliseconds: 189));
    final progress = const Cubic(.2, .9, .3, 1).transform(.5);
    expect(_offset(tester, 'paper-swap-out').dx, closeTo(-40 * progress, .5));
    expect(
      _offset(tester, 'paper-swap-in').dx,
      closeTo(40 * (1 - progress), .5),
    );
    expect(_opacity(tester, 'paper-swap-in'), closeTo(progress, .01));
    expect(find.text('2 of 3'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 190));
    await tester.pumpAndSettle();
    expect(_swapOut(), findsNothing);
    expect(_stem('q1'), findsNothing);
    expect(_stem('q2'), findsOneWidget);
  });

  testWidgets('Previous mirrors Next with a 380ms slide from the left',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-prev')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(_swapOut(), findsOneWidget);
    expect(_offset(tester, 'paper-swap-in').dx, lessThan(0));
    await tester.pump(const Duration(milliseconds: 189));
    final progress = const Cubic(.2, .9, .3, 1).transform(.5);
    expect(_offset(tester, 'paper-swap-out').dx, closeTo(40 * progress, .5));
    await tester.pumpAndSettle();
    expect(_stem('q1'), findsOneWidget);
  });

  testWidgets('an adjacent grid jump crossfades over 200ms', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('grid-question-0-2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_swapOut(), findsOneWidget);
    expect(_offset(tester, 'paper-swap-in'), Offset.zero);
    expect(_offset(tester, 'paper-swap-out'), Offset.zero);
    expect(_opacity(tester, 'paper-swap-in'), closeTo(.5, .02));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(_stem('q2'), findsOneWidget);
    expect(_swapOut(), findsNothing);
  });

  testWidgets(
      'selecting the current grid question does not change the next slide',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('grid-question-0-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_offset(tester, 'paper-swap-in').dx, greaterThan(0));
    await tester.pumpAndSettle();
  });

  testWidgets('turning on reduced motion ends an active question transition',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(_swapOut(), findsOneWidget);
    await tester.pumpWidget(_app(still: true));
    expect(_swapOut(), findsNothing);
    expect(_stem('q2'), findsOneWidget);
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
