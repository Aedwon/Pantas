import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/presentation/quiz_review_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

Future<Attempt> seedAttempt(AppDatabase db, ContentDatabase content) async {
  await seedContentExam(content, examId: 'exam_cse_pro');
  await seedContentSubject(content, subjectId: 's', examId: 'exam_cse_pro');
  await seedContentTopic(content, topicId: 't', subjectId: 's');
  await seedContentQuestion(
    content,
    questionId: 'q',
    topicId: 't',
    examId: 'exam_cse_pro',
    stem: 'Original question',
  );
  final attempt = Attempt(
    id: 'a',
    examId: 'exam_cse_pro',
    startedAt: DateTime.utc(2026),
    completedAt: DateTime.utc(2026, 1, 2),
    items: const [
      AttemptItem(
        questionId: 'q',
        questionVersion: 1,
        chosenChoiceId: 'q_b',
        correctChoiceId: 'q_a',
        responseMs: 12,
      ),
    ],
  );
  await AttemptsRepository(db).save(attempt);
  await SyncActiveContextStore(db).clearStable();
  return attempt;
}

Future<void> waitForReview(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 80 && !ready(); i++) {
    await tester.pump(const Duration(milliseconds: 20));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2)));
  }
  expect(
    ready(),
    isTrue,
    reason: tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .join(' | '),
  );
}

