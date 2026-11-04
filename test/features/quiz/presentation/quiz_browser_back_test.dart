import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/quiz_routes.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/application/quiz_leave_guard.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedSession;

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  void fail() => state = const QuizFailure('x');

  @override
  Future<void> start({
    required String examId,
    String? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}
}

/// Browser Back leaves a session without a pop, so the session routes ask the
/// open session first (3M-8). It must show the dialog Esc shows.
void main() {
  test('only the web build guards the session routes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final provider = Provider<List<RouteBase>>(quizRoutes);
    final webProvider = Provider<List<RouteBase>>(
      (ref) => quizRoutes(ref, isWeb: true),
    );
    List<String> guarded(List<RouteBase> routes) => [
          for (final r in routes.cast<GoRoute>())
            if (r.onExit != null) r.path,
        ];
    expect(guarded(container.read(provider)), isEmpty);
    expect(guarded(container.read(webProvider)), [
      '/quiz/today/:examId',
      '/quiz/resume/:examId',
      '/quiz/quick/:examId',
      '/quiz/practice/:examId/run',
      '/quiz/retake/:examId',
      '/quiz/inline/:examId/:lessonId',
    ]);
  });

  for (final dark in [false, true]) {
    group('browser Back in a session dark=$dark', () {
      late GoRouter router;
      late ProviderContainer container;
      late _Controller controller;

      Future<void> pumpSession(WidgetTester tester) async {
        debugWebPlatformOverride = true;
        addTearDown(() => debugWebPlatformOverride = null);
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final completed = completedSession(batch: true);
        final session = completed.copyWith(
          currentIndex: 3,
          outcomes: completed.outcomes.take(3).toList(),
        );
        late _Controller made;
        container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            flaggedIdsProvider.overrideWith((_) async => <String>{}),
            quizControllerProvider.overrideWith(
              (ref) => made = _Controller(ref, session),
            ),
          ],
        );
        addTearDown(container.dispose);
        router = GoRouter(
          initialLocation: '/quiz',
          routes: [
            GoRoute(
              path: '/quiz',
              builder: (_, __) => const Scaffold(body: Text('Tab')),
              routes: [
                GoRoute(
                  path: 'session',
                  builder: (_, __) =>
                      const QuizPage(examId: 'e', proIsActive: false),
                  onExit: (context, state) =>
                      container.read(quizLeaveGuardProvider).allowLeave(),
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme:
                  dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        unawaited(router.push('/quiz/session'));
        await tester.pumpAndSettle();
        controller = made;
        expect(find.text('Reviews · Session 1 of 2'), findsOneWidget);
      }

      testWidgets('shows the leave dialog and stays; Keep Going keeps it',
          (tester) async {
        await pumpSession(tester);
        router.go('/quiz');
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsOneWidget);
        expect(find.text('Tab'), findsNothing);
        // A second Back with the dialog open adds nothing.
        router.go('/quiz');
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsOneWidget);
        expect(find.text('Tab'), findsNothing);
        await tester.tap(find.text('Keep Going'));
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsNothing);
        expect(find.text('Reviews · Session 1 of 2'), findsOneWidget);
        expect(find.text('Tab'), findsNothing);
      });

      testWidgets('Leave in that dialog leaves the session', (tester) async {
        await pumpSession(tester);
        router.go('/quiz');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Leave'));
        await tester.pumpAndSettle();
        expect(find.text('Tab'), findsOneWidget);
        expect(find.text('Leave this session?'), findsNothing);
      });

      testWidgets('a session that is not running lets Back through',
          (tester) async {
        await pumpSession(tester);
        controller.fail();
        await tester.pumpAndSettle();
        router.go('/quiz');
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsNothing);
        expect(find.text('Tab'), findsOneWidget);
      });
    });
  }
}
