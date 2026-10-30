import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import 'support/release_harness.dart';
import 'support/test_content_fixture.dart';
import 'support/test_content_seed.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'quick quiz persists attempt, review, mistake, and progress state '
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

      final fixedNow = DateTime(2026, 9, 6, 9);
      final harness = ReleaseHarness(
        additionalOverrides: <Override>[
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

      await _completeReleaseOnboarding(tester);
      if (find.text('Not right now').evaluate().isNotEmpty) {
        await tester.tap(find.text('Not right now'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Build your study plan'), findsOneWidget);
      await tester.tap(find.text('Try a quick quiz'));
      await tester.pumpAndSettle();

      for (var answered = 0; answered < 3; answered += 1) {
        await _answerVisibleFixtureQuestion(tester);
        await tester.pumpAndSettle();

        final done = find.text('Done').evaluate().isNotEmpty;
        final next = find.text('Next').evaluate().isNotEmpty;
        expect(done || next, isTrue);
        await tester.tap(done ? find.text('Done') : find.text('Next'));
        await tester.pumpAndSettle();
      }

      await _waitForUnique(
        tester,
        find.text('To come back to'),
        diagnostics: 'waiting for quiz debrief',
      );
      expect(find.text('To come back to'), findsOneWidget);
      expect(find.text('Which number is even?'), findsOneWidget);

      await _expectPersistedQuizState(harness, fixedNow);

      await _tapVisible(
        tester,
        find.text('Go through all 3'),
        diagnostics: 'waiting for Go through all 3',
      );
      await tester.pumpAndSettle();
      expect(find.text('All questions'), findsOneWidget);
      await _tapVisible(
        tester,
        find.text('All 3'),
        diagnostics: 'waiting for All 3 review filter',
      );
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

Finder _step(String key) => find.byKey(ValueKey<String>(key));

Finder _within(Finder root, Finder target) =>
    find.descendant(of: root, matching: target);

Finder _enabledBoardButton(Finder root, String label) => find.descendant(
      of: root,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is BoardButton &&
            widget.label == label &&
            widget.onPressed != null,
      ),
    );

Future<void> _waitForUnique(
  WidgetTester tester,
  Finder finder, {
  required String diagnostics,
  bool hitTestable = false,
}) async {
  var matches = 0;
  var hitTestableMatches = 0;
  await waitUntil(
    () {
      matches = finder.evaluate().length;
      hitTestableMatches = finder.hitTestable().evaluate().length;
      return matches == 1 && (!hitTestable || hitTestableMatches == 1);
    },
    deadline: DateTime.now().add(const Duration(seconds: 5)),
    diagnostics: () => '$diagnostics matches=$matches '
        'hitTestable=$hitTestableMatches',
    delay: tester.pump,
  );
}

Future<void> _tapVisible(
  WidgetTester tester,
  Finder target, {
  required String diagnostics,
}) async {
  await _waitForUnique(tester, target, diagnostics: diagnostics);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await _waitForUnique(
    tester,
    target,
    diagnostics: diagnostics,
    hitTestable: true,
  );
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _completeReleaseOnboarding(WidgetTester tester) async {
  final welcome = _step('welcome');
  await _waitForUnique(
    tester,
    welcome,
    diagnostics: 'waiting for welcome step',
  );
  await _tapVisible(
    tester,
    _enabledBoardButton(welcome, 'Get started'),
    diagnostics: 'waiting for welcome Get started',
  );

  final ageGate = _step('ageGate');
  await _waitForUnique(
    tester,
    ageGate,
    diagnostics: 'waiting for age gate step',
  );
  final yearPicker = _within(ageGate, find.byType(CupertinoPicker));
  await _waitForUnique(
    tester,
    yearPicker,
    diagnostics: 'waiting for age gate year picker',
    hitTestable: true,
  );
  await tester.drag(yearPicker, const Offset(0, -40));
  await tester.pumpAndSettle();
  await _tapVisible(
    tester,
    _enabledBoardButton(ageGate, 'Continue'),
    diagnostics: 'waiting for age gate Continue',
  );

  final consent = _step('consent');
  await _waitForUnique(
    tester,
    consent,
    diagnostics: 'waiting for consent step',
  );
  await _tapVisible(
    tester,
    _within(consent, find.textContaining('I agree to the')),
    diagnostics: 'waiting for consent terms control',
  );
  await _tapVisible(
    tester,
    _enabledBoardButton(consent, 'Continue'),
    diagnostics: 'waiting for consent Continue',
  );

  final picker = _step('picker');
  await _waitForUnique(
    tester,
    picker,
    diagnostics: 'waiting for exam picker step',
  );
  final exam = _within(picker, find.text('Release E2E Exam'));
  if (exam.hitTestable().evaluate().length != 1) {
    final examList = _within(picker, find.byType(ListView));
    await _waitForUnique(
      tester,
      examList,
      diagnostics: 'waiting for exam list',
      hitTestable: true,
    );
    await tester.dragUntilVisible(
      exam,
      examList,
      const Offset(0, -240),
      maxIteration: 20,
    );
    await tester.pumpAndSettle();
  }
  await _tapVisible(
    tester,
    exam,
    diagnostics: 'waiting for Release E2E Exam',
  );
  await _tapVisible(
    tester,
    _enabledBoardButton(picker, 'Continue'),
    diagnostics: 'waiting for exam picker Continue',
  );

  final examDate = _step('examDate');
  await _waitForUnique(
    tester,
    examDate,
    diagnostics: 'waiting for exam date step',
  );
  await _tapVisible(
    tester,
    _within(examDate, find.text("I don't know yet")),
    diagnostics: 'waiting for exam date skip control',
  );

  final name = _step('name');
  await _waitForUnique(tester, name, diagnostics: 'waiting for name step');
  final nameField = _within(name, find.byType(TextField));
  await _waitForUnique(
    tester,
    nameField,
    diagnostics: 'waiting for onboarding name field',
    hitTestable: true,
  );
  await tester.enterText(nameField, 'Release Tester');
  await tester.pump();
  await _tapVisible(
    tester,
    _enabledBoardButton(name, 'Done'),
    diagnostics: 'waiting for onboarding Done',
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
}
