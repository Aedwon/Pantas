import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/quiz_results_page.dart';

import '../../../helpers/pump_app.dart';

class _MockAttemptsRepo extends Mock implements AttemptsRepository {}

class _MockContentRepo extends Mock implements ContentRepository {}

class _MockFlagsRepo extends Mock implements QuestionFlagsRepository {}

void main() {
  const q1 = Question(
    id: 'q_1',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 't_1',
    language: 'en',
    stem: 'Stem text for question 1',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Option A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Option B', isCorrect: true),
    ],
    explanation: 'Explanation 1',
  );

  const q2 = Question(
    id: 'q_2',
    version: 1,
    examIds: ['cse_prof'],
    topicId: 't_2',
    language: 'en',
    stem: 'Stem text for question 2',
    choices: [
      Choice(id: 'c_a', label: 'A', text: 'Option A', isCorrect: false),
      Choice(id: 'c_b', label: 'B', text: 'Option B', isCorrect: true),
    ],
    explanation: 'Explanation 2',
  );

  const t1 =
      Topic(id: 't_1', subjectId: 's_1', name: 'Mathematics', ordering: 1);
  const t2 = Topic(id: 't_2', subjectId: 's_2', name: 'Science', ordering: 2);

  const s1 =
      Subject(id: 's_1', examId: 'cse_prof', name: 'Mathematics', ordering: 1);
  const s2 =
      Subject(id: 's_2', examId: 'cse_prof', name: 'Science', ordering: 2);

  final attempt = Attempt(
    id: 'a_1',
    examId: 'cse_prof',
    startedAt: DateTime.utc(2026, 5, 9, 12),
    completedAt: DateTime.utc(2026, 5, 9, 12, 5),
    items: const [
      AttemptItem(
        questionId: 'q_1',
        questionVersion: 1,
        chosenChoiceId: 'c_a', // miss
        correctChoiceId: 'c_b',
        responseMs: 1000,
      ),
      AttemptItem(
        questionId: 'q_2',
        questionVersion: 1,
        chosenChoiceId: 'c_b', // correct
        correctChoiceId: 'c_b',
        responseMs: 1000,
      ),
    ],
  );

  late _MockAttemptsRepo attemptsRepo;
  late _MockContentRepo contentRepo;
  late _MockFlagsRepo flagsRepo;

  setUp(() {
    attemptsRepo = _MockAttemptsRepo();
    contentRepo = _MockContentRepo();
    flagsRepo = _MockFlagsRepo();

    when(() => attemptsRepo.byId('a_1')).thenAnswer((_) async => attempt);
    when(() => flagsRepo.flaggedIds()).thenAnswer((_) async => {});

    // One query for all of them now, rather than one per question.
    when(() => contentRepo.questionsByIds(any()))
        .thenAnswer((invocation) async {
      final wanted =
          (invocation.positionalArguments.first as Iterable<String>).toSet();
      return {
        for (final q in [q1, q2])
          if (wanted.contains(q.id)) q.id: q,
      };
    });
    when(() => contentRepo.topicById('t_1')).thenAnswer((_) async => t1);
    when(() => contentRepo.topicById('t_2')).thenAnswer((_) async => t2);
    when(() => contentRepo.subjectById('s_1')).thenAnswer((_) async => s1);
    when(() => contentRepo.subjectById('s_2')).thenAnswer((_) async => s2);
  });

  testWidgets('the practice review is flat', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizResultsPage(attemptId: 'a_1'),
      overrides: [
        attemptsRepositoryProvider.overrideWithValue(attemptsRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('All questions'), findsOneWidget);
    // No subject headings even with two subjects in the session.
    expect(find.text('Mathematics'), findsNothing);
  });

  testWidgets('it opens on Wrong', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizResultsPage(attemptId: 'a_1'),
      overrides: [
        attemptsRepositoryProvider.overrideWithValue(attemptsRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Wrong 1'), findsOneWidget);
    expect(find.text('Stem text for question 1'), findsOneWidget);
    expect(find.text('Stem text for question 2'), findsNothing);
  });

  testWidgets('there is no one-time flag offer', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizResultsPage(attemptId: 'a_1'),
      overrides: [
        attemptsRepositoryProvider.overrideWithValue(attemptsRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Keep them to practice?'), findsNothing);
  });

  testWidgets('questions are named, not identified', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizResultsPage(attemptId: 'a_1'),
      overrides: [
        attemptsRepositoryProvider.overrideWithValue(attemptsRepo),
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('q_1'), findsNothing);
  });
}
