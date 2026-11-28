// The quiz bar as Aedwon drew it (Nov 24): count with its chevron at the left,
// the flag on the bar's own center, the button at the right. No answer track,
// no flag in the question header, and no flight of marks at the session end.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_session_end_page.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(
      session: session,
      questionShownAt: DateTime.utc(2026),
    );
  }

  int nexts = 0;

  @override
  Future<void> next() async {
    nexts++;
    final s = state;
    if (s is! QuizRunning) return;
    if (s.session.isComplete) {
      state = QuizComplete(
        attempt: completedAttempt(s.session),
        session: s.session,
      );
    }
  }

  @override
  Future<void> start({
    required String examId,
    String? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}
}

Future<_Controller> _pump(
  WidgetTester tester, {
  required double width,
  required int total,
  required int answered,
  int correct = 7,
}) async {
  await tester.runAsync(loadDsFonts);
  final web = width >= 1024;
  debugWebPlatformOverride = web;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = Size(width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final completed = completedSession(total: total, correct: correct);
  final session = completed.copyWith(
    currentIndex: answered - 1,
    outcomes: completed.outcomes.take(answered).toList(),
  );
  late _Controller controller;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        flaggedIdsProvider.overrideWith((_) async => <String>{}),
        quizControllerProvider.overrideWith(
          (ref) => controller = _Controller(ref, session),
        ),
      ],
      child: MaterialApp(
        theme: web ? buildLightTheme(web: true) : buildLightTheme(web: false),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const QuizPage(examId: 'e', proIsActive: false),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

bool _named(Widget w, String name) => w.runtimeType.toString() == name;

void main() {
  for (final width in [390.0, 1440.0]) {
    final name = width < 1024 ? 'phone' : 'wide';

    testWidgets('$name: no answer track, flag on the bar center',
        (tester) async {
      await _pump(tester, width: width, total: 10, answered: 4);
      expect(
        find.byWidgetPredicate((w) => _named(w, 'AnswerTrack')),
        findsNothing,
      );
      final bar = tester.getRect(
        width < 1024 ? find.byType(FloatingBar) : find.byType(WebBottomBar),
      );
      final flag = tester.getRect(find.byTooltip('Flag question'));
      expect(
        (flag.center.dx - bar.center.dx).abs(),
        lessThanOrEqualTo(1),
        reason: 'flag ${flag.center.dx} vs bar ${bar.center.dx}',
      );
      expect(flag.width, greaterThanOrEqualTo(44));
      expect(flag.height, greaterThanOrEqualTo(44));
      // The count is at the left of the flag, the button at its right.
      expect(
        tester.getRect(find.text('4 of 10')).right,
        lessThan(flag.left),
      );
      expect(tester.getRect(find.text('Next')).left, greaterThan(flag.right));
      // The flag is in the bar only: nothing above the question stem.
      expect(find.byTooltip('Flag question'), findsOneWidget);
      expect(flag.center.dy, greaterThan(bar.top));
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name: no hint line in the bar', (tester) async {
      await _pump(tester, width: width, total: 10, answered: 4);
      expect(find.textContaining('Pick an answer'), findsNothing);
    });

    testWidgets('$name: the last Finish shows the results with no flight',
        (tester) async {
      await _pump(tester, width: width, total: 10, answered: 10);
      await tester.tap(find.text('Finish'));
      await tester.pump();
      expect(find.byType(QuizSessionEndPage), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => _named(w, 'QuizEndFlightHost')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name: Next in the middle goes on without results',
        (tester) async {
      final controller =
          await _pump(tester, width: width, total: 10, answered: 4);
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(controller.nexts, 1);
      expect(find.byType(QuizSessionEndPage), findsNothing);
    });
  }
}
