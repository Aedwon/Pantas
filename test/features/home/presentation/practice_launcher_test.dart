import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/practice_launcher.dart';
import 'package:pantas/features/quiz/application/quiz_preparation_stamp.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';

class _Preparer extends TodayQuizPreparer {
  _Preparer()
      : super(
          readStamp: (_) => throw UnimplementedError(),
          buildPlan: (_) => throw UnimplementedError(),
          now: DateTime.now,
        );
  final calls = <QuizPreparationRequest>[];
  PreparedTodaySession? result;
  Exception? failure;
  @override
  Future<PreparedTodaySession> prepare(QuizPreparationRequest request) async {
    calls.add(request);
    if (failure != null) throw failure!;
    return result!;
  }
}

PreparedTodaySession prepared({required bool empty}) => PreparedTodaySession(
      plan: TodaySessionPlan(
        questions: empty
            ? const []
            : const [
                Question(
                  id: 'q1',
                  version: 1,
                  examIds: ['e'],
                  topicId: 't',
                  language: 'en',
                  stem: 'Stem',
                  choices: [
                    Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
                    Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
                  ],
                  explanation: 'Because.',
                ),
              ],
        dueCount: 0,
        weaknessCount: 0,
        freshCount: 0,
        topicId: 't',
        topicName: 'Topic',
      ),
      stamp: QuizPreparationStamp(
        contentRevision: 'c',
        accountLifetimeToken: 'local',
        examId: 'e',
        topicId: 't',
        scopeToken: 't',
        topicExclusionToken: '',
        ordering: SessionOrdering.interleavedTail,
        sessionLength: 10,
        roadmapToken: 'r',
        historyRevision: 'h',
        sessionStateRevision: 's',
        localDay: DateTime(2026, 10, 24),
        nextDueExpiry: null,
      ),
      preparedAt: DateTime(2026, 10, 24, 10),
    );

void main() {
  late _Preparer preparer;
  Object? extra;

  Future<void> pump(WidgetTester tester) async {
    extra = null;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: Consumer(
              builder: (context, ref, _) => TextButton(
                onPressed: () => unawaited(
                  startTopicPractice(
                    context,
                    ref,
                    examId: 'e',
                    topicId: 't',
                  ),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/quiz/today/:examId',
          builder: (_, state) {
            extra = state.extra;
            return const Scaffold(body: Text('quiz'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayQuizPreparerProvider.overrideWithValue(preparer)],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  setUp(() => preparer = _Preparer());

  testWidgets('pushes the exact prepared session to the Today route',
      (tester) async {
    final session = prepared(empty: false);
    preparer.result = session;
    await pump(tester);
    expect(find.text('quiz'), findsOneWidget);
    expect(identical(extra, session), isTrue);
    expect(preparer.calls.single.topicId, 't');
  });

  testWidgets('an empty plan says nothing is ready and does not navigate',
      (tester) async {
    preparer.result = prepared(empty: true);
    await pump(tester);
    expect(find.text('No questions are ready right now.'), findsOneWidget);
    expect(find.text('quiz'), findsNothing);
  });

  testWidgets('a failed preparation says so and does not navigate',
      (tester) async {
    preparer.failure = Exception('boom');
    await pump(tester);
    expect(find.text('Could not prepare this quiz.'), findsOneWidget);
    expect(find.text('quiz'), findsNothing);
  });
}
