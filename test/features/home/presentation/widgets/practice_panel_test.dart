import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_chevron.dart';
import 'package:cse_cet_reviewer/core/ui/components/inline_meter.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_text_styles.dart';
import 'package:cse_cet_reviewer/features/home/application/topic_accuracy_provider.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/practice_panel.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_today_session.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

class StartTodaySessionCall {
  const StartTodaySessionCall({
    required this.userId,
    required this.examId,
    this.topicId,
  });
  final String userId;
  final String examId;
  final String? topicId;
}

class FakeStartTodaySession implements StartTodaySession {
  final calls = <StartTodaySessionCall>[];
  StartTodaySessionResult resultToReturn =
      const StartTodaySessionNoQuestions('No questions');

  @override
  Future<StartTodaySessionResult> call({
    required String userId,
    required String examId,
    required DateTime now,
    String? topicId,
    dynamic preferences,
    dynamic plan,
  }) async {
    calls.add(
      StartTodaySessionCall(
        userId: userId,
        examId: examId,
        topicId: topicId,
      ),
    );
    return resultToReturn;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late FakeStartTodaySession fakeStartToday;

  setUp(() {
    db = inMemoryDatabase();
    fakeStartToday = FakeStartTodaySession();
  });

  tearDown(() async {
    await db.close();
  });

  Widget harness(List<TopicAccuracy> topics) {
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
        topicAccuracyProvider.overrideWith((ref) async => topics),
        startTodaySessionProvider.overrideWithValue(fakeStartToday),
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

  testWidgets('no lead line promises a session length', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ten questions'), findsNothing);
    expect(find.textContaining('questions on whichever'), findsNothing);
  });

  testWidgets('tapping a row starts a session on that topic', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chemistry'));
    await tester.pumpAndSettle();

    expect(fakeStartToday.calls.single.topicId, 'chem');
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
}
