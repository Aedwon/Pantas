import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/questions_unavailable.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _FailedController extends QuizController {
  _FailedController(super.ref) {
    state = const QuizFailure('offline');
  }
}

void main() {
  for (final direct in [true, false]) {
    for (final escape in [true, false]) {
      testWidgets('wide failed quiz exits direct=$direct escape=$escape',
          (tester) async {
        debugWebPlatformOverride = true;
        addTearDown(() => debugWebPlatformOverride = null);
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final router = GoRouter(
          initialLocation: direct ? '/failed' : '/quiz',
          routes: [
            GoRoute(
              path: '/quiz',
              builder: (context, _) => Scaffold(
                body: TextButton(
                  onPressed: () => context.push('/failed'),
                  child: const Text('Quiz home'),
                ),
              ),
            ),
            GoRoute(
              path: '/failed',
              builder: (_, __) => const QuizPage(
                examId: 'e',
                mode: QuizPageMode.practice,
                proIsActive: false,
              ),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpAppWithRouter(
          router,
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            quizControllerProvider.overrideWith(_FailedController.new),
          ],
        );
        if (!direct) {
          await tester.tap(find.text('Quiz home'));
        }
        await tester.pumpAndSettle();
        expect(find.byType(WebCenteredTopBar), findsOneWidget);
        final message = find.text('Could not load your quiz.');
        expect(message, findsOneWidget);
        expect(tester.getCenter(message).dx, closeTo(720, 1));
        expect(tester.getCenter(message).dy, greaterThan(300));
        if (escape) {
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        } else {
          await tester.tap(find.byTooltip('Leave session'));
        }
        await tester.pumpAndSettle();
        expect(find.text('Quiz home'), findsOneWidget);
      });
    }
  }

  for (final wide in [false, true]) {
    testWidgets('direct empty inline quiz is unavailable wide=$wide',
        (tester) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final content = openTestContentDatabase();
      await seedContentLesson(content, lessonId: 'empty', topicId: 't');
      final router = GoRouter(
        initialLocation: '/empty',
        routes: [
          GoRoute(
            path: '/quiz',
            builder: (_, __) => const Scaffold(body: Text('Quiz home')),
          ),
          GoRoute(
            path: '/empty',
            builder: (_, __) => const QuizPage(
              examId: 'e',
              lessonId: 'empty',
              mode: QuizPageMode.inline,
              proIsActive: false,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpAppWithRouter(
        router,
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(QuestionsUnavailable), findsOneWidget);
      expect(find.text('Try Again'), findsNothing);
      if (wide) {
        expect(find.byType(WebCenteredTopBar), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      } else {
        await tester.tap(find.text('Quiz'));
      }
      await tester.pumpAndSettle();
      expect(find.text('Quiz home'), findsOneWidget);
    });
  }
}
