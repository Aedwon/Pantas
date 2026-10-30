import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_review_providers.dart';
import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_review_page.dart';

import '../../../helpers/pump_app.dart';

class _MockContentRepo extends Mock implements ContentRepository {}

class _MockAttemptRepo extends Mock implements MockAttemptRepo {}

class _MockFlagsRepo extends Mock implements QuestionFlagsRepository {}

class _MockPrefsRepo extends Mock implements AppPreferencesRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime.utc(2000));
  });

  late _MockContentRepo contentRepo;
  late _MockAttemptRepo attemptRepo;
  late _MockFlagsRepo flagsRepo;
  late _MockPrefsRepo prefsRepo;

  final markedIds = List.generate(12, (i) => 'q_${i + 1}');
  final questions = <String, Question>{};
  for (var i = 0; i < 12; i++) {
    final id = 'q_${i + 1}';
    questions[id] = Question(
      id: id,
      version: 1,
      examIds: const ['cse_prof'],
      topicId: i < 6 ? 't_1' : 't_2',
      language: 'en',
      stem: 'Stem for $id',
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: false),
        Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: true),
      ],
      explanation: 'Explanation $id',
    );
  }

  const t1 =
      Topic(id: 't_1', subjectId: 's_1', name: 'Mathematics', ordering: 1);
  const t2 = Topic(id: 't_2', subjectId: 's_2', name: 'Science', ordering: 2);
  const s1 =
      Subject(id: 's_1', examId: 'cse_prof', name: 'Mathematics', ordering: 1);
  const s2 =
      Subject(id: 's_2', examId: 'cse_prof', name: 'Science', ordering: 2);

  late MockAttempt mockAttempt;
  final prefsStore = <String, String>{};

  setUp(() {
    contentRepo = _MockContentRepo();
    attemptRepo = _MockAttemptRepo();
    flagsRepo = _MockFlagsRepo();
    prefsRepo = _MockPrefsRepo();
    prefsStore.clear();

    mockAttempt = MockAttempt(
      id: 'attempt_1',
      userId: 'user_1',
      examId: 'cse_prof',
      blueprintId: 'bp_1',
      blueprintName: 'UPCAT Full',
      durationMinutes: 180,
      status: MockAttemptStatus.completed,
      strictMode: false,
      sampledQuestionsJson:
          // ignore: missing_whitespace_between_adjacent_strings
          '[{"sectionId":"sec_1","name":"Section 1","questionIds":'
          '${markedIds.map((id) => '"$id"').toList()}}]',
      elapsedSeconds: 3600,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{"q_1":{"selectedIndex":1,"atSec":10}}',
      flagsJson: '[${markedIds.map((id) => '"$id"').join(',')}]',
      currentIndex: 0,
      startedAt: DateTime.utc(2026, 8),
      lastFlushedAt: DateTime.utc(2026, 8),
      updatedAt: DateTime.utc(2026, 8),
      scoreRaw: 1,
      scoreTotal: 12,
      submittedAt: DateTime.utc(2026, 8),
    );

    when(() => attemptRepo.findById('attempt_1'))
        .thenAnswer((_) async => mockAttempt);

    when(() => contentRepo.questionsByIds(any()))
        .thenAnswer((invocation) async {
      final wanted =
          (invocation.positionalArguments.first as Iterable<String>).toSet();
      return {
        for (final entry in questions.entries)
          if (wanted.contains(entry.key)) entry.key: entry.value,
      };
    });

    when(() => contentRepo.topicById('t_1')).thenAnswer((_) async => t1);
    when(() => contentRepo.topicById('t_2')).thenAnswer((_) async => t2);

    when(() => contentRepo.subjectById('s_1')).thenAnswer((_) async => s1);
    when(() => contentRepo.subjectById('s_2')).thenAnswer((_) async => s2);

    when(() => flagsRepo.flaggedIds()).thenAnswer((_) async => <String>{});
    when(() => flagsRepo.flag(any())).thenAnswer((_) async {});
    when(() => flagsRepo.unflag(any())).thenAnswer((_) async {});
    when(() => flagsRepo.isFlagged(any())).thenAnswer((_) async => false);

    when(() => prefsRepo.deviceValue(any())).thenAnswer((invocation) async {
      final key = invocation.positionalArguments.first as String;
      return prefsStore[key];
    });
    when(() => prefsRepo.setDeviceValue(any(), any()))
        .thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      final val = invocation.positionalArguments[1] as String;
      prefsStore[key] = val;
    });
  });

  testWidgets('the offer counts the marks made under the clock',
      (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('while the clock was running'), findsNothing);
    await tester.tap(find.text('Flagged 12'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'You flagged 12 questions while the clock was running. '
        'Do you want to save them?',
      ),
      findsOneWidget,
    );
    expect(find.text('Save All 12'), findsOneWidget);
    expect(find.text('No Thanks'), findsOneWidget);
  });

  testWidgets('taking it flags them all and the offer goes', (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flagged 12'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save All 12'));
    await tester.pumpAndSettle();

    expect(find.text('Save All 12'), findsNothing);
    verify(() => flagsRepo.flag(any())).called(12);
  });

  testWidgets('refusing it also ends it', (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flagged 12'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No Thanks'));
    await tester.pumpAndSettle();

    expect(find.textContaining('while the clock was running'), findsNothing);
  });

  testWidgets('the offer does not come back on a second visit', (tester) async {
    prefsStore['mock_flag_offer_handled_attempt_1'] = 'true';

    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flagged 12'));
    await tester.pumpAndSettle();
    expect(find.textContaining('while the clock was running'), findsNothing);
  });

  testWidgets('an attempt with no marks makes no offer', (tester) async {
    final emptyAttempt = MockAttempt(
      id: 'attempt_no_marks',
      userId: 'user_1',
      examId: 'cse_prof',
      blueprintId: 'bp_1',
      blueprintName: 'UPCAT Full',
      durationMinutes: 180,
      status: MockAttemptStatus.completed,
      strictMode: false,
      sampledQuestionsJson:
          '[{"sectionId":"sec_1","name":"Section 1","questionIds":["q_1"]}]',
      elapsedSeconds: 3600,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{}',
      flagsJson: '[]',
      currentIndex: 0,
      startedAt: DateTime.utc(2026, 8),
      lastFlushedAt: DateTime.utc(2026, 8),
      updatedAt: DateTime.utc(2026, 8),
    );

    when(() => attemptRepo.findById('attempt_no_marks'))
        .thenAnswer((_) async => emptyAttempt);

    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_no_marks', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('while the clock was running'), findsNothing);
  });

  testWidgets('there is no fourth filter', (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Marked'), findsNothing);
  });

  testWidgets('the mock review groups by paper part', (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('All 12'));
    await tester.pumpAndSettle();
    expect(find.text('SECTION 1'), findsOneWidget);
    expect(find.text('Mathematics'), findsNothing);
    expect(find.text('Science'), findsNothing);
  });

  testWidgets('Free sees every question and the answer', (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    // Default filter is Wrong (11 misses out of 12 since only q_1 was correct).
    expect(find.text('Stem for q_1'), findsNothing);
    expect(find.text('Wrong 11'), findsOneWidget);

    await tester.tap(find.text('All 12'));
    await tester.pumpAndSettle();

    expect(find.text('Stem for q_1'), findsOneWidget);
  });

  testWidgets(
      'approved mock review opens Wrong and keeps flag offer on Flagged only',
      (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: true),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Wrong 11'), findsOneWidget);
    expect(find.textContaining('You flagged 12 questions'), findsNothing);
    expect(
      find.textContaining('Tell Pantas why you got each one wrong'),
      findsOneWidget,
    );
    expect(find.text('Finish the Notes'), findsOneWidget);

    await tester.tap(find.text('Flagged 12'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'You flagged 12 questions while the clock was running. '
        'Do you want to save them?',
      ),
      findsOneWidget,
    );
    expect(find.text('No Thanks'), findsOneWidget);
    expect(find.text('Save All 12'), findsOneWidget);
  });

  testWidgets(
      'approved mock review groups rows by paper part, not content subject',
      (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('All 12'));
    await tester.pumpAndSettle();
    expect(find.text('SECTION 1'), findsOneWidget);
    expect(find.text('Mathematics'), findsNothing);
    expect(find.text('Science'), findsNothing);
    expect(find.text('Left blank'), findsWidgets);
  });

  testWidgets('a review row opens a viewer that moves through the current tab',
      (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Left blank').first);
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceRow), findsNWidgets(2));
    expect(find.byType(AnswerReveal), findsOneWidget);
    expect(find.text('1 of 11'), findsOneWidget);
    expect(find.text('All questions'), findsOneWidget);
    expect(find.text('Opt B'), findsOneWidget);
  });

  testWidgets('Free review has no notes affordance', (tester) async {
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: false),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Tell Pantas why you got each one wrong'),
      findsNothing,
    );
    expect(find.text('Finish the Notes'), findsNothing);
  });

  testWidgets('Pro can save why a blank question was left unanswered',
      (tester) async {
    when(
      () => attemptRepo.saveReviewReason(
        attemptId: 'attempt_1',
        questionId: 'q_2',
        savedAt: any(named: 'savedAt'),
        blankReason: BlankReason.didNotKnow,
      ),
    ).thenAnswer((_) async {});

    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: true),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Left blank').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add note'));
    await tester.pumpAndSettle();
    expect(find.text('Why did you leave it blank?'), findsOneWidget);
    await tester.tap(find.text("I didn't know"));
    await tester.pumpAndSettle();

    verify(
      () => attemptRepo.saveReviewReason(
        attemptId: 'attempt_1',
        questionId: 'q_2',
        savedAt: any(named: 'savedAt'),
        blankReason: BlankReason.didNotKnow,
      ),
    ).called(1);
  });

  testWidgets('Pro saves why an answered question was wrong', (tester) async {
    final wrongAttempt = MockAttempt(
      id: 'attempt_1',
      userId: 'user_1',
      examId: 'cse_prof',
      blueprintId: 'bp_1',
      blueprintName: 'UPCAT Full',
      durationMinutes: 180,
      status: MockAttemptStatus.completed,
      strictMode: false,
      sampledQuestionsJson: mockAttempt.sampledQuestionsJson,
      elapsedSeconds: 3600,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: jsonEncode({
        'q_1': {'selectedIndex': 1, 'atSec': 10},
        'q_2': {'selectedIndex': 0, 'atSec': 20},
      }),
      flagsJson: mockAttempt.flagsJson,
      currentIndex: 0,
      startedAt: DateTime.utc(2026, 8),
      lastFlushedAt: DateTime.utc(2026, 8),
      updatedAt: DateTime.utc(2026, 8),
      scoreRaw: 1,
      scoreTotal: 12,
      submittedAt: DateTime.utc(2026, 8),
    );
    when(() => attemptRepo.findById('attempt_1'))
        .thenAnswer((_) async => wrongAttempt);
    when(
      () => attemptRepo.saveReviewReason(
        attemptId: 'attempt_1',
        questionId: 'q_2',
        savedAt: any(named: 'savedAt'),
        missReason: MissReason.misread,
      ),
    ).thenAnswer((_) async {});

    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: true),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stem for q_2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add note'));
    await tester.pumpAndSettle();
    expect(find.text('Why did you miss it?'), findsOneWidget);
    await tester.tap(find.text('I misread'));
    await tester.pumpAndSettle();

    verify(
      () => attemptRepo.saveReviewReason(
        attemptId: 'attempt_1',
        questionId: 'q_2',
        savedAt: any(named: 'savedAt'),
        missReason: MissReason.misread,
      ),
    ).called(1);
  });

  Future<void> openFirstBlank(
    WidgetTester tester, {
    bool pro = false,
    List<Override> extra = const [],
  }) async {
    await tester.pumpAppWithProviders(
      MockReviewPage(attemptId: 'attempt_1', proIsActive: pro),
      overrides: [
        ...extra,
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stem for q_2'));
    await tester.pumpAndSettle();
  }

  testWidgets('review keeps the passage needed to understand the question',
      (tester) async {
    final original = questions['q_2']!;
    questions['q_2'] = original.copyWith(passageId: 'passage_1');
    addTearDown(() => questions['q_2'] = original);
    when(() => contentRepo.passageById('passage_1')).thenAnswer(
      (_) async => const Passage(
        id: 'passage_1',
        topicId: 't_1',
        title: 'The source passage',
        body: 'This is the evidence needed to answer the question.',
        language: 'en',
        wordCount: 11,
      ),
    );
    await openFirstBlank(tester);
    expect(
      find.text('This is the evidence needed to answer the question.'),
      findsOneWidget,
    );
  });

  testWidgets('review draws the diagram attached to the question',
      (tester) async {
    final original = questions['q_2']!;
    questions['q_2'] = original.copyWith(
      figureSpecJson:
          '{"kind":"gear-train","gears":3,"firstTurns":"clockwise"}',
    );
    addTearDown(() => questions['q_2'] = original);
    await openFirstBlank(tester);
    expect(find.byType(GearTrainFigure), findsOneWidget);
  });

  testWidgets('Free can flag and unflag one reviewed question', (tester) async {
    final saved = <String>{};
    when(() => flagsRepo.isFlagged(any())).thenAnswer(
      (call) async => saved.contains(call.positionalArguments.first),
    );
    when(() => flagsRepo.flaggedIds()).thenAnswer((_) async => Set.of(saved));
    when(() => flagsRepo.flag(any())).thenAnswer((call) async {
      saved.add(call.positionalArguments.first as String);
    });
    when(() => flagsRepo.unflag(any())).thenAnswer((call) async {
      saved.remove(call.positionalArguments.first as String);
    });
    await openFirstBlank(tester);
    await tester.tap(find.byTooltip('Flag question'));
    await tester.pumpAndSettle();
    expect(saved, {'q_2'});
    expect(find.byTooltip('Unflag question'), findsOneWidget);
    await tester.tap(find.byTooltip('Unflag question'));
    await tester.pumpAndSettle();
    expect(saved, isEmpty);
    expect(find.byTooltip('Flag question'), findsOneWidget);
  });

  testWidgets('saved custom notes reopen for editing after saving',
      (tester) async {
    final submitted = mockAttempt;
    String? savedNote;
    when(() => attemptRepo.findById('attempt_1')).thenAnswer(
      (_) async => MockAttempt(
        id: submitted.id,
        userId: submitted.userId,
        examId: submitted.examId,
        blueprintId: submitted.blueprintId,
        blueprintName: submitted.blueprintName,
        durationMinutes: submitted.durationMinutes,
        status: submitted.status,
        strictMode: submitted.strictMode,
        sampledQuestionsJson: submitted.sampledQuestionsJson,
        elapsedSeconds: submitted.elapsedSeconds,
        accumulatedPausedSeconds: 0,
        pausedAtLastFlush: false,
        flagsJson: submitted.flagsJson,
        currentIndex: 0,
        startedAt: submitted.startedAt,
        lastFlushedAt: submitted.lastFlushedAt,
        updatedAt: submitted.updatedAt,
        submittedAt: submitted.submittedAt,
        answersJson: jsonEncode({
          'q_1': {'selectedIndex': 1, 'atSec': 10},
          'q_2': {
            'selectedIndex': -1,
            'atSec': 0,
            'blankReason': 'other',
            'reasonNote': savedNote ?? 'I need more time',
          },
        }),
      ),
    );
    when(
      () => attemptRepo.saveReviewReason(
        attemptId: 'attempt_1',
        questionId: 'q_2',
        savedAt: any(named: 'savedAt'),
        blankReason: BlankReason.other,
        reasonNote: any(named: 'reasonNote'),
      ),
    ).thenAnswer((call) async {
      savedNote = call.namedArguments[#reasonNote] as String?;
    });
    await openFirstBlank(tester, pro: true);
    await tester.tap(find.byTooltip('Add note'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'I need more time',
    );
    await tester.enterText(find.byType(TextField), 'I will return sooner');
    await tester.ensureVisible(find.text('Save Note'));
    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Add note'));
    await tester.tap(find.byTooltip('Add note'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'I will return sooner',
    );
  });
  testWidgets(
      'bulk flags stop after an account change '
      'and do not acknowledge the offer', (tester) async {
    final auth = StreamController<AuthState>();
    addTearDown(auth.close);
    auth.add(
      const AuthState.signedIn(
        user: AuthUser(uid: 'a', email: 'a@x.test', displayName: 'A'),
      ),
    );
    final gate = Completer<void>();
    var calls = 0;
    when(() => flagsRepo.flag(any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) await gate.future;
    });
    await openFirstBlank(
      tester,
      extra: [authStateProvider.overrideWith((ref) => auth.stream)],
    );
    await tester.tap(find.byTooltip('Back to questions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flagged 12'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save All 12'));
    await tester.pump();
    auth.add(
      const AuthState.signedIn(
        user: AuthUser(uid: 'b', email: 'b@x.test', displayName: 'B'),
      ),
    );
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();
    expect(calls, 1);
    verifyNever(
      () =>
          prefsRepo.setDeviceValue('mock_flag_offer_handled_attempt_1', 'true'),
    );
  });
  testWidgets('a pending flag lookup cannot write into the next account',
      (tester) async {
    final auth = StreamController<AuthState>();
    addTearDown(auth.close);
    auth.add(
      const AuthState.signedIn(
        user: AuthUser(uid: 'a', email: 'a@x.test', displayName: 'A'),
      ),
    );
    final gate = Completer<bool>();
    when(() => flagsRepo.isFlagged('q_2')).thenAnswer((_) => gate.future);
    await openFirstBlank(
      tester,
      extra: [authStateProvider.overrideWith((ref) => auth.stream)],
    );
    await tester.tap(find.byTooltip('Flag question'));
    auth.add(
      const AuthState.signedIn(
        user: AuthUser(uid: 'b', email: 'b@x.test', displayName: 'B'),
      ),
    );
    await tester.pump();
    gate.complete(false);
    await tester.pumpAndSettle();
    verifyNever(() => flagsRepo.flag('q_2'));
  });
  testWidgets('failed note save preserves the draft and retries the same note',
      (tester) async {
    var calls = 0;
    when(
      () => attemptRepo.saveReviewReason(
        attemptId: 'attempt_1',
        questionId: 'q_2',
        savedAt: any(named: 'savedAt'),
        blankReason: BlankReason.other,
        reasonNote: 'My saved draft',
      ),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw StateError('offline');
    });
    await openFirstBlank(tester, pro: true);
    await tester.tap(find.byTooltip('Add note'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Type my own'));
    await tester.tap(find.text('Type my own'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'My saved draft');
    await tester.ensureVisible(find.text('Save Note'));
    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'My saved draft',
    );
    await tester.ensureVisible(find.text('Try Again'));
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(TextField), findsNothing);
  });
  testWidgets(
      'Finish the Notes waits for saved notes before opening the editor',
      (tester) async {
    final notes = Completer<Map<String, MockAnswer>>();
    await tester.pumpAppWithProviders(
      const MockReviewPage(attemptId: 'attempt_1', proIsActive: true),
      overrides: [
        mockAttemptRepoProvider.overrideWithValue(attemptRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
        mockReviewAnswersProvider('attempt_1')
            .overrideWith((ref) => notes.future),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish the Notes'));
    await tester.pumpAndSettle();
    notes.complete({
      'q_2': const MockAnswer(
        selectedIndex: -1,
        atSec: 0,
        blankReason: BlankReason.other,
        reasonNote: 'Saved before opening',
      ),
    });
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Saved before opening',
    );
  });
}
