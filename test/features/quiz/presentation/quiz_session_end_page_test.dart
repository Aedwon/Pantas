import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/quiz_routes.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/presentation/quiz_review_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_session_end_page.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
import 'package:pantas/features/review_prompt/domain/app_review_gateway.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _Gateway implements AppReviewGateway {
  int asked = 0;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<void> requestReview() async {
    asked++;
  }
}

void main() {
  for (final view in [
    'all',
    'mistakes',
    'historical',
    'fresh',
    'customDone',
    'flaggedDone',
    'lessonDone',
    'retakeDone',
  ]) {
    testWidgets('completed $view uses actual saved answers and origin',
        (tester) async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      final gateway = _Gateway();
      final done = view.endsWith('Done');
      final attempt = Attempt(
        id: 'a',
        examId: 'e',
        origin: view == 'lessonDone'
            ? 'inline'
            : view == 'retakeDone'
                ? 'retake'
                : view == 'customDone'
                    ? 'drill'
                    : 'flagged',
        startedAt: DateTime.utc(2026),
        completedAt: DateTime.utc(2026, 1, 1, 0, 0, 40),
        items: [
          for (var i = 1; i <= 5; i++)
            AttemptItem(
              questionId: 'q$i',
              questionVersion: 1,
              chosenChoiceId: i == 3 ? 'q${i}_b' : 'q${i}_a',
              correctChoiceId: 'q${i}_a',
              responseMs: 100,
            ),
        ],
      );
      await tester.runAsync(() async {
        await seedContentTopicWithQuestions(
          content,
          examId: 'e',
          subjectId: 's',
          topicId: 't',
          topicName: 'Topic',
          questionIds: [for (var i = 1; i <= 5; i++) 'q$i'],
        );
        await AttemptsRepository(db).save(attempt);
        await AttemptsRepository(db).save(
          attempt.copyWith(id: 'b', items: attempt.items.take(2).toList()),
        );
        await SyncActiveContextStore(db).clearStable();
      });

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          authStateProvider.overrideWith(
            (_) => Stream.value(const AuthState.anonymous(uid: 'one')),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          appReviewGatewayProvider.overrideWithValue(gateway),
          proForActiveExamProvider.overrideWith((_) async => false),
          entitlementProvider
              .overrideWith((_) => Stream.value(const Entitlement.free())),
        ],
      );
      await tester.runAsync(() async {
        await container.read(authStateProvider.future);
        await container.read(activeExamFocusProvider.future);
      });

      final router = GoRouter(
        initialLocation: done
            ? '/origin'
            : view == 'all' || view == 'mistakes'
                ? '/quiz/all/a${view == 'mistakes' ? '?mistakes=true' : ''}'
                : '/end',
        routes: [
          if (!done) ...container.read(Provider(quizRoutes)),
          GoRoute(
            path: '/origin',
            builder: (_, __) => const Scaffold(body: Text('Origin')),
          ),
          if (done)
            GoRoute(
              path: '/quiz/practice/e',
              builder: (_, __) => const Scaffold(body: Text('Picker')),
            ),
          GoRoute(
            path: '/end',
            builder: (_, __) => QuizSessionEndPage(
              attemptId: 'a',
              fresh: view == 'fresh',
              custom: view == 'customDone',
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: buildLightTheme(),
            routerConfig: router,
          ),
        ),
      );
      if (done) {
        if (view == 'customDone') {
          unawaited(router.push<void>('/quiz/practice/e'));
          await tester.pumpAndSettle();
        }
        unawaited(router.push<void>('/end'));
        await tester.pump();
      }
      for (var i = 0;
          i < 100 &&
              find
                  .text(
                    view == 'all'
                        ? 'All questions'
                        : view == 'mistakes'
                            ? 'Your mistakes'
                            : 'Session finished.',
                  )
                  .evaluate()
                  .isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 20));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 2)),
        );
      }

      await tester.pumpAndSettle();
      if (view == 'all' || view == 'mistakes') {
        expect(find.text('4 of 5 correct'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('1'), view == 'all' ? findsOneWidget : findsNothing);
        await tester.tap(find.text('3'));
        for (var i = 0; i < 80 && find.text('3 of 5').evaluate().isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 20));
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 2)),
          );
        }
        expect(find.text('3 of 5'), findsOneWidget);
        expect(
          GoRouterState.of(tester.element(find.byType(QuizReviewPage)))
              .uri
              .path,
          '/quiz/viewer/a',
        );
        if (view == 'all') {
          router.pop();
          await tester.pumpAndSettle();
          router.go('/quiz/all/b');
          for (var i = 0;
              i < 80 && find.text('2 of 2 correct').evaluate().isEmpty;
              i++) {
            await tester.pump(const Duration(milliseconds: 20));
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 2)),
            );
          }
          expect(find.text('2 of 2 correct'), findsOneWidget);
          router.go('/quiz/viewer/a?index=2&fromAll=true');
          for (var i = 0;
              i < 80 && find.text('3 of 5').evaluate().isEmpty;
              i++) {
            await tester.pump(const Duration(milliseconds: 20));
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 2)),
            );
          }
          expect(find.text('3 of 5'), findsOneWidget);
          router.go('/quiz/viewer/b?index=1&fromAll=true');
          for (var i = 0;
              i < 80 && find.text('2 of 2').evaluate().isEmpty;
              i++) {
            await tester.pump(const Duration(milliseconds: 20));
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 2)),
            );
          }
          expect(find.text('2 of 2'), findsOneWidget);
        }
      } else if (done) {
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Origin'), findsOneWidget);
        expect(find.text('Picker'), findsNothing);
      } else {
        expect(find.text('Flagged questions'), findsOneWidget);
        expect(find.text('in under 1 minute'), findsOneWidget);
        expect(gateway.asked, view == 'fresh' ? 1 : 0);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      router.dispose();
      container.dispose();
      await tester.runAsync(() async {
        await db.close();

        await content.close();
      });
    });
  }
}
