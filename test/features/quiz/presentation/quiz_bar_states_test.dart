// The phone session bar in every state, at every phone width (Aedwon's bar,
// Nov 24: count left, flag centered, button right, no hint, no answer track):
// the flag is always in the bar and on its center, and the bar never overflows.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedSession;

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  @override
  Future<void> start({
    required String examId,
    String? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}
}

enum _State { pick, next, finish, back }

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  required int total,
  required _State state,
  double scale = 1,
}) async {
  await tester.runAsync(loadDsFonts);
  debugWebPlatformOverride = false;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = Size(width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final completed = completedSession(total: total);
  final answered = switch (state) {
    _State.pick => 3,
    _State.next => 3,
    _ => total,
  };
  final session = completed.copyWith(
    currentIndex: switch (state) {
      _State.pick => 3,
      _State.next => 2,
      _ => total - 1,
    },
    outcomes: completed.outcomes.take(answered).toList(),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        flaggedIdsProvider.overrideWith((_) async => <String>{}),
        quizControllerProvider.overrideWith((ref) => _Controller(ref, session)),
      ],
      child: MaterialApp(
        theme: buildLightTheme(web: false),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        ),
        home: const QuizPage(examId: 'e', proIsActive: false),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (state == _State.back) {
    await tester.tap(find.text('$total of $total'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('grid-question-0-${total - 2}')));
    await tester.pumpAndSettle();
  }
}

void _expectFlagInBar(WidgetTester tester, double width) {
  expect(tester.takeException(), isNull, reason: 'no overflow at $width');
  final flag = tester.getRect(find.byTooltip('Flag question'));
  // The bar is at the bottom of the screen; the header is at the top.
  expect(flag.center.dy, greaterThan(700), reason: 'flag in the bar');
  expect(flag.width, greaterThanOrEqualTo(44));
  expect(flag.height, greaterThanOrEqualTo(44));
  expect(flag.right, lessThanOrEqualTo(width));
  expect(
    find.byWidgetPredicate((w) => w.runtimeType.toString() == 'AnswerTrack'),
    findsNothing,
    reason: 'the bar draws no answer track',
  );
  // The flag sits on the bar's own center, not between the count and button.
  final bar = tester.getRect(find.byType(FloatingBar));
  expect(
    (flag.center.dx - bar.center.dx).abs(),
    lessThanOrEqualTo(1),
    reason: 'flag center ${flag.center.dx} vs bar center ${bar.center.dx}',
  );
}

void main() {
  for (final width in [320.0, 344.0, 360.0, 390.0, 430.0]) {
    for (final total in [5, 10, 20, 25]) {
      for (final state in _State.values) {
        testWidgets('bar at ${width.toInt()}, $total questions, ${state.name}',
            (tester) async {
          await _pump(tester, width: width, total: total, state: state);
          _expectFlagInBar(tester, width);
        });
      }
    }
  }

  testWidgets('bar at 320 and 1.3 times text, 20 questions, looking back',
      (tester) async {
    await _pump(
      tester,
      width: 320,
      total: 20,
      state: _State.back,
      scale: 1.3,
    );
    _expectFlagInBar(tester, 320);
  });

  testWidgets('bar at 320 and 1.3 times text, 10 questions, Finish',
      (tester) async {
    await _pump(
      tester,
      width: 320,
      total: 10,
      state: _State.finish,
      scale: 1.3,
    );
    _expectFlagInBar(tester, 320);
  });
}
