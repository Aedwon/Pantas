import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/quiz_routes.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final (product, paused, notes) in [
    ('pantas_cs_monthly', false, true),
    ('pantas_pro_monthly', false, false),
    ('pantas_cs_monthly', true, false),
  ]) {
    testWidgets(
        'ordinary route applies current $product coverage paused=$paused',
        (tester) async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      var refreshFocus = false;
      final pendingFocus = Completer<ActiveExamFocus>();
      const question = Question(
        id: 'q',
        version: 1,
        examIds: ['exam_cse_pro'],
        topicId: 't',
        language: 'en',
        stem: 'Original question',
        explanation: 'Correct explanation',
        choices: [
          Choice(id: 'a', label: 'A', text: 'Right', isCorrect: true),
          Choice(
            id: 'b',
            label: 'B',
            text: 'Wrong',
            isCorrect: false,
            rationale: 'Paid wrong-choice note',
          ),
        ],
      );
      final session = QuizSession(
        sessionId: 's',
        examId: 'exam_cse_pro',
        questions: const [question],
        currentIndex: 0,
        outcomes: const [
          AnswerOutcome(
            questionId: 'q',
            questionVersion: 1,
            chosenChoiceId: 'b',
            correctChoiceId: 'a',
            responseMs: 1,
          ),
        ],
        startedAt: DateTime.utc(2026),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          devProOverrideProvider.overrideWithValue(null),
          activeExamFocusProvider.overrideWith(
            (_) => refreshFocus
                ? pendingFocus.future
                : Future.value(
                    ActiveExamFocus.selected(buildExam(id: 'exam_cse_pro')),
                  ),
          ),
          entitlementProvider.overrideWith(
            (_) => Stream.value(
              Entitlement(
                plan: EntitlementPlan.monthly,
                productId: product,
                expiresAt: DateTime.utc(2030),
                state:
                    paused ? EntitlementState.paused : EntitlementState.active,
              ),
            ),
          ),
          quizControllerProvider.overrideWith(
            (ref) => _Running(
              ref,
              QuizRunning(
                session: session,
                persisted: true,
                questionShownAt: DateTime.utc(2026),
              ),
            ),
          ),
        ],
      );
      final routes = container.read(Provider(quizRoutes));
      final router = GoRouter(
        initialLocation: '/quiz/practice/exam_cse_pro/run',
        routes: routes,
      );
      addTearDown(() async {
        router.dispose();
        container.dispose();
        await db.close();
        await content.close();
      });
      await tester.runAsync(() async {
        expect(await container.read(proForActiveExamProvider.future), notes);
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: buildLightTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(container.read(proForActiveExamProvider).valueOrNull, notes);
      expect(
        find.text('Paid wrong-choice note'),
        notes ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(ProPausedLine),
        paused ? findsOneWidget : findsNothing,
      );
      if (notes) {
        refreshFocus = true;
        container.invalidate(activeExamFocusProvider);
        await tester.pump();
        expect(container.read(proForActiveExamProvider).isLoading, isTrue);
        await tester.pump();
        expect(find.text('Paid wrong-choice note'), findsNothing);
        pendingFocus
            .complete(ActiveExamFocus.selected(buildExam(id: 'exam_cse_pro')));
        for (var i = 0;
            i < 80 &&
                container
                        .read(proForActiveExamProvider)
                        .unwrapPrevious()
                        .asData
                        ?.value !=
                    true;
            i++) {
          await tester.pump(const Duration(milliseconds: 20));
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 2)),
          );
        }
        expect(
          container
              .read(proForActiveExamProvider)
              .unwrapPrevious()
              .asData
              ?.value,
          isTrue,
        );
        await tester.pumpAndSettle();
        expect(find.text('Paid wrong-choice note'), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

class _Running extends QuizController {
  _Running(super.ref, this.value);
  final QuizRunning value;
  @override
  QuizControllerState get state => value;
}
