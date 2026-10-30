import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/core/content/bundle/seed_installer.dart';
import 'package:pantas/core/content/content_seed_version.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';

import 'support/release_harness.dart';

const _candidate = String.fromEnvironment('RELEASE_E2E_CANDIDATE');
const _contentSha = String.fromEnvironment('RELEASE_E2E_CONTENT_SHA');
const _localOnly = bool.fromEnvironment('RELEASE_E2E_LOCAL_ONLY');

const _examName = 'Civil Service Examination — Professional';
const _topicName = 'Vocabulary';
const _lessonId = 'les_vocab_context';
const _lessonTitle = 'Reading Context Clues';

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
  await waitUntil(
    () async {
      await tester.pump();
      if (finder.evaluate().length != 1) return false;
      return !hitTestable || finder.hitTestable().evaluate().length == 1;
    },
    deadline: DateTime.now().add(const Duration(seconds: 5)),
    diagnostics: () => '$diagnostics '
        'matches=${finder.evaluate().length} '
        'hitTestable=${finder.hitTestable().evaluate().length}',
    delay: (duration) => tester.runAsync(
      () => Future<void>.delayed(duration),
    ),
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

Future<void> _completeShippingOnboarding(
  WidgetTester tester, {
  required String examName,
  required String studentName,
}) async {
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
  final exam = _within(picker, find.text(examName));
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
    diagnostics: 'waiting for shipping exam $examName',
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
  await tester.enterText(nameField, studentName);
  await tester.pump();
  await _tapVisible(
    tester,
    _enabledBoardButton(name, 'Done'),
    diagnostics: 'waiting for onboarding Done',
  );
}

Future<void> _openShippingLessonFromStudy(WidgetTester tester) async {
  await _tapVisible(
    tester,
    find.text('Study').last,
    diagnostics: 'waiting for Study tab',
  );

  final studyList = find.byType(ListView);
  await _waitForUnique(
    tester,
    studyList,
    diagnostics: 'waiting for Study topic list',
    hitTestable: true,
  );

  final topic = find.text(_topicName);
  await tester.dragUntilVisible(
    topic,
    studyList,
    const Offset(0, -240),
    maxIteration: 20,
  );
  await tester.pumpAndSettle();
  await _tapVisible(
    tester,
    topic,
    diagnostics: 'waiting for shipping topic $_topicName',
  );
  await _tapVisible(
    tester,
    find.text(_lessonTitle),
    diagnostics: 'waiting for shipping lesson $_lessonTitle',
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shipping cold start persists lesson read state offline',
      (tester) async {
    expect(
      _candidate,
      '6080897422db0aa3314ac4143c76d8f0fb96df9a',
      reason: 'runner must expose the exact release candidate to the journey',
    );
    expect(
      _contentSha,
      'eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45',
      reason: 'runner must expose the exact approved shipping content digest',
    );
    expect(
      _localOnly,
      isTrue,
      reason: 'shipping journey must reject network-dependent services',
    );
    expect(contentSeedVersion, 'eb3a9da425b80a51');

    await SeedInstaller().install(
      installedVersion: null,
      bundledVersion: contentSeedVersion,
    );

    final harness = ReleaseHarness();
    await harness.openDatabases();
    try {
      final content = harness.providerContainer.read(contentRepositoryProvider);
      final shippingExam = (await content.listExams()).singleWhere(
        (exam) => exam.name == _examName,
      );
      expect(shippingExam.isActive, isTrue);

      final shippingLesson = await content.lessonById(_lessonId);
      expect(shippingLesson?.title, _lessonTitle);
      expect(shippingLesson?.bodyJson, isNotEmpty);

      await harness.pumpProductionApp(tester);
      await tester.pumpAndSettle();
      await _completeShippingOnboarding(
        tester,
        examName: _examName,
        studentName: 'Release Shipping',
      );

      final skipNotificationRationale = find.text('Not right now');
      if (skipNotificationRationale.evaluate().isNotEmpty) {
        await tester.tap(skipNotificationRationale);
        await tester.pumpAndSettle();
      }

      expect(find.text('Study'), findsWidgets);
      await _openShippingLessonFromStudy(tester);
      expect(find.text(_lessonTitle), findsWidgets);

      final progress =
          harness.providerContainer.read(lessonProgressRepositoryProvider);
      final reader = find.byType(SingleChildScrollView);
      await tester.dragUntilVisible(
        find.textContaining('min read'),
        reader,
        const Offset(0, -320),
      );
      await tester.pump();

      final scrollController =
          tester.widget<SingleChildScrollView>(reader).controller;
      expect(scrollController, isNotNull);
      for (var attempt = 0;
          attempt < 30 && scrollController!.position.extentAfter > 1;
          attempt++) {
        // Finish the real reader scroll with bounded gestures. Keep each
        // gesture small so the pull-to-advance affordance cannot be armed.
        await tester.drag(reader, const Offset(0, -40));
        await tester.pumpAndSettle();
      }
      expect(
        scrollController!.position.extentAfter,
        lessThanOrEqualTo(1),
        reason: 'reader must reach its real end through production scrolling',
      );

      await waitUntil(
        () async {
          if (await progress.isRead(_lessonId)) return true;

          // The production reader marks read only after its dwell floor and a
          // scroll observation at the real end. Keep driving the actual
          // reader toward its clamped max extent instead of mutating storage.
          await tester.drag(reader, const Offset(0, -2000));
          await tester.pump();
          return progress.isRead(_lessonId);
        },
        deadline: DateTime.now().add(const Duration(seconds: 25)),
        diagnostics: () => 'lesson=$_lessonId '
            'routeTitle='
            '${find.text(_lessonTitle).evaluate().length}',
        pollInterval: const Duration(milliseconds: 100),
        delay: (duration) => tester.runAsync(
          () => Future<void>.delayed(duration),
        ),
      );
      expect(await progress.isRead(_lessonId), isTrue);

      await harness.reconstruct(
        disposeAppTree: () async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        },
      );
      await harness.pumpProductionApp(tester);
      await tester.pumpAndSettle();

      expect(find.text('Get started'), findsNothing);
      final reopenedProgress =
          harness.providerContainer.read(lessonProgressRepositoryProvider);
      expect(await reopenedProgress.isRead(_lessonId), isTrue);

      final reopenedContent =
          harness.providerContainer.read(contentRepositoryProvider);
      final reopenedLesson = await reopenedContent.lessonById(_lessonId);
      expect(reopenedLesson?.title, _lessonTitle);
      expect(reopenedLesson?.bodyJson, isNotEmpty);

      await _openShippingLessonFromStudy(tester);
      expect(find.text(_lessonTitle), findsWidgets);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await harness.dispose();
    }
  });
}
