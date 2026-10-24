import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/review_providers.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _BlockedContent extends ContentRepository {
  _BlockedContent(super.db);
  bool blocked = false;
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<Map<String, Question>> questionsByIds(Iterable<String> ids) async {
    if (blocked) {
      if (!entered.isCompleted) entered.complete();
      await release.future;
    }
    return super.questionsByIds(ids);
  }
}

void main() {
  testWidgets(
      'flagged UI cannot bind its pending membership to a post-wipe owner',
      (tester) async {
    final db = inMemoryDatabase();
    final contentDb = inMemoryContentDatabase();
    final content = _BlockedContent(contentDb);
    await tester.runAsync(() async {
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'e',
        subjectId: 's',
        topicId: 't',
        topicName: 'Topic',
        questionIds: ['q'],
      );
      await QuestionFlagsRepository(db).flag('q');
      await SyncActiveContextStore(db).clearStable();
    });
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentRepositoryProvider.overrideWithValue(content),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'same')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
      ],
    );
    await tester.runAsync(() async {
      await container.read(authStateProvider.future);
      await container.read(activeExamFocusProvider.future);
      await container.read(flaggedExamReviewProvider('e').future);
    });
    final router = GoRouter(
      initialLocation: '/flags',
      routes: [
        GoRoute(
          path: '/flags',
          builder: (_, __) => const FlaggedListPage(examId: 'e'),
        ),
        GoRoute(
          path: '/quiz/practice/e/run',
          builder: (_, __) => const Scaffold(body: Text('Run opened')),
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
        i < 80 && find.text('Practice these 1').evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 20));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2)),
      );
    }
    expect(find.text('Practice these 1'), findsOneWidget);
    content.blocked = true;
    container.invalidate(flaggedExamReviewProvider('e'));
    for (var i = 0; i < 80 && !content.entered.isCompleted; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2)),
      );
    }
    expect(content.entered.isCompleted, isTrue);
    await tester.tap(find.text('Practice these 1'));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2)),
      );
    }
    await tester.runAsync(() => SyncLocalStateWiper(db).wipeAll());
    content.release.complete();
    for (var i = 0;
        i < 80 &&
            container.read(quizControllerProvider) is! QuizRunning &&
            find.text('Could not start your quiz.').evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 20));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2)),
      );
    }
    final rows = await tester.runAsync(() => db.select(db.quizSessions).get());
    expect(rows, isEmpty);
    expect(find.text('Run opened'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    router.dispose();
    container.dispose();
    await tester.runAsync(() async {
      await db.close();
      await contentDb.close();
    });
  });
}
