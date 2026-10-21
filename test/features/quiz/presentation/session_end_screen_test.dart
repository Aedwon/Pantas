import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/domain/models/review_batch_position.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';

import '../../../helpers/pump_app.dart';

QuizSession completedSession({
  int total = 10,
  int correct = 7,
  bool batch = false,
}) {
  final questions = List.generate(
    total,
    (i) => Question(
      id: 'q$i',
      version: 1,
      examIds: const ['e'],
      topicId: 't',
      language: 'en',
      stem: 'Stem $i',
      shortLabel: 'Question $i',
      explanation: 'Explanation $i',
      choices: const [
        Choice(id: 'a', label: 'A', text: 'Right', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'Wrong', isCorrect: false),
      ],
    ),
  );
  return QuizSession(
    sessionId: 's',
    examId: 'e',
    questions: questions,
    currentIndex: total - 1,
    startedAt: DateTime.utc(2026, 10, 16),
    reviewBatch: batch
        ? const ReviewBatchPosition(
            batchId: 's',
            userId: 'local',
            ordinal: 1,
            total: 2,
          )
        : null,
    outcomes: [
      for (var i = 0; i < total; i++)
        AnswerOutcome(
          questionId: 'q$i',
          questionVersion: 1,
          chosenChoiceId: i < correct ? 'a' : 'b',
          correctChoiceId: 'a',
          responseMs: 54000,
        ),
    ],
  );
}

Attempt completedAttempt(QuizSession session) => Attempt(
      id: session.sessionId,
      examId: session.examId,
      startedAt: session.startedAt,
      completedAt: session.startedAt.add(const Duration(minutes: 9)),
      items: [
        for (final o in session.outcomes)
          AttemptItem(
            questionId: o.questionId,
            questionVersion: o.questionVersion,
            chosenChoiceId: o.chosenChoiceId,
            correctChoiceId: o.correctChoiceId,
            responseMs: o.responseMs,
          ),
      ],
    );