void main() {
  for (final change in ['account', 'exam', 'Pro', 'pending auth']) {
    testWidgets(
        'actual viewer $change transition rolls back pending note '
        'and recorder tail', (tester) async {
      final db = inMemoryDatabase();
      final content = inMemoryContentDatabase();
      final attempt = (await tester.runAsync(() => seedAttempt(db, content)))!;
      final auth = StateProvider<AuthState>(
        (_) => const AuthState.anonymous(uid: 'first'),
      );
      final exam = StateProvider<String>((_) => 'exam_cse_pro');
      final pro = StateProvider<bool>((_) => true);
      final pendingAuth = StateProvider<bool>((_) => false);
      late ProviderContainer container;
      final writeSettled = Completer<void>();
      final recorder = _AfterRecorder(db, () async {
        switch (change) {
          case 'account':
            container.read(auth.notifier).state =
                const AuthState.anonymous(uid: 'second');
            await container.read(authStateProvider.future);
          case 'exam':
            container.read(exam.notifier).state = 'exam_upcat';
            await container.read(activeExamFocusProvider.future);
          case 'pending auth':
            container.read(pendingAuth.notifier).state = true;
            container.read(authStateProvider);
          case 'Pro':
            container.read(pro.notifier).state = false;
            await container.read(entitlementProvider.future);
        }
      });
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          devProOverrideProvider.overrideWithValue(null),
          authStateProvider.overrideWith(
            (ref) => ref.watch(pendingAuth)
                ? const Stream<AuthState>.empty()
                : Stream.value(ref.watch(auth)),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async =>
                ActiveExamFocus.selected(buildExam(id: ref.watch(exam))),
          ),
          entitlementProvider.overrideWith(
            (ref) => Stream.value(
              ref.watch(pro)
                  ? Entitlement(
                      plan: EntitlementPlan.monthly,
                      productId: 'pantas_cs_monthly',
                      expiresAt: DateTime.utc(2030),
                    )
                  : const Entitlement.free(),
            ),
          ),
          attemptsRepositoryProvider.overrideWithValue(
            _ObservedAttempts(db, recorder, writeSettled),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();

        await db.close();

        await content.close();
      });
      await tester.runAsync(() async {
        await container.read(authStateProvider.future);
        await container.read(activeExamFocusProvider.future);
        expect(await container.read(proForActiveExamProvider.future), isTrue);
      });
      final revision = (await db
              .customSelect('select revision from sync_local_mutations')
              .getSingle())
          .read<int>('revision');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const QuizReviewPage(attemptId: 'a'),
          ),
        ),
      );
      await waitForReview(
        tester,
        () =>
            find.byTooltip('Add Note').evaluate().isNotEmpty ||
            find.text('Could not load your questions.').evaluate().isNotEmpty,
      );

      expect(find.byTooltip('Add Note'), findsOneWidget);
      await tester.tap(find.byTooltip('Add Note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I misread it'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Note'));

      await tester.pumpAndSettle();

      await waitForReview(tester, () => writeSettled.isCompleted);

      if (change == 'Pro' || change == 'exam') {
        await waitForReview(
          tester,
          () => container.read(proForActiveExamProvider).asData != null,
        );
      }
      await tester.runAsync(() async {
        expect(await AttemptsRepository(db).byId('a'), attempt);

        expect(
          (await db
                  .customSelect('select revision from sync_local_mutations')
                  .getSingle())
              .read<int>('revision'),
          revision,
        );
      });
      expect(find.byTooltip('Edit Note'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
      'actual anonymous wipe during hydration cannot publish or rebind retry',
      (tester) async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    await tester.runAsync(() => seedAttempt(db, content));
    final entered = Completer<void>();
    final release = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        contentRepositoryProvider
            .overrideWithValue(_DelayedContent(content, entered, release)),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'same')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'exam_cse_pro')),
        ),
        proForActiveExamProvider.overrideWith((_) async => true),
        entitlementProvider
            .overrideWith((_) => Stream.value(const Entitlement.free())),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      await content.close();
    });
    await container.read(authStateProvider.future);
    await container.read(activeExamFocusProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const QuizReviewPage(attemptId: 'a'),
        ),
      ),
    );
    await tester.pump();
    await waitForReview(tester, () => entered.isCompleted);
    await entered.future;
    await SyncLocalStateWiper(db).wipeAll();
    release.complete();
    await waitForReview(
      tester,
      () => find.text('Could not load your questions.').evaluate().isNotEmpty,
    );
    await tester.pumpAndSettle();
    expect(find.text('Original question'), findsNothing);
    expect(find.text('Could not load your questions.'), findsOneWidget);
    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    await SyncActiveContextStore(db).clearStable();
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Original question'), findsNothing);
    expect(find.byTooltip('Add Note'), findsNothing);
    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('viewer rejects a different stored core owner', (tester) async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    await tester.runAsync(() async {
      await seedAttempt(db, content);
      await SyncActiveContextStore(db)
          .publishStable(uid: 'other-owner', generationId: 'g');
    });
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        authStateProvider.overrideWith(
          (_) => Stream.value(const AuthState.anonymous(uid: 'first')),
        ),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'exam_cse_pro')),
        ),
        proForActiveExamProvider.overrideWith((_) async => false),
        entitlementProvider
            .overrideWith((_) => Stream.value(const Entitlement.free())),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      await content.close();
    });
    await tester.runAsync(() async {
      await container.read(authStateProvider.future);
      await container.read(activeExamFocusProvider.future);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const QuizReviewPage(attemptId: 'a'),
        ),
      ),
    );
    await waitForReview(
      tester,
      () =>
          find.text('Original question').evaluate().isNotEmpty ||
          find.text('Could not load your questions.').evaluate().isNotEmpty,
    );
    expect(find.text('Could not load your questions.'), findsOneWidget);
    expect(find.text('Original question'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('a fresh account viewer cannot reuse another view cache',
      (tester) async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    await tester.runAsync(() async {
      await seedAttempt(db, content);
      await SyncActiveContextStore(db)
          .publishStable(uid: 'first', generationId: 'g1');
    });
    final auth = StateProvider<AuthState>(
      (_) => const AuthState.anonymous(uid: 'first'),
    );
    final showSecond = StateProvider<bool>((_) => false);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        authStateProvider.overrideWith((ref) => Stream.value(ref.watch(auth))),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'exam_cse_pro')),
        ),
        proForActiveExamProvider.overrideWith((_) async => false),
        entitlementProvider
            .overrideWith((_) => Stream.value(const Entitlement.free())),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      await content.close();
    });
    await tester.runAsync(() async {
      await container.read(authStateProvider.future);
      await container.read(activeExamFocusProvider.future);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLightTheme(),
          home: Consumer(
            builder: (context, ref, _) {
              final second = ref.watch(showSecond);
              return Stack(
                children: [
                  Offstage(
                    offstage: second,
                    child: const QuizReviewPage(
                      key: ValueKey('first-view'),
                      attemptId: 'a',
                    ),
                  ),
                  if (second)
                    const QuizReviewPage(
                      key: ValueKey('second-view'),
                      attemptId: 'a',
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await waitForReview(
      tester,
      () => find.text('Original question').evaluate().isNotEmpty,
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      container.read(auth.notifier).state =
          const AuthState.anonymous(uid: 'second');
      await container.read(authStateProvider.future);
      await SyncLocalStateWiper(db).wipeAll();
      await SyncActiveContextStore(db)
          .publishStable(uid: 'second', generationId: 'g2');
      expect(await db.select(db.attemptsLocal).get(), isEmpty);
    });
    container.read(showSecond.notifier).state = true;
    await tester.pump();
    await waitForReview(
      tester,
      () =>
          find.text('Original question').evaluate().isNotEmpty ||
          find.text('Could not load your questions.').evaluate().isNotEmpty,
    );
    expect(find.text('Could not load your questions.'), findsOneWidget);
    expect(find.text('Original question'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

class _AfterRecorder extends LocalSyncMutationRecorder {
  _AfterRecorder(super.db, this.after)
      : super(
          activeContextStore: SyncActiveContextStore(db),
          rowMetaRepository: SyncRowMetaRepository(db),
        );
  final Future<void> Function() after;
  @override
  Future<T> runRecorded<T>({
    required String collection,
    required String rowId,
    required SyncLocalMutationOp op,
    required FutureOr<T> Function() mutate,
  }) async {
    final result = await super.runRecorded<T>(
      collection: collection,
      rowId: rowId,
      op: op,
      mutate: mutate,
    );
    await after();
    return result;
  }
}

class _DelayedContent extends ContentRepository {
  _DelayedContent(super.db, this.entered, this.release);
  final Completer<void> entered;
  final Completer<void> release;
  @override
  Future<Map<String, Question>> questionsByIds(Iterable<String> ids) async {
    if (!entered.isCompleted) {
      entered.complete();
      await release.future;
    }
    return super.questionsByIds(ids);
  }
}

class _ObservedAttempts extends AttemptsRepository {
  _ObservedAttempts(super.db, LocalSyncMutationRecorder recorder, this.settled)
      : super(syncRecorder: recorder);
  final Completer<void> settled;
  @override
  Future<void> tagItem({
    required String attemptId,
    required String questionId,
    required MistakeTag? tag,
    String? note,
    bool replaceNote = false,
    FutureOr<bool> Function()? canPersist,
  }) async {
    try {
      await super.tagItem(
        attemptId: attemptId,
        questionId: questionId,
        tag: tag,
        note: note,
        replaceNote: replaceNote,
        canPersist: canPersist,
      );
    } finally {
      if (!settled.isCompleted) settled.complete();
    }
  }
}
