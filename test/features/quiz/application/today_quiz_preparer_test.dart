import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/application/quiz_preparation_stamp.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';

void main() {
  const request = QuizPreparationRequest(
    userId: 'local',
    examId: 'exam_cse_pro',
  );

  test('unchanged Today preparation is built once and shared by identity',
      () async {
    var builds = 0;
    var stamp = _stamp(historyRevision: 'history-1');
    final preparer = TodayQuizPreparer(
      readStamp: (_) async => stamp,
      buildPlan: (_) async {
        builds += 1;
        return _plan('q-$builds');
      },
      now: () => DateTime(2026, 9, 9, 9),
    );

    final first = await preparer.prepare(request);
    final second = await preparer.prepare(request);

    expect(identical(first, second), isTrue);
    expect(builds, 1);
    expect(first.orderedQuestionIds, const ['q-1']);

    stamp = _stamp(historyRevision: 'history-2');
    final third = await preparer.prepare(request);
    expect(identical(first, third), isFalse);
    expect(builds, 2);
    expect(third.orderedQuestionIds, const ['q-2']);
  });

  test('prepared Today plan freezes the builder question list', () async {
    final sourcePlan = _plan('q-original');
    final preparer = TodayQuizPreparer(
      readStamp: (_) async => _stamp(historyRevision: 'history-1'),
      buildPlan: (_) async => sourcePlan,
      now: () => DateTime(2026, 9, 9, 9),
    );

    final prepared = await preparer.prepare(request);
    sourcePlan.questions.add(_question('q-late'));

    expect(prepared.orderedQuestionIds, const ['q-original']);
    expect(
      prepared.plan.questions.map((question) => question.id),
      const ['q-original'],
    );
    expect(
      () => prepared.plan.questions.add(_question('q-mutated')),
      throwsUnsupportedError,
    );
  });

  test('older async preparation cannot overwrite a newer generation', () async {
    var stamp = _stamp(historyRevision: 'history-1');
    final firstPlan = Completer<TodaySessionPlan>();
    final secondPlan = Completer<TodaySessionPlan>();
    var builds = 0;
    final preparer = TodayQuizPreparer(
      readStamp: (_) async => stamp,
      buildPlan: (_) {
        builds += 1;
        return builds == 1 ? firstPlan.future : secondPlan.future;
      },
      now: () => DateTime(2026, 9, 9, 9),
    );

    final older = preparer.prepare(request);
    await Future<void>.delayed(Duration.zero);
    preparer.invalidate(request);
    stamp = _stamp(historyRevision: 'history-2');
    final newer = preparer.prepare(request);
    await Future<void>.delayed(Duration.zero);

    secondPlan.complete(_plan('q-new'));
    final newestValue = await newer;
    firstPlan.complete(_plan('q-old'));
    final olderValue = await older;

    expect(newestValue.orderedQuestionIds, const ['q-new']);
    expect(identical(olderValue, newestValue), isTrue);
    expect(identical(await preparer.prepare(request), newestValue), isTrue);
  });

  test('failed preparation reports once and clears in-flight work', () async {
    final uncaught = <Object>[];
    var reads = 0;

    await runZonedGuarded(
      () async {
        final preparer = TodayQuizPreparer(
          readStamp: (_) async {
            reads += 1;
            if (reads == 1) throw StateError('stamp failed');
            return _stamp(historyRevision: 'history-1');
          },
          buildPlan: (_) async => _plan('q-retry'),
          now: () => DateTime(2026, 9, 9, 9),
        );

        await expectLater(
          preparer.prepare(request),
          throwsA(isA<StateError>()),
        );
        await Future<void>.delayed(Duration.zero);

        final retried = await preparer.prepare(request);
        expect(retried.orderedQuestionIds, const ['q-retry']);
      },
      (error, stackTrace) => uncaught.add(error),
    );

    expect(uncaught, isEmpty);
  });

  test('prepared-session cache is bounded', () async {
    var builds = 0;
    final preparer = TodayQuizPreparer(
      maxEntries: 2,
      readStamp: (request) async => _stamp(
        examId: request.examId,
        historyRevision: request.examId,
      ),
      buildPlan: (request) async {
        builds += 1;
        return _plan('q-${request.examId}-$builds');
      },
      now: () => DateTime(2026, 9, 9, 9),
    );

    await preparer.prepare(
      const QuizPreparationRequest(userId: 'local', examId: 'exam-a'),
    );
    await preparer.prepare(
      const QuizPreparationRequest(userId: 'local', examId: 'exam-b'),
    );
    await preparer.prepare(
      const QuizPreparationRequest(userId: 'local', examId: 'exam-c'),
    );

    expect(preparer.cachedEntryCount, 2);
    await preparer.prepare(
      const QuizPreparationRequest(userId: 'local', examId: 'exam-a'),
    );
    expect(builds, 4);
  });
}

QuizPreparationStamp _stamp({
  required String historyRevision,
  String examId = 'exam_cse_pro',
}) {
  return QuizPreparationStamp(
    contentRevision: 'content-1',
    accountLifetimeToken: 'uid:anon-1',
    examId: examId,
    topicId: null,
    scopeToken: 'topic-a|topic-b',
    topicExclusionToken: '',
    ordering: SessionOrdering.interleavedTail,
    sessionLength: 10,
    roadmapToken: 'day|digest|0',
    historyRevision: historyRevision,
    sessionStateRevision: 'sessions-1',
    localDay: DateTime(2026, 9, 9),
    nextDueExpiry: DateTime(2026, 9, 9, 12),
  );
}

TodaySessionPlan _plan(String id) {
  return TodaySessionPlan(
    questions: [_question(id)],
    dueCount: 1,
    weaknessCount: 0,
    freshCount: 0,
    topicId: 'topic-a',
    topicName: 'Topic A',
  );
}

Question _question(String id) {
  return Question(
    id: id,
    version: 1,
    examIds: const ['exam_cse_pro'],
    topicId: 'topic-a',
    language: 'en',
    stem: 'Stem',
    choices: const [
      Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
      Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
    ],
    explanation: 'Because.',
  );
}
