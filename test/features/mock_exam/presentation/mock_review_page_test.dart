import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_review_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockContentRepo extends Mock implements ContentRepository {}

class _MockAttemptRepo extends Mock implements MockAttemptRepo {}

class _MockFlagsRepo extends Mock implements QuestionFlagsRepository {}

class _MockPrefsRepo extends Mock implements AppPreferencesRepository {}

void main() {
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

    expect(
      find.textContaining(
        'You marked 12 to come back to while the clock was running.',
      ),
      findsOneWidget,
    );
    expect(find.text('Flag all 12'), findsOneWidget);
    expect(find.text('No thanks'), findsOneWidget);
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

    await tester.tap(find.text('Flag all 12'));
    await tester.pumpAndSettle();

    expect(find.text('Flag all 12'), findsNothing);
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

    await tester.tap(find.text('No thanks'));
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

  testWidgets('the mock review groups by subject', (tester) async {
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

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
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

    // Default filter is Wrong (11 wrong out of 12 since only q_1 was correct).
    expect(find.byType(ReviewRow), findsNWidgets(11));

    // Tap All filter to see all 12.
    await tester.tap(find.text('All 12'));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewRow), findsNWidgets(12));
  });
}
