import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/review_providers.dart';

import '../../../../helpers/pump_app.dart';

class _MockContentRepo extends Mock implements ContentRepository {}

class _MockFlagsRepo extends Mock implements QuestionFlagsRepository {}

class _MockPrefsRepo extends Mock implements AppPreferencesRepository {}

class _RecordingController extends QuizController {
  _RecordingController(super.ref, this.pool);
  final List<Question> pool;
  int calls = 0;
  List<String>? requestedIds;
  SessionOrigin? requestedOrigin;
  bool fail = false;
  @override
  Future<Future<bool> Function()> captureLaunchGuard({
    required String examId,
  }) async =>
      () async => true;

  @override
  Future<void> startPracticeFromQuestionIds({
    required String examId,
    required List<String> questionIds,
    SessionOrigin origin = SessionOrigin.drill,
    Future<bool> Function()? canPersist,
  }) async {
    calls++;
    requestedIds = questionIds;
    requestedOrigin = origin;
    state = fail
        ? const QuizFailure('private diagnostic')
        : QuizRunning(
            persisted: true,
            session: QuizSession.start(
              sessionId: 'started',
              examId: examId,
              questions: [
                for (final id in questionIds)
                  pool.firstWhere((q) => q.id == id),
              ],
              startedAt: DateTime.utc(2026),
              origin: origin,
            ),
          );
  }
}

