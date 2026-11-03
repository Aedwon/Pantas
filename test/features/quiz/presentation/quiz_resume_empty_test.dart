import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _MockLaunchCoordinator extends Mock implements QuizLaunchCoordinator {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const QuizPreparationRequest(userId: quizLocalUserId, examId: 'e'),
    );
  });

  // Resume only reads. With no open session the page used to stop on a retry
  // button that could never succeed, with no way out.
  for (final direct in [true, false]) {
    testWidgets(
        'resume with no open session leads to the Quiz tab, '
        '${direct ? 'opened directly' : 'pushed from the tab'}',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final launch = _MockLaunchCoordinator();
      when(() => launch.resumeToday(any())).thenAnswer((_) async => null);
      final router = GoRouter(
        initialLocation: direct ? '/quiz/resume/e' : '/quiz',
        routes: [
          GoRoute(
            path: '/quiz',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/quiz/resume/e'),
                child: const Text('quiz tab'),
              ),
            ),
          ),
          GoRoute(
            path: '/quiz/resume/:examId',
            builder: (_, __) =>
                const QuizPage(examId: 'e', mode: QuizPageMode.resume),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpAppWithRouter(
        router,
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          quizLaunchCoordinatorProvider.overrideWithValue(launch),
        ],
      );
      await tester.pumpAndSettle();
      if (!direct) {
        await tester.tap(find.text('quiz tab'));
        await tester.pumpAndSettle();
      }
      expect(find.text('quiz tab'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/quiz');
    });
  }
}
