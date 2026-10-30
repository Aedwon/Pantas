import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import 'support/release_harness.dart';
import 'support/test_content_fixture.dart';
import 'support/test_content_seed.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'mock lifecycle interruption reconstructs and resumes the same attempt',
    (tester) async {
      final buildRoot =
          await Directory.systemTemp.createTemp('pantas-release-e2e-mock-');
      addTearDown(() async {
        if (buildRoot.existsSync()) {
          await buildRoot.delete(recursive: true);
        }
      });

      final installation = await installReleaseTestContent(
        buildDirectory: Directory('${buildRoot.path}/fixture'),
      );
      await installation.dispose();

      final harness = ReleaseHarness(
        openContentDatabase: installation.openInstalledContent,
        additionalOverrides: <Override>[releaseTestCatalogOverride],
      );
      addTearDown(harness.dispose);
      await harness.openDatabases();
      await harness.pumpProductionApp(tester);
      await completeOnboardingThroughUi(tester);

      unawaited(
        harness.providerContainer.read(routerProvider).push<void>(
              '/quiz/mock/start?examId=${ReleaseTestContentIds.exam}'
              '&blueprintId=${ReleaseTestContentIds.mockBlueprint}',
            ),
      );
      await tapReleaseControl(tester, find.text('Start the Paper'));
      await _waitForSession(tester);

      final repo = harness.providerContainer.read(mockAttemptRepoProvider);
      final started = await repo.findInProgress(mockAttemptLocalUserId);
      expect(started, isNotNull);
      final attemptId = started!.id;

      await _answerCurrent(tester);
      await tester.tap(find.byKey(const ValueKey('mock-next')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('mock-flag')));
      await tester.pump();
      await _answerCurrent(tester);
      await tester.tap(find.byKey(const ValueKey('mock-next')));
      await tester.pump();

      await waitUntil(
        () async {
          await tester.pump();
          final page = _sessionPage(tester);
          return page.state.currentIndex == 2 && page.state.elapsedSeconds >= 1;
        },
        deadline: DateTime.now().add(const Duration(seconds: 5)),
        diagnostics: () => 'mock timer did not advance on question 3',
      );

      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      MockAttempt? persisted;
      MockSessionSnapshot? persistedSnapshot;
      await waitUntil(
        () async {
          persisted = await repo.findById(attemptId);
          final attempt = persisted;
          if (attempt == null) return false;
          final snapshot = const MockSessionSnapshotCodec().decode(
            sampledQuestionsJson: attempt.sampledQuestionsJson,
            answersJson: attempt.answersJson,
            flagsJson: attempt.flagsJson,
          );
          persistedSnapshot = snapshot;
          return attempt.currentIndex == 2 &&
              attempt.elapsedSeconds >= 1 &&
              snapshot.answers.length >= 2 &&
              snapshot.flags.isNotEmpty;
        },
        deadline: DateTime.now().add(const Duration(seconds: 5)),
        diagnostics: () =>
            'paused mock snapshot was not persisted for attempt $attemptId',
      );

      final savedAttempt = persisted!;
      final savedSnapshot = persistedSnapshot!;
      expect(savedAttempt.status, MockAttemptStatus.inProgress);

      await harness.reconstruct(
        disposeAppTree: () async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        },
      );
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await harness.pumpProductionApp(tester);

      final reopenedRepo =
          harness.providerContainer.read(mockAttemptRepoProvider);
      final reopened = await reopenedRepo.findById(attemptId);
      expect(reopened, isNotNull);
      expect(reopened!.answersJson, savedAttempt.answersJson);
      expect(reopened.flagsJson, savedAttempt.flagsJson);
      expect(reopened.currentIndex, savedAttempt.currentIndex);
      expect(reopened.elapsedSeconds, savedAttempt.elapsedSeconds);

      unawaited(
        harness.providerContainer
            .read(routerProvider)
            .push<void>('/quiz/mock/resume/$attemptId'),
      );
      await waitUntil(
        () async {
          await tester.pump();
          return find.text('Resume').hitTestable().evaluate().length == 1;
        },
        deadline: DateTime.now().add(const Duration(seconds: 10)),
        diagnostics: () => 'reconstructed mock did not show its pause screen',
      );
      await tester.tap(find.text('Resume'));
      await _waitForSession(tester);

      final resumedPage = _sessionPage(tester);
      expect(resumedPage.state.attemptId, attemptId);
      expect(resumedPage.state.currentIndex, savedAttempt.currentIndex);
      expect(resumedPage.state.answers, savedSnapshot.answers);
      expect(resumedPage.state.flags, savedSnapshot.flags);
      expect(
        resumedPage.state.elapsedSeconds,
        greaterThanOrEqualTo(savedAttempt.elapsedSeconds),
      );

      await _answerCurrent(tester);
      await tester.tap(find.byKey(const ValueKey('mock-next')));
      await tester.pump();
      expect(find.text('Submit the exam?'), findsOneWidget);
      await tester.tap(find.text('Submit'));

      await waitUntil(
        () async {
          await tester.pump();
          return find.byType(MockResultsPage).evaluate().isNotEmpty;
        },
        deadline: DateTime.now().add(const Duration(seconds: 30)),
        diagnostics: () =>
            'production mock results did not open for $attemptId',
      );

      MockAttempt? completed;
      await waitUntil(
        () async {
          completed = await reopenedRepo.findById(attemptId);
          return completed?.status == MockAttemptStatus.completed;
        },
        deadline: DateTime.now().add(const Duration(seconds: 5)),
        diagnostics: () => 'mock attempt $attemptId was not completed',
      );
      expect(completed!.id, attemptId);
      expect(completed!.scoreRaw, isNotNull);
      expect(completed!.scoreTotal, 3);
      expect(
        completed!.totalTimeSeconds,
        greaterThanOrEqualTo(savedAttempt.elapsedSeconds),
      );
    },
  );
}

Future<void> _waitForSession(WidgetTester tester) => waitUntil(
      () async {
        await tester.pump();
        return find.byType(MockSessionPage).evaluate().isNotEmpty;
      },
      deadline: DateTime.now().add(const Duration(seconds: 5)),
      diagnostics: () => 'production mock session did not become visible',
    );

MockSessionPage _sessionPage(WidgetTester tester) =>
    tester.widget<MockSessionPage>(find.byType(MockSessionPage));

Future<void> _answerCurrent(WidgetTester tester) async {
  expect(find.byType(ChoiceRow), findsNWidgets(2));
  await tester.tap(find.byType(ChoiceRow).first);
  await tester.pump();
}