void main() {
  const q1 = Question(
    id: 'q_1',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 't_1',
    language: 'en',
    stem: 'Flagged Q1 Stem',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: true),
    ],
    explanation: 'Exp 1',
  );

  const q2 = Question(
    id: 'q_2',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 't_1',
    language: 'en',
    stem: 'Flagged Q2 Stem',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: true),
    ],
    explanation: 'Exp 2',
  );

  const q3 = Question(
    id: 'q_3',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 't_2',
    language: 'en',
    stem: 'Flagged Q3 Stem',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: true),
    ],
    explanation: 'Exp 3',
  );

  const foreign = Question(
    id: 'foreign',
    version: 1,
    examIds: ['other'],
    topicId: 'other_topic',
    language: 'en',
    stem: 'Foreign exam question',
    explanation: 'Other',
    choices: [Choice(id: 'a', label: 'A', text: 'A', isCorrect: true)],
  );

  const t1 =
      Topic(id: 't_1', subjectId: 's_1', name: 'Mathematics', ordering: 1);
  const t2 = Topic(id: 't_2', subjectId: 's_2', name: 'Science', ordering: 2);
  const s1 =
      Subject(id: 's_1', examId: 'cse_prof', name: 'Mathematics', ordering: 1);
  const s2 =
      Subject(id: 's_2', examId: 'cse_prof', name: 'Science', ordering: 2);

  late _MockContentRepo contentRepo;
  late _MockFlagsRepo flagsRepo;
  late _MockPrefsRepo prefsRepo;

  setUp(() {
    contentRepo = _MockContentRepo();
    flagsRepo = _MockFlagsRepo();
    prefsRepo = _MockPrefsRepo();

    when(() => prefsRepo.hasAnnouncedFirstFlag()).thenAnswer((_) async => true);
    when(() => flagsRepo.flaggedIds()).thenAnswer(
      (_) async => (await flagsRepo.flagsNewestFirst())
          .map((row) => row.questionId)
          .toSet(),
    );

    // The review reads every question in one query now, not one at a time.
    when(() => contentRepo.questionsByIds(any()))
        .thenAnswer((invocation) async {
      final wanted =
          (invocation.positionalArguments.first as Iterable<String>).toSet();
      return {
        for (final q in [q1, q2, q3, foreign])
          if (wanted.contains(q.id)) q.id: q,
      };
    });

    when(() => contentRepo.topicById('other_topic')).thenAnswer(
      (_) async => const Topic(
        id: 'other_topic',
        subjectId: 'other_subject',
        name: 'Other topic',
        ordering: 1,
      ),
    );
    when(() => contentRepo.subjectById('other_subject')).thenAnswer(
      (_) async => const Subject(
        id: 'other_subject',
        examId: 'other',
        name: 'Other exam',
        ordering: 1,
      ),
    );

    when(() => contentRepo.topicById('t_1')).thenAnswer((_) async => t1);
    when(() => contentRepo.topicById('t_2')).thenAnswer((_) async => t2);

    when(() => contentRepo.subjectById('s_1')).thenAnswer((_) async => s1);
    when(() => contentRepo.subjectById('s_2')).thenAnswer((_) async => s2);

    when(() => flagsRepo.flagsNewestFirst()).thenAnswer(
      (_) async => [
        QuestionFlagLocalRow(
          questionId: 'q_1',
          flaggedAt: DateTime.utc(2026, 5, 9),
          syncState: 'pending',
        ),
        QuestionFlagLocalRow(
          questionId: 'q_2',
          flaggedAt: DateTime.utc(2026, 5, 8),
          syncState: 'pending',
        ),
        QuestionFlagLocalRow(
          questionId: 'q_3',
          flaggedAt: DateTime.utc(2026, 5, 7),
          syncState: 'pending',
        ),
        QuestionFlagLocalRow(
          questionId: 'foreign',
          flaggedAt: DateTime.utc(2026, 5, 6),
          syncState: 'pending',
        ),
      ],
    );
  });

  testWidgets('the flagged list groups by subject', (tester) async {
    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
        scopedTopicsProvider('cse_prof').overrideWith((_) async => [t1, t2]),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('MATHEMATICS'), findsOneWidget);
    expect(find.text('SCIENCE'), findsOneWidget);
    expect(find.text('Foreign exam question'), findsNothing);
    expect(find.text('Other exam'), findsNothing);
  });

  testWidgets('it has no filter row', (tester) async {
    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
        scopedTopicsProvider('cse_prof').overrideWith((_) async => [t1, t2]),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Wrong'), findsNothing);
  });

  testWidgets('the button counts what is in the list', (tester) async {
    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
        scopedTopicsProvider('cse_prof').overrideWith((_) async => [t1, t2]),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Practice these 3'), findsOneWidget);
  });

  testWidgets('unflagging updates the count as it happens', (tester) async {
    when(() => flagsRepo.isFlagged('q_1')).thenAnswer((_) async => true);

    // The list starts at three and drops to two only once the unflag has
    // happened. Stubbing the second state before pumping would assert the
    // starting count against a repository that never had three in it.
    when(() => flagsRepo.unflag('q_1')).thenAnswer((_) async {
      when(() => flagsRepo.flagsNewestFirst()).thenAnswer(
        (_) async => [
          QuestionFlagLocalRow(
            questionId: 'q_2',
            flaggedAt: DateTime.utc(2026, 5, 8),
            syncState: 'pending',
          ),
          QuestionFlagLocalRow(
            questionId: 'q_3',
            flaggedAt: DateTime.utc(2026, 5, 7),
            syncState: 'pending',
          ),
          QuestionFlagLocalRow(
            questionId: 'foreign',
            flaggedAt: DateTime.utc(2026, 5, 6),
            syncState: 'pending',
          ),
        ],
      );
    });

    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
        scopedTopicsProvider('cse_prof').overrideWith((_) async => [t1, t2]),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Practice these 3'), findsOneWidget);

    await tester.tap(find.byType(PennantMark).first);
    await tester.pumpAndSettle();

    expect(find.text('Practice these 2'), findsOneWidget);
  });

  testWidgets('emptying the list says what to do', (tester) async {
    when(() => flagsRepo.flagsNewestFirst()).thenAnswer((_) async => []);

    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
        scopedTopicsProvider('cse_prof').overrideWith((_) async => [t1, t2]),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Flag anything you want to come back to'),
      findsOneWidget,
    );
    expect(find.textContaining('Practice these'), findsNothing);
  });

  Future<void> routed(
    WidgetTester tester, {
    bool practice = false,
    bool fail = false,
  }) async {
    _RecordingController? controller;
    final router = GoRouter(
      initialLocation: '/quiz/flagged/cse_prof',
      routes: [
        GoRoute(
          path: '/quiz/flagged/:examId',
          builder: (_, __) => const FlaggedListPage(examId: 'cse_prof'),
        ),
        GoRoute(
          path: '/quiz/flagged/:examId/view/:questionId',
          builder: (_, state) => Scaffold(
            body: Text('Viewer ${state.pathParameters['questionId']}'),
          ),
        ),
        GoRoute(
          path: '/quiz/practice/:examId/run',
          builder: (_, __) =>
              const Scaffold(body: Text('Declared flagged run')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        scopedTopicsProvider('cse_prof').overrideWith((_) async => [t1, t2]),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
        quizControllerProvider.overrideWith(
          (ref) =>
              controller = _RecordingController(ref, [q1, q2, q3])..fail = fail,
        ),
      ],
    );
    await tester.pumpAndSettle();
    if (!practice) {
      await tester.tap(find.text('Flagged Q1 Stem'));
      await tester.pumpAndSettle();
      expect(find.text('Viewer q_1'), findsOneWidget);
    } else {
      await tester.ensureVisible(find.text('Practice these 3'));
      await tester.tap(find.text('Practice these 3'));
      await tester.pumpAndSettle();
      if (fail) {
        expect(find.text('Declared flagged run'), findsNothing);
        expect(find.text('Could not start your quiz.'), findsOneWidget);
        expect(find.textContaining('private diagnostic'), findsNothing);
      } else {
        expect(find.text('Declared flagged run'), findsOneWidget);
        expect(controller!.requestedIds, ['q_1', 'q_2', 'q_3']);
        expect(controller!.requestedOrigin, SessionOrigin.flagged);
        expect(controller!.calls, 1);
      }
    }
  }

  testWidgets('a flagged row opens the real question viewer route',
      (tester) async {
    await routed(tester);
  });
  testWidgets('practice uses scoped flags and the declared run route',
      (tester) async {
    await routed(tester, practice: true);
  });
  testWidgets('failed practice stays on the list with plain retry',
      (tester) async {
    await routed(tester, practice: true, fail: true);
  });

  ProviderContainer flaggedContainer({bool narrow = false}) {
    final container = ProviderContainer(
      overrides: [
        scopedTopicsProvider('cse_prof')
            .overrideWith((_) async => narrow ? [t2] : [t1, t2]),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('scoped provider preserves global flags and follows narrowed topics',
      () async {
    final entries = await flaggedContainer(narrow: true)
        .read(flaggedExamReviewProvider('cse_prof').future);
    expect(entries.map((entry) => entry.question.id), ['q_3']);
    expect(entries.single.number, 1);
    expect((await flagsRepo.flagsNewestFirst()).length, 4);
    verifyNever(() => flagsRepo.unflag(any()));
  });

  test('flagged content carries its actual required passage', () async {
    when(() => contentRepo.questionsByIds(any())).thenAnswer(
      (_) async => {
        q1.id: q1,
        q2.id: q2,
        q3.id: q3.copyWith(passageId: 'p'),
        foreign.id: foreign,
      },
    );
    when(() => contentRepo.passageById('p')).thenAnswer(
      (_) async => const Passage(
        id: 'p',
        topicId: 't_2',
        title: 'Actual passage',
        body: 'Passage text',
        language: 'en',
        wordCount: 2,
      ),
    );
    final entries = await flaggedContainer()
        .read(flaggedExamReviewProvider('cse_prof').future);
    expect(entries.last.passage?.id, 'p');
    expect(entries.last.passage?.body, 'Passage text');
  });

  test('missing flagged question never silently shortens membership', () async {
    when(() => contentRepo.questionsByIds(any()))
        .thenAnswer((_) async => {q1.id: q1, q2.id: q2, foreign.id: foreign});
    await expectLater(
      flaggedContainer().read(flaggedExamReviewProvider('cse_prof').future),
      throwsStateError,
    );
  });

  test('missing required flagged passage fails recoverably', () async {
    when(() => contentRepo.questionsByIds(any())).thenAnswer(
      (_) async => {
        q1.id: q1,
        q2.id: q2,
        q3.id: q3.copyWith(passageId: 'p'),
        foreign.id: foreign,
      },
    );
    when(() => contentRepo.passageById('p')).thenAnswer((_) async => null);
    await expectLater(
      flaggedContainer().read(flaggedExamReviewProvider('cse_prof').future),
      throwsStateError,
    );
  });

  testWidgets('flagged load error uses plain shared retry', (tester) async {
    final savedRows = await flagsRepo.flagsNewestFirst();
    when(() => flagsRepo.flagsNewestFirst())
        .thenThrow(StateError('private diagnostic'));
    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
        scopedTopicsProvider('cse_prof').overrideWith((_) async => [t1, t2]),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load your questions.'), findsOneWidget);
    expect(find.textContaining('private diagnostic'), findsNothing);
    expect(find.text('Try Again'), findsOneWidget);
    when(() => flagsRepo.flagsNewestFirst()).thenAnswer((_) async => savedRows);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Practice these 3'), findsOneWidget);
    expect(find.textContaining('private diagnostic'), findsNothing);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('flagged compact phone dark=$dark scale=$scale',
          (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              scopedTopicsProvider('cse_prof')
                  .overrideWith((_) async => [t1, t2]),
              contentRepositoryProvider.overrideWithValue(contentRepo),
              questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
              appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
            ],
            child: MaterialApp(
              theme: dark ? buildDarkTheme() : buildLightTheme(),
              home: MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: const FlaggedListPage(examId: 'cse_prof'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Practice these 3'), findsOneWidget);
        expect(find.text('Foreign exam question'), findsNothing);
        await tester.ensureVisible(find.text('Flagged Q3 Stem'));
        expect(
          tester.getRect(find.text('Flagged Q3 Stem')).bottom,
          lessThanOrEqualTo(
            tester.getRect(find.text('Practice these 3')).top,
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
