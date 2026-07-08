import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_chevron.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/debrief/miss_cause.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/debrief/session_debrief.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/debrief_providers.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/pages/debrief_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Question makeQuestion(String id, {String topicId = 't_chem'}) {
    return Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: topicId,
      language: 'en',
      stem: 'Stem for $id',
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'Opt A', isCorrect: true),
        Choice(id: 'c_b', label: 'B', text: 'Opt B', isCorrect: false),
      ],
      explanation: 'Explanation',
    );
  }

  QuizSession makeSession({
    int totalQuestions = 10,
    int correctCount = 7,
    SessionOrigin origin = SessionOrigin.todayTopic,
  }) {
    final start = DateTime.utc(2026, 8, 2, 10, 0);
    final questions = List.generate(
      totalQuestions,
      (i) => makeQuestion('q_$i', topicId: 't_chem'),
    );
    final outcomes = List.generate(
      questions.length,
      (i) => AnswerOutcome(
        questionId: questions[i].id,
        questionVersion: 1,
        chosenChoiceId: i < correctCount ? 'c_a' : 'c_b',
        correctChoiceId: 'c_a',
        responseMs: 4000,
        derivedRating: i < correctCount ? Rating.good : Rating.again,
        nextReviewIntervalDays: 1,
      ),
    );

    return QuizSession(
      sessionId: 'sess_1',
      examId: 'exam_cse_pro',
      questions: questions,
      currentIndex: questions.length,
      outcomes: outcomes,
      startedAt: start,
      origin: origin,
    );
  }

  Future<void> pumpDebrief(
    WidgetTester tester, {
    required SessionDebrief debrief,
    required bool proIsActive,
  }) async {
    final params = (
      attemptId: 'att_1',
      proIsActive: proIsActive,
      sessionOverride: null,
      attemptOverride: null,
    );

    await tester.pumpAppWithProviders(
      DebriefPage(
        attemptId: 'att_1',
        proIsActive: proIsActive,
      ),
      overrides: [
        sessionDebriefProvider(params).overrideWith((_) async => debrief),
      ],
    );
  }

  testWidgets('the headline speaks plainly', (tester) async {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: {'t_chem': 'Chemistry'},
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await pumpDebrief(tester, debrief: debrief, proIsActive: true);
    await tester.pumpAndSettle();

    expect(find.text('Ten answered.'), findsOneWidget);
    expect(find.text('Session complete'), findsNothing);
  });

  testWidgets('two figures, correct and taken', (tester) async {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: {'t_chem': 'Chemistry'},
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await pumpDebrief(tester, debrief: debrief, proIsActive: true);
    await tester.pumpAndSettle();

    expect(find.text('correct'), findsOneWidget);
    expect(find.text('taken'), findsOneWidget);
    expect(find.text('spent'), findsNothing);
    expect(find.textContaining('streak'), findsNothing);
  });

  testWidgets('the section is a return, not a loss', (tester) async {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: {'t_chem': 'Chemistry'},
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await pumpDebrief(tester, debrief: debrief, proIsActive: true);
    await tester.pumpAndSettle();

    expect(find.text('To come back to'), findsOneWidget);
    expect(find.text('What you missed'), findsNothing);
  });

  testWidgets('miss rows do not navigate', (tester) async {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: {'t_chem': 'Chemistry'},
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await pumpDebrief(tester, debrief: debrief, proIsActive: true);
    await tester.pumpAndSettle();

    expect(find.byType(InkChevron), findsNothing);
  });

  testWidgets('the return promise is shown to Free too', (tester) async {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: {'t_chem': 'Chemistry'},
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: false,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await pumpDebrief(tester, debrief: debrief, proIsActive: false);
    await tester.pumpAndSettle();

    expect(
      find.text("You'll see all three again tomorrow."),
      findsOneWidget,
    );
  });

  testWidgets('the review row counts the session', (tester) async {
    final session = makeSession();
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: {'t_chem': 'Chemistry'},
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await pumpDebrief(tester, debrief: debrief, proIsActive: true);
    await tester.pumpAndSettle();

    expect(find.text('Go through all 10'), findsOneWidget);
  });

  testWidgets('a clean session drops the section and the row', (tester) async {
    final session = makeSession(totalQuestions: 10, correctCount: 10);
    final debrief = BuildSessionDebrief.call(
      session: session,
      topicNames: {'t_chem': 'Chemistry'},
      topicAverageMs: {},
      topicAnswerCount: {},
      priorCorrect: {},
      priorAttemptedQuestionIds: {},
      proIsActive: true,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await pumpDebrief(tester, debrief: debrief, proIsActive: true);
    await tester.pumpAndSettle();

    expect(find.text('To come back to'), findsNothing);
    expect(find.textContaining('Go through all'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('the inferred cause is Pro only', (tester) async {
    final session = makeSession();

    final debriefFree = BuildSessionDebrief.call(
      session: session,
      topicNames: {'t_chem': 'Chemistry'},
      topicAverageMs: {'t_chem': 20000},
      topicAnswerCount: {'t_chem': 10},
      priorCorrect: {},
      priorAttemptedQuestionIds: {'q_7', 'q_8', 'q_9'},
      proIsActive: false,
      now: session.startedAt.add(const Duration(minutes: 9)),
    );

    await pumpDebrief(tester, debrief: debriefFree, proIsActive: false);
    await tester.pumpAndSettle();

    expect(find.textContaining('You usually take'), findsNothing);
  });
}
