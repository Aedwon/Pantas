import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:pantas/features/quiz/application/session_debrief_provider.dart';
import 'package:pantas/features/quiz/data/session_diagnosis_api.dart';
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
  testWidgets('Free diagnosis survives a completed plan on the session page',
      (tester) async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    final gateway = _Gateway();
    final attempt = Attempt(
      id: 'a',
      examId: 'e',
      origin: 'flagged',
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
      await SyncActiveContextStore(db).clearStable();
    });

    final container = ProviderContainer(
      overrides: [
        sessionDebriefPlanProvider.overrideWith(
          (_, __) async => const DebriefPlanData(lessonTitles: {}),
        ),
        sessionDiagnosisProvider.overrideWith(
          (_, __) async => SessionDiagnosisData.decode({
            'status': 'ok',
            'tier': 'free',
            'tracedCount': 3,
          }),
        ),
        sessionDebriefClaimProvider.overrideWith((_, __) async => true),
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
      initialLocation: '/end',
      routes: [
        GoRoute(
          path: '/end',
          builder: (_, __) => const QuizSessionEndPage(
            attemptId: 'a',
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
    for (var i = 0;
        i < 100 && find.text('Session finished.').evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 20));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2)),
      );
    }

    await tester.pumpAndSettle();

    expect(
      find.textContaining('See which', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('NEXT'), findsNothing);
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