void main() {
  Future<void> pump(
    WidgetTester tester, {
    int correct = 7,
    bool pro = false,
    bool batch = false,
    double scale = 1,
    Duration? duration = const Duration(minutes: 9),
  }) async {
    final session = completedSession(correct: correct, batch: batch);
    await tester.pumpApp(
      MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: SessionEndBody(
          session: session,
          attempt: completedAttempt(session).copyWith(
            completedAt:
                duration == null ? null : session.startedAt.add(duration),
          ),
          subjectNames: const {'t': 'Earth Science'},
          proIsActive: pro,
          onDone: () {},
          onQuestion: (_) {},
          onAll: () {},
          onMistakes: () {},
          onNotes: () {},
          onNext: batch ? () async {} : null,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('end score uses completed answers and real elapsed time',
      (tester) async {
    await pump(tester);
    expect(find.text('Session finished.'), findsOneWidget);
    expect(find.text('/10'), findsOneWidget);
    expect(find.text('correct'), findsOneWidget);
    expect(find.text('in 9 minutes'), findsOneWidget);
    expect(find.text('YOUR MISTAKES'), findsOneWidget);
    expect(find.text('See all questions'), findsOneWidget);
    expect(find.textContaining("You'll see"), findsNothing);
    expect(find.textContaining('you picked'), findsNothing);
    expect(find.text('Finish the Notes'), findsNothing);
  });
  testWidgets('many mistakes show three before the complete list',
      (tester) async {
    await pump(tester, correct: 2, pro: true);
    expect(find.text('Question 2'), findsOneWidget);
    expect(find.text('Question 4'), findsOneWidget);
    expect(find.text('Question 5'), findsNothing);
    expect(find.text('See all 8 mistakes'), findsOneWidget);
    final row = tester.widget<ListRow>(find.byType(ListRow).first);
    expect(row.subtitle, 'Earth Science');
    await tester.scrollUntilVisible(find.text('Finish the Notes'), 300);
    expect(find.text('Finish the Notes'), findsOneWidget);
  });
  testWidgets('perfect score omits mistakes and notes but keeps all questions',
      (tester) async {
    await pump(tester, correct: 10, pro: true);
    expect(find.text('YOUR MISTAKES'), findsNothing);
    expect(find.text('Finish the Notes'), findsNothing);
    expect(find.text('See all questions'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.textContaining('Start Session'), findsNothing);
  });
  testWidgets('only real batch metadata can show a next ordinal',
      (tester) async {
    await pump(tester, batch: true);
    expect(find.text('Reviews · Session 1 of 2'), findsOneWidget);
    expect(find.text('Start Session 2'), findsOneWidget);
    await pump(tester);
    expect(find.textContaining('Session 1 of'), findsNothing);
    expect(find.textContaining('Start Session'), findsNothing);
  });
  testWidgets('large text preserves reachable actions without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pump(tester, pro: true, correct: 2, batch: true, scale: 2);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Finish the Notes'), 300);
    expect(tester.takeException(), isNull);
  });
  testWidgets('elapsed time uses the immutable valid completion endpoint',
      (tester) async {
    for (final (duration, label) in <(Duration?, String?)>[
      (const Duration(seconds: 12), 'in under 1 minute'),
      (Duration.zero, 'in 0 minutes'),
      (const Duration(minutes: 1), 'in 1 minute'),
      (const Duration(minutes: 9), 'in 9 minutes'),
      (null, null),
      (const Duration(seconds: -1), null),
    ]) {
      await pump(tester, duration: duration);
      if (label != null) {
        expect(find.text(label), findsOneWidget);
        await tester.pump(const Duration(hours: 1));
        expect(find.text(label), findsOneWidget);
      } else {
        expect(find.textContaining('in ', findRichText: true), findsNothing);
      }
    }
  });
  testWidgets('next claims once and keeps retryable failure', (tester) async {
    final session = completedSession(batch: true);
    var calls = 0;
    final pending = Completer<void>();
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: SessionEndBody(
          session: session,
          attempt: completedAttempt(session),
          subjectNames: const {},
          proIsActive: true,
          onDone: () {},
          onQuestion: (_) {},
          onAll: () {},
          onMistakes: () {},
          onNotes: () {},
          onNext: () {
            calls++;
            return calls == 1 ? pending.future : Future.value();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Session 2'));
    await tester.pump();
    await tester.tap(find.text('Start Session 2'));
    expect(calls, 1);
    pending.completeError(StateError('internal details'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('internal details'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Could not save your progress.'), findsNothing);
  });
  testWidgets('dark reduced motion shows final state and usable actions',
      (tester) async {
    final session = completedSession();
    var done = 0;
    var all = 0;
    final seen = <int>[];
    final semantics = tester.ensureSemantics();
    await tester.pumpApp(
      Theme(
        data: buildDarkTheme(),
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SessionEndBody(
            session: session,
            attempt: completedAttempt(session),
            subjectNames: const {},
            proIsActive: false,
            onDone: () => done++,
            onQuestion: seen.add,
            onAll: () => all++,
            onMistakes: () {},
            onNotes: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('7 of 10 correct')), findsOneWidget);
    await tester.scrollUntilVisible(find.text('See all questions'), 200);
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all questions'));
    expect(all, 1);
    await tester.scrollUntilVisible(find.text('Question 7'), -200);
    await tester.drag(find.byType(ListView), const Offset(0, 250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Question 7'));
    expect(seen, [7]);
    await tester.tap(find.text('Done'));
    expect(done, 1);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('normal motion finishes once and disposes during entry',
      (tester) async {
    final session = completedSession();
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(),
        child: SessionEndBody(
          session: session,
          attempt: completedAttempt(session),
          subjectNames: const {},
          proIsActive: false,
          onDone: () {},
          onQuestion: (_) {},
          onAll: () {},
          onMistakes: () {},
          onNotes: () {},
        ),
      ),
    );
    final header = find
        .ancestor(
          of: find.text('Session finished.'),
          matching: find.byType(Opacity),
        )
        .first;
    expect(tester.widget<Opacity>(header).opacity, 0);
    await tester.pump(const Duration(milliseconds: 480));
    expect(tester.widget<Opacity>(header).opacity, closeTo(1, .001));
    await tester.pump(const Duration(seconds: 3));
    expect(tester.widget<Opacity>(header).opacity, 1);
    await tester.pumpApp(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });
}
