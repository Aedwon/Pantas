import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import 'support/fixture_quiz_journey.dart';
import 'support/release_harness.dart';
import 'support/test_content_fixture.dart';
import 'support/test_content_seed.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'custom quiz persists attempt, review, mistake, and progress state '
    'across reconstruction',
    (tester) async {
      final buildDirectory = Directory.systemTemp.createTempSync(
        'pantas-release-quiz-',
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

      final fixedNow = DateTime.utc(2026, 9, 6, 9);
      final harness = ReleaseHarness(
        openContentDatabase: installation.openInstalledContent,
        additionalOverrides: <Override>[
          releaseTestCatalogOverride,
          entitlementProvider.overrideWith(
            (_) => Stream.value(const Entitlement.free()),
          ),
          nowProvider.overrideWithValue(() => fixedNow),
        ],
      );
      await harness.openDatabases();
      addTearDown(harness.dispose);

      await harness.pumpProductionApp(tester);
      await tester.pumpAndSettle();

      await completeOnboardingThroughUi(tester);
      if (find.text('Not right now').evaluate().isNotEmpty) {
        await tester.tap(find.text('Not right now'));
        await tester.pumpAndSettle();
      }

      await startReleaseFixtureQuiz(tester);

      for (var answered = 0; answered < 3; answered += 1) {
        await _answerVisibleFixtureQuestion(tester);
        await tester.pumpAndSettle();

        await tapReleaseControl(tester, find.text('Check'));
        final done = find.text('Finish').evaluate().isNotEmpty;
        final next = find.text('Next').evaluate().isNotEmpty;
        expect(done || next, isTrue);
        await tester.tap(done ? find.text('Finish') : find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Session finished.'), findsOneWidget);
      await _expectPersistedQuizState(harness, fixedNow);
      await tapReleaseControl(tester, find.text('See all questions'));
      expect(find.text('All questions'), findsOneWidget);
      expect(find.text('Which number is even?'), findsOneWidget);
      expect(find.text('Which number is greater?'), findsOneWidget);
      expect(find.text('Which number is smaller?'), findsOneWidget);

      await harness.reconstruct(
        disposeAppTree: () async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        },
      );

      await harness.pumpProductionApp(tester);
      await tester.pumpAndSettle();

      await _expectPersistedQuizState(harness, fixedNow);

      final content = harness.providerContainer.read(contentRepositoryProvider);
      expect(
        await content.questionById(ReleaseTestContentIds.question1),
        isNotNull,
      );
    },
  );
}

Future<void> _answerVisibleFixtureQuestion(WidgetTester tester) async {
  if (find.text('Which number is even?').evaluate().isNotEmpty) {
    await tester.tap(find.text('3'));
    return;
  }
  if (find.text('Which number is greater?').evaluate().isNotEmpty) {
    await tester.tap(find.text('9'));
    return;
  }
  if (find.text('Which number is smaller?').evaluate().isNotEmpty) {
    await tester.tap(find.text('2'));
    return;
  }

  fail('No deterministic release fixture question is visible.');
}

Future<void> _expectPersistedQuizState(
  ReleaseHarness harness,
  DateTime fixedNow,
) async {
  final attempts = harness.providerContainer.read(attemptsRepositoryProvider);
  final review = harness.providerContainer.read(reviewStateRepositoryProvider);

  expect(await attempts.countForExam(ReleaseTestContentIds.exam), 1);
  expect(
    await attempts.recentIncorrects(
      examId: ReleaseTestContentIds.exam,
      now: fixedNow,
      window: const Duration(days: 30),
    ),
    <String>[ReleaseTestContentIds.question1],
  );

  final outcomes = await attempts.questionOutcomes(
    examId: ReleaseTestContentIds.exam,
    now: fixedNow,
  );
  expect(outcomes[ReleaseTestContentIds.question1]?.attempts, 1);
  expect(outcomes[ReleaseTestContentIds.question1]?.correct, 0);
  expect(outcomes[ReleaseTestContentIds.question2]?.correct, 1);
  expect(outcomes[ReleaseTestContentIds.question3]?.correct, 1);

  expect(await review.byQuestionId(ReleaseTestContentIds.question1), isNotNull);
  expect(await review.byQuestionId(ReleaseTestContentIds.question2), isNotNull);
  expect(await review.byQuestionId(ReleaseTestContentIds.question3), isNotNull);

  final tally = await attempts.tallyForDay(
    examId: ReleaseTestContentIds.exam,
    day: fixedNow,
  );
  expect(tally.answered, 3);
  expect(tally.correct, 2);
  final db = harness.appDatabase;
  expect(await db.select(db.reviewLogs).get(), hasLength(3));
}
