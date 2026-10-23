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
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';
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
  Future<List<Question>> questionsByTopic(String topicId) async {
    if (blocked) {
      if (!entered.isCompleted) entered.complete();
      await release.future;
    }
    return super.questionsByTopic(topicId);
  }

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
  for (final custom in [false, true]) {
    testWidgets('page disposal cancels actual pending launch custom=$custom',
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
          lessonIds: ['a'],
          questionLessonMap: {'q': 'a'},
        );
        await QuestionFlagsRepository(db).flag('q');
        await SyncActiveContextStore(db).clearStable();
      });
      final container = ProviderContainer(
        overrides: [
          practiceIndexProvider('e').overrideWith(
            (_) async => const PracticeIndex([
              PracticeSubjectEntry(
                id: 's',
                name: 'Subject',
                topics: [
                  PracticeTopicEntry(
                    id: 't',
                    name: 'Topic',
                    questionCount: 1,
                    lessons: [
                      PracticeLessonEntry(
                        id: 'a',
                        title: 'Lesson',
                        isRead: true,
                        questionCount: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ]),
          ),
          practicePaceProvider('e').overrideWith((_) async => null),
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
            builder: (_, __) => custom
                ? const PracticePickerScreen(examId: 'e')
                : const FlaggedListPage(examId: 'e'),
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
          i < 80 &&
              find
                  .text(custom ? 'Start' : 'Practice these 1')
                  .evaluate()
                  .isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 20));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 2)),
        );
      }
      if (custom) {
        await tester.tap(find.byKey(const ValueKey('scope-select-t')));
        await tester.pumpAndSettle();
      }
      content.blocked = true;
      await tester.tap(find.text(custom ? 'Start' : 'Practice these 1'));
      for (var i = 0; i < 80 && !content.entered.isCompleted; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 2)),
        );
      }
      expect(content.entered.isCompleted, isTrue);
      // Remove only the page. The real app container and controller stay alive.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => QuizSessionRepository(db).create(
          sessionId: 'newer-paused',
          userId: 'local',
          examId: 'e',
          origin: SessionOrigin.drill,
          questionIds: ['q'],
          startedAt: DateTime.utc(2026),
        ),
      );
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
      final rows =
          await tester.runAsync(() => db.select(db.quizSessions).get());
      expect(rows, hasLength(1));
      expect(rows!.single.id, 'newer-paused');
      expect(rows.single.quitAt, isNull);
      expect(container.read(quizControllerProvider), isNot(isA<QuizRunning>()));
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
}
