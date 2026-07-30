import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/features/quiz/presentation/pages/flagged_list_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockContentRepo extends Mock implements ContentRepository {}

class _MockFlagsRepo extends Mock implements QuestionFlagsRepository {}

class _MockPrefsRepo extends Mock implements AppPreferencesRepository {}

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

    // The review reads every question in one query now, not one at a time.
    when(() => contentRepo.questionsByIds(any()))
        .thenAnswer((invocation) async {
      final wanted =
          (invocation.positionalArguments.first as Iterable<String>).toSet();
      return {
        for (final q in [q1, q2, q3])
          if (wanted.contains(q.id)) q.id: q,
      };
    });

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
      ],
    );
  });

  testWidgets('the flagged list groups by subject', (tester) async {
    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
        contentRepositoryProvider.overrideWithValue(contentRepo),
        questionFlagsRepositoryProvider.overrideWithValue(flagsRepo),
        appPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Science'), findsOneWidget);
  });

  testWidgets('it has no filter row', (tester) async {
    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
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
        ],
      );
    });

    await tester.pumpAppWithProviders(
      const FlaggedListPage(examId: 'cse_prof'),
      overrides: [
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
}
