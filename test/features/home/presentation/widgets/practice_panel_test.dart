import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/components/inline_meter.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';
import 'package:pantas/features/home/application/performance/topic_accuracy_provider.dart';
import 'package:pantas/features/home/presentation/widgets/practice_panel.dart';
import 'package:pantas/features/quiz/application/quiz_preparation_stamp.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';

import '../../../../helpers/in_memory_database.dart';

class RecordingTodayQuizPreparer extends TodayQuizPreparer {
  RecordingTodayQuizPreparer()
      : super(
          readStamp: (_) => throw UnimplementedError(),
          buildPlan: (_) => throw UnimplementedError(),
          now: DateTime.now,
        );

  final calls = <QuizPreparationRequest>[];
  final _pending = Completer<PreparedTodaySession>();
  PreparedTodaySession? resultToReturn;

  @override
  Future<PreparedTodaySession> prepare(QuizPreparationRequest request) {
    calls.add(request);
    final result = resultToReturn;
    return result == null ? _pending.future : Future.value(result);
  }
}

void main() {
  late AppDatabase db;
  late RecordingTodayQuizPreparer fakePreparer;

  setUp(() {
    db = inMemoryDatabase();
    fakePreparer = RecordingTodayQuizPreparer();
  });

  tearDown(() async {
    await db.close();
  });

  Widget harness(
    List<TopicAccuracy> topics, {
    Future<List<TopicAccuracy>> Function()? loadTopics,
  }) {
    const exam = Exam(
      id: 'upcat',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
      language: 'en',
      isActive: true,
      subjects: [],
    );
    return ProviderScope(
      key: UniqueKey(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activeExamFocusProvider.overrideWith(
          (ref) async => const ActiveExamFocus.selected(exam),
        ),
        topicAccuracyProvider.overrideWith(
          (ref) => loadTopics?.call() ?? Future.value(topics),
        ),
        todayQuizPreparerProvider.overrideWithValue(fakePreparer),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: [AppColors.light, AppTextStyles.create()],
        ),
        home: const Scaffold(
          body: PracticePanel(),
        ),
      ),
    );
  }

  const threeTopics = [
    TopicAccuracy(
      topicId: 'chem',
      topicName: 'Chemistry',
      correct: 3,
      answered: 10,
    ),
    TopicAccuracy(
      topicId: 'alg',
      topicName: 'Algebra',
      correct: 6,
      answered: 10,
    ),
    TopicAccuracy(
      topicId: 'geo',
      topicName: 'Geometry',
      correct: 9,
      answered: 10,
    ),
  ];

  testWidgets('draws three rows, weakest first, with severity colour',
      (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();

    expect(find.text('30%'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);

    final meters = tester.widgetList<InlineMeter>(find.byType(InlineMeter));
    expect(
      meters.map((m) => m.color),
      [AppColors.light.rust, AppColors.light.amber, AppColors.light.ink],
    );
  });

  testWidgets('the boundaries land on the right side', (tester) async {
    // 49% rust, 50% amber, 69% amber, 70% ink.
    await tester.pumpWidget(
      harness(const [
        TopicAccuracy(
          topicId: 't1',
          topicName: 'T1',
          correct: 49,
          answered: 100,
        ),
        TopicAccuracy(
          topicId: 't2',
          topicName: 'T2',
          correct: 50,
          answered: 100,
        ),
        TopicAccuracy(
          topicId: 't3',
          topicName: 'T3',
          correct: 69,
          answered: 100,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    final meters1 =
        tester.widgetList<InlineMeter>(find.byType(InlineMeter)).toList();
    expect(meters1[0].color, AppColors.light.rust);
    expect(meters1[1].color, AppColors.light.amber);
    expect(meters1[2].color, AppColors.light.amber);

    await tester.pumpWidget(
      harness(const [
        TopicAccuracy(
          topicId: 't4',
          topicName: 'T4',
          correct: 70,
          answered: 100,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    final meters2 =
        tester.widgetList<InlineMeter>(find.byType(InlineMeter)).toList();
    expect(meters2[0].color, AppColors.light.ink);
  });

  testWidgets('below the floor: ranked, tappable, and no figure at all',
      (tester) async {
    await tester.pumpWidget(
      harness(const [
        TopicAccuracy(
          topicId: 'chem',
          topicName: 'Chemistry',
          correct: 0,
          answered: 1,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chemistry'), findsOneWidget);
    expect(find.byType(InlineMeter), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('0'), findsNothing);
  });

  testWidgets('every row carries a chevron', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    expect(find.byType(InkChevron), findsNWidgets(3));
  });

  testWidgets('every practice row has a 48dp hit region', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();

    for (final topic in ['Chemistry', 'Algebra', 'Geometry']) {
      final row = find.ancestor(
        of: find.text(topic),
        matching: find.byType(InkWell),
      );
      expect(row, findsOneWidget);
      expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('loading exposes one quiet status', (tester) async {
    final completer = Completer<List<TopicAccuracy>>();
    await tester.pumpWidget(
      harness(const [], loadTopics: () => completer.future),
    );
    await tester.pump();

    final status = find.bySemanticsLabel('Loading practice topics');
    expect(status, findsOneWidget);
    expect(
      tester.getSemantics(status).flagsCollection.isLiveRegion,
      isFalse,
    );
  });

  testWidgets('no lead line promises a session length', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ten questions'), findsNothing);
    expect(find.textContaining('questions on whichever'), findsNothing);
  });

  testWidgets(
      'tapping a row prepares the canonical topic without '
      'pre-route persistence', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chemistry'));
    await tester.pump();

    final request = fakePreparer.calls.single;
    expect(request.userId, quizLocalUserId);
    expect(request.examId, 'upcat');
    expect(request.topicId, 'chem');
  });

  testWidgets('no board green in this panel except the header action',
      (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();

    final board = AppColors.light.board;
    for (final meter in tester.widgetList<InlineMeter>(
      find.byType(InlineMeter),
    )) {
      expect(meter.color, isNot(board));
    }
  });

  testWidgets('the plate reads Practice and the action reads See all',
      (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(find.text('Weakest areas'), findsNothing);
    expect(find.text('Practice these'), findsNothing);
  });

  testWidgets('no topics at all renders no panel', (tester) async {
    await tester.pumpWidget(harness(const []));
    await tester.pumpAndSettle();
    expect(find.byType(RuledPanel), findsNothing);
  });
  testWidgets('Home passes the exact prepared object to the Today route',
      (tester) async {
    const question = Question(
      id: 'q-chem',
      version: 1,
      examIds: ['upcat'],
      topicId: 'chem',
      language: 'en',
      stem: 'Chemistry question',
      choices: [
        Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'Because.',
    );
    final prepared = PreparedTodaySession(
      plan: const TodaySessionPlan(
        questions: [question],
        dueCount: 1,
        weaknessCount: 0,
        freshCount: 0,
        topicId: 'chem',
        topicName: 'Chemistry',
      ),
      stamp: QuizPreparationStamp(
        contentRevision: 'content-1',
        accountLifetimeToken: 'local',
        examId: 'upcat',
        topicId: 'chem',
        scopeToken: 'chem',
        topicExclusionToken: '',
        ordering: SessionOrdering.interleavedTail,
        sessionLength: 10,
        roadmapToken: 'day|digest|0',
        historyRevision: 'history-1',
        sessionStateRevision: 'session-1',
        localDay: DateTime(2026, 9, 9),
        nextDueExpiry: null,
      ),
      preparedAt: DateTime(2026, 9, 9, 10),
    );
    fakePreparer.resultToReturn = prepared;
    Object? routeExtra;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: PracticePanel()),
        ),
        GoRoute(
          path: '/quiz/today/:examId',
          builder: (context, state) {
            routeExtra = state.extra;
            return const Scaffold(body: Text('Today destination'));
          },
        ),
      ],
    );
    const exam = Exam(
      id: 'upcat',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
      language: 'en',
      isActive: true,
      subjects: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(exam),
          ),
          topicAccuracyProvider
              .overrideWith((ref) => Future.value(threeTopics)),
          todayQuizPreparerProvider.overrideWithValue(fakePreparer),
        ],
        child: MaterialApp.router(
          theme: ThemeData(
            useMaterial3: true,
            extensions: [AppColors.light, AppTextStyles.create()],
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chemistry'));
    await tester.pumpAndSettle();

    expect(find.text('Today destination'), findsOneWidget);
    expect(identical(routeExtra, prepared), isTrue);
  });
}
