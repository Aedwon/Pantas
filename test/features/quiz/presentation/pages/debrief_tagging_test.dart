import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/domain/debrief/session_debrief.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/debrief_providers.dart';
import 'package:pantas/features/quiz/presentation/pages/debrief_page.dart';

import '../../../../helpers/in_memory_database.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late AttemptsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = AttemptsRepository(db);
  });
  tearDown(() => db.close());

  Question makeQuestion(String id) {
    return Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: 't_chem',
      language: 'en',
      stem: 'Stem for $id',
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: true),
        Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: false),
      ],
      explanation: 'Explanation',
    );
  }

  QuizSession makeSession({int totalQuestions = 5, int correctCount = 2}) {
    final start = DateTime.utc(2026, 8, 2, 10);
    final questions =
        List.generate(totalQuestions, (i) => makeQuestion('q_$i'));
    final outcomes = List.generate(
      questions.length,
      (i) => AnswerOutcome(
        questionId: questions[i].id,
        questionVersion: 1,
        chosenChoiceId: i < correctCount ? 'c_a' : 'c_b',
        correctChoiceId: 'c_a',
        responseMs: 4000,
        derivedRating: i < correctCount ? Rating.good : Rating.again,
      ),
    );

    return QuizSession(
      sessionId: 'sess_1',
      examId: 'exam_cse_pro',
      questions: questions,
      currentIndex: questions.length,
      outcomes: outcomes,
      startedAt: start,
    );
  }

  Future<Attempt> saveAttempt(QuizSession session) async {
    final attempt = Attempt(
      id: 'att_1',
      examId: session.examId,
      startedAt: session.startedAt,
      completedAt: session.startedAt.add(const Duration(minutes: 9)),
      items: session.outcomes
          .map(
            (o) => AttemptItem(
              questionId: o.questionId,
              questionVersion: o.questionVersion,
              chosenChoiceId: o.chosenChoiceId,
              correctChoiceId: o.correctChoiceId,
              responseMs: o.responseMs,
            ),
          )
          .toList(),
    );
    await repo.save(attempt);
    return attempt;
  }

  Future<void> pumpDebriefPage(
    WidgetTester tester, {
    required QuizSession session,
    required bool proIsActive,
  }) async {
    final attempt = await saveAttempt(session);

    final params = (
      attemptId: attempt.id,
      proIsActive: proIsActive,
      sessionOverride: session,
      attemptOverride: attempt,
    );

    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: const {'t_chem': 'Chemistry'},
      topicAverageMs: const {},
      topicAnswerCount: const {},
      priorCorrect: const {},
      priorAttemptedQuestionIds: const {},
      proIsActive: proIsActive,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await tester.pumpAppWithProviders(
      DebriefPage(
        attemptId: attempt.id,
        proIsActive: proIsActive,
        sessionOverride: session,
        attemptOverride: attempt,
      ),
      overrides: [
        attemptsRepositoryProvider.overrideWithValue(repo),
        sessionDebriefProvider(params).overrideWith((_) async => debrief),
      ],
    );
  }

  testWidgets('Free is never invited', (tester) async {
    final session = makeSession();
    await pumpDebriefPage(tester, session: session, proIsActive: false);
    await tester.pumpAndSettle();

    expect(find.text('Finish the notes'), findsNothing);
  });

  testWidgets('Pro is invited once, not per row', (tester) async {
    final session = makeSession();
    await pumpDebriefPage(tester, session: session, proIsActive: true);
    await tester.pumpAndSettle();

    expect(find.text('Finish the notes'), findsOneWidget);
    expect(
      find.text('These are the notes Pantas could write on its own. '
          "You're the only one who knows the rest."),
      findsOneWidget,
    );
  });

  testWidgets('the invitation arms three choices under every miss',
      (tester) async {
    final session = makeSession(); // 3 misses
    await pumpDebriefPage(tester, session: session, proIsActive: true);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Finish the notes'));
    await tester.tap(find.text('Finish the notes'));
    await tester.pumpAndSettle();

    expect(find.text('I misread it'), findsNWidgets(3));
    expect(find.text('I knew this, I just slipped'), findsNWidgets(3));
    expect(find.text("I didn't know it"), findsNWidgets(3));
  });

  testWidgets('leaving one blank is stated to cost nothing', (tester) async {
    final session = makeSession(); // 3 misses
    await pumpDebriefPage(tester, session: session, proIsActive: true);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Finish the notes'));
    await tester.tap(find.text('Finish the notes'));
    await tester.pumpAndSettle();

    // Tag two of three misses
    final misreadFinder = find.text('I misread it').first;
    await tester.ensureVisible(misreadFinder);
    await tester.tap(misreadFinder);
    await tester.pumpAndSettle();

    final unknownFinder = find.text("I didn't know it").at(1);
    await tester.ensureVisible(unknownFinder);
    await tester.tap(unknownFinder);
    await tester.pumpAndSettle();

    expect(
      find.text('2 of 3 noted. Leave any of them blank, it costs nothing.'),
      findsOneWidget,
    );
  });

  testWidgets('finishing them all says what it bought', (tester) async {
    final session = makeSession(); // 3 misses
    await pumpDebriefPage(tester, session: session, proIsActive: true);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Finish the notes'));
    await tester.tap(find.text('Finish the notes'));
    await tester.pumpAndSettle();

    // Tag all three misses
    final misreadFinder = find.text('I misread it').first;
    await tester.ensureVisible(misreadFinder);
    await tester.tap(misreadFinder);
    await tester.pumpAndSettle();

    final slippedFinder = find.text('I knew this, I just slipped').at(1);
    await tester.ensureVisible(slippedFinder);
    await tester.tap(slippedFinder);
    await tester.pumpAndSettle();

    final unknownFinder = find.text("I didn't know it").at(2);
    await tester.ensureVisible(unknownFinder);
    await tester.tap(unknownFinder);
    await tester.pumpAndSettle();

    expect(
      find.text('All three noted. Progress can use them now.'),
      findsOneWidget,
    );
  });

  testWidgets('a tag is written to the attempt', (tester) async {
    final session = makeSession(correctCount: 4); // 1 miss: q_4
    await pumpDebriefPage(tester, session: session, proIsActive: true);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Finish the notes'));
    await tester.tap(find.text('Finish the notes'));
    await tester.pumpAndSettle();

    final misreadFinder = find.text('I misread it');
    await tester.ensureVisible(misreadFinder);
    await tester.tap(misreadFinder);
    await tester.pumpAndSettle();

    final updatedAttempt = await repo.byId('att_1');
    expect(updatedAttempt, isNotNull);
    final taggedItem =
        updatedAttempt!.items.firstWhere((i) => i.questionId == 'q_4');
    expect(taggedItem.mistakeTag, MistakeTag.misread);
  });
}
