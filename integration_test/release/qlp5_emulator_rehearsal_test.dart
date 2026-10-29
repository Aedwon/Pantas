import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/answer_row.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/application/quiz_performance_probe.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

import 'support/qlp5_performance_collector.dart';
import 'support/release_harness.dart';
import 'support/test_content_fixture.dart';
import 'support/test_content_seed.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'E09 emulator rehearses Today timing collection without acceptance',
      (tester) async {
    final buildDirectory = Directory.systemTemp.createTempSync(
      'pantas-e09-qlp5-emulator-',
    );
    addTearDown(() {
      if (buildDirectory.existsSync()) {
        buildDirectory.deleteSync(recursive: true);
      }
    });

    final installation = await installReleaseTestContent(
      buildDirectory: buildDirectory,
    );
    await installation.dispose();

    final collector = Qlp5PerformanceCollector();
    var contentQueryCount = 0;
    final fixedNow = DateTime(2026, 9, 10, 8);
    final harness = ReleaseHarness(
      openContentDatabase: installation.openInstalledContent,
      additionalOverrides: <Override>[
        authStateProvider.overrideWith(
          (_) => Stream.value(
            const AuthState.anonymous(uid: 'release-e2e-anonymous'),
          ),
        ),
        entitlementProvider.overrideWith(
          (_) => Stream.value(const Entitlement.free()),
        ),
        nowProvider.overrideWithValue(() => fixedNow),
        quizPerformanceProbeProvider.overrideWithValue(
          QuizPerformanceProbe.recording(collector.recordPhaseSample),
        ),
        contentRepositoryProvider.overrideWith(
          (ref) => ContentRepository(
            ref.watch(contentDatabaseProvider),
            onQuery: () => contentQueryCount += 1,
          ),
        ),
      ],
    );
    await harness.openDatabases();
    addTearDown(harness.dispose);

    await harness.pumpProductionApp(tester);
    await tester.pumpAndSettle();
    await _pumpUntilFinder(tester, find.text('Get started'), 'Get started');
    await completeOnboardingThroughUi(tester);
    if (find.text('Not right now').evaluate().isNotEmpty) {
      await tester.tap(find.text('Not right now'));
      await tester.pumpAndSettle();
    }

    // Test setup only: Today sessions are available only after assessment.
    // Keep this outside every QLP-5 timing and query-count window.
    await harness.providerContainer
        .read(assessmentRepositoryProvider)
        .saveResult(
      ReleaseTestContentIds.exam,
      fixedNow,
      const <TopicScore>[
        TopicScore(
          topicId: ReleaseTestContentIds.topic,
          correct: 1,
          total: 1,
        ),
      ],
    );

    contentQueryCount = 0;
    final timingsCallback = collector.recordFrameTimings;
    WidgetsBinding.instance.addTimingsCallback(timingsCallback);
    addTearDown(
      () => WidgetsBinding.instance.removeTimingsCallback(timingsCallback),
    );

    final recommendationWatch = Stopwatch()..start();
    await tester.tap(find.text('Quiz'));
    await tester.pump();
    await _pumpUntilFinder(
      tester,
      find.text("Today's session"),
      'Today session panel',
    );
    await _pumpUntilFinder(tester, find.text('Start'), 'Today Start');
    recommendationWatch.stop();
    collector.recordObservation(
      Qlp5Metric.firstRecommendation,
      recommendationWatch.elapsed,
      temperature: Qlp5RunTemperature.cold,
    );
    final recommendationQueries = contentQueryCount;

    final startFeedbackWatch = Stopwatch()..start();
    final launchWatch = Stopwatch()..start();
    await tester.tap(find.text('Start'));
    await tester.pump();
    await _pumpUntil(
      tester,
      () => harness.providerContainer.read(quizControllerProvider) is! QuizIdle,
      'Start feedback state transition',
    );
    startFeedbackWatch.stop();
    collector.recordObservation(
      Qlp5Metric.startFeedback,
      startFeedbackWatch.elapsed,
      temperature: Qlp5RunTemperature.cold,
    );

    await _pumpUntil(
      tester,
      () {
        final state = harness.providerContainer.read(quizControllerProvider);
        return state is QuizRunning &&
            state.questionShownAt != null &&
            _hasEnabledAnswerRow();
      },
      'first complete answerable Today frame',
    );
    launchWatch.stop();
    collector
      ..recordObservation(
        Qlp5Metric.coldDailyRoute,
        launchWatch.elapsed,
        temperature: Qlp5RunTemperature.cold,
      )
      ..recordObservation(
        Qlp5Metric.firstAnswerable,
        launchWatch.elapsed,
        temperature: Qlp5RunTemperature.cold,
      )
      ..recordObservation(
        Qlp5Metric.launchToAnswerable,
        launchWatch.elapsed,
        temperature: Qlp5RunTemperature.cold,
      );
    final launchQueries = contentQueryCount;

    final firstRunning =
        harness.providerContainer.read(quizControllerProvider) as QuizRunning;
    final firstIndex = firstRunning.session.currentIndex;
    expect(
      firstRunning.session.questions.length,
      greaterThan(firstIndex + 1),
      reason: 'The deterministic fixture must exercise prepared Next.',
    );
    await _answerVisibleQuestion(tester);
    await _pumpUntil(
      tester,
      () {
        final state = harness.providerContainer.read(quizControllerProvider);
        return state is QuizRunning && state.session.currentOutcome != null;
      },
      'persisted answer before prepared Next',
    );
    await _pumpUntilFinder(tester, find.text('Next'), 'prepared Next control');

    final nextWatch = Stopwatch()..start();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await _pumpUntil(
      tester,
      () {
        final state = harness.providerContainer.read(quizControllerProvider);
        return state is QuizRunning &&
            state.session.currentIndex == firstIndex + 1 &&
            state.questionShownAt != null &&
            _hasEnabledAnswerRow();
      },
      'prepared Next answerable frame',
    );
    nextWatch.stop();
    collector.recordObservation(
      Qlp5Metric.preparedNext,
      nextWatch.elapsed,
      temperature: Qlp5RunTemperature.warm,
    );
    final throughNextQueries = contentQueryCount;

    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final phases = collector.phaseSamples.map((sample) => sample.phase).toSet();
    expect(
      phases,
      containsAll(<QuizPerformancePhase>{
        QuizPerformancePhase.scopeResolution,
        QuizPerformancePhase.metadataRead,
        QuizPerformancePhase.historyRead,
        QuizPerformancePhase.selection,
        QuizPerformancePhase.hydration,
        QuizPerformancePhase.sessionPersistence,
      }),
    );

    final output = <String, Object>{
      'kind': 'e09_qlp5_emulator_rehearsal',
      'acceptance': false,
      'fixture': 'release-e2e-fixture-v1',
      'metrics': <Object>[
        collector
            .summary(
              Qlp5Metric.firstRecommendation,
              temperature: Qlp5RunTemperature.cold,
            )
            .toJson(),
        collector
            .summary(
              Qlp5Metric.startFeedback,
              temperature: Qlp5RunTemperature.cold,
            )
            .toJson(),
        collector
            .summary(
              Qlp5Metric.coldDailyRoute,
              temperature: Qlp5RunTemperature.cold,
            )
            .toJson(),
        collector
            .summary(
              Qlp5Metric.firstAnswerable,
              temperature: Qlp5RunTemperature.cold,
            )
            .toJson(),
        collector
            .summary(
              Qlp5Metric.launchToAnswerable,
              temperature: Qlp5RunTemperature.cold,
            )
            .toJson(),
        collector
            .summary(
              Qlp5Metric.preparedNext,
              temperature: Qlp5RunTemperature.warm,
            )
            .toJson(),
      ],
      'phase_samples': <Object>[
        for (final sample in collector.phaseSamples) sample.toJson(),
      ],
      'query_counts': <String, int>{
        'recommendation': recommendationQueries,
        'through_launch': launchQueries,
        'through_next': throughNextQueries,
      },
      'frames': collector.frameSummary.toJson(),
    };
    // ignore: avoid_print -- structured local E09 evidence is test output.
    print('E09_QLP5_EMULATOR_JSON=${jsonEncode(output)}');
  });
}

Future<void> _pumpUntilFinder(
  WidgetTester tester,
  Finder finder,
  String label,
) =>
    _pumpUntil(
      tester,
      () => finder.evaluate().isNotEmpty,
      label,
    );

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() predicate,
  String label,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for $label.');
    }
    await tester.pump(const Duration(milliseconds: 10));
  }
}

bool _hasEnabledAnswerRow() => find
    .byWidgetPredicate(
      (widget) => widget is AnswerRow && widget.onTap != null,
      description: 'enabled AnswerRow',
    )
    .evaluate()
    .isNotEmpty;

Future<void> _answerVisibleQuestion(WidgetTester tester) async {
  for (final label in <String>['3', '9', '2']) {
    final rowFinder = find.byWidgetPredicate(
      (widget) => widget is AnswerRow && widget.text == label,
      description: 'AnswerRow with text $label',
    );
    if (rowFinder.evaluate().isNotEmpty) {
      expect(rowFinder, findsOneWidget);
      final choiceText = find.descendant(
        of: rowFinder,
        matching: find.text(label),
      );
      expect(choiceText, findsOneWidget);
      await tester.tap(choiceText);
      return;
    }
  }
  fail('Expected one deterministic fixture answer control.');
}
