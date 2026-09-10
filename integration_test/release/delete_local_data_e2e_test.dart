import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/local_state_wiper.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/settings.dart';

import 'support/release_harness.dart';
import 'support/test_content_fixture.dart';
import 'support/test_content_seed.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'anonymous Settings deletion wipes local study state but preserves device '
    'preferences and content',
    (tester) async {
      final buildDirectory = Directory.systemTemp.createTempSync(
        'pantas-release-delete-',
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
        ],
      );
      await harness.openDatabases();
      addTearDown(harness.dispose);
      expect(
        await harness.providerContainer.read(isAnonymousProvider.future),
        isTrue,
      );

      await harness.pumpProductionApp(tester);
      await tester.pumpAndSettle();

      await _waitForFinder(
        tester,
        find.text('Get started'),
        'onboarding welcome Get started',
      );
      await completeOnboardingThroughUi(tester);
      if (find.text('Not right now').evaluate().isNotEmpty) {
        await tester.tap(find.text('Not right now'));
        await tester.pumpAndSettle();
      }

      await _bookmarkFixtureLesson(tester, harness);
      await _completeFixtureQuickQuiz(tester);
      await _waitForQuizProgress(harness);

      await _reconstructToHome(tester, harness);
      await _expectProgressPresent(harness);

      await _startFixtureMock(tester, harness);
      await _waitForMockProgress(tester, harness);

      await _reconstructToHome(tester, harness);
      await _expectProgressPresent(harness, includeMock: true);

      final settings =
          harness.providerContainer.read(settingsRepositoryProvider);
      await settings.updateThemePreference(ThemePreference.dark);
      expect(await settings.readThemePreference(), ThemePreference.dark);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Account'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Account'), findsOneWidget);
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.text('Delete my data'), findsOneWidget);

      await tester.tap(find.text('Delete my data'));
      await tester.pumpAndSettle();
      expect(find.text('Delete your data?'), findsOneWidget);
      expect(
        find.text(
          'Your progress on this device will be permanently deleted. '
          'Sign in first if you want to keep it.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Yes, delete my data'));
      await tester.pump();
      await _waitForLocalDeletion(harness);
      await tester.pumpAndSettle();
      expect(find.text('Deletion request completed.'), findsOneWidget);

      await _expectProgressGone(harness);
      expect(
        await harness.providerContainer
            .read(settingsRepositoryProvider)
            .readThemePreference(),
        ThemePreference.dark,
      );
      expect(
        await harness.providerContainer
            .read(contentRepositoryProvider)
            .questionById(ReleaseTestContentIds.question1),
        isNotNull,
      );

      await _reconstructToHome(tester, harness);
      await _expectProgressGone(harness);
      expect(
        await harness.providerContainer
            .read(settingsRepositoryProvider)
            .readThemePreference(),
        ThemePreference.dark,
      );
      expect(
        await harness.providerContainer
            .read(contentRepositoryProvider)
            .questionById(ReleaseTestContentIds.question1),
        isNotNull,
      );
      expect(find.text('Home'), findsOneWidget);
    },
  );
}

Future<void> _bookmarkFixtureLesson(
  WidgetTester tester,
  ReleaseHarness harness,
) async {
  await tester.tap(find.text('Study'));
  await tester.pumpAndSettle();

  await _waitForFinder(
    tester,
    find.text('Release E2E Topic'),
    'study map Release E2E topic',
  );

  await tester.tap(find.text('Release E2E Topic'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Release E2E Lesson'));
  await tester.pumpAndSettle();

  expect(find.text('Read this deterministic release lesson.'), findsOneWidget);
  await tester.tap(find.bySemanticsLabel('Bookmark lesson'));
  await tester.pump();

  var bookmarkCount = 0;
  await waitUntil(
    () async {
      bookmarkCount = (await harness.appDatabase
              .select(harness.appDatabase.lessonBookmarksLocal)
              .get())
          .length;
      return bookmarkCount == 1;
    },
    deadline: DateTime.now().add(const Duration(seconds: 5)),
    diagnostics: () => 'lesson bookmark count=$bookmarkCount',
  );

  await tester.pumpAndSettle();
  await _waitForFinder(
    tester,
    find.bySemanticsLabel('Remove lesson bookmark'),
    'bookmarked lesson action',
  );
  expect(find.bySemanticsLabel('Remove lesson bookmark'), findsOneWidget);
  await tester.tap(find.bySemanticsLabel('Back to Study'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Home'));
  await tester.pumpAndSettle();
}

Future<void> _completeFixtureQuickQuiz(WidgetTester tester) async {
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

  expect(find.text('To come back to'), findsOneWidget);
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
  fail('Expected one of the deterministic Release E2E quiz questions.');
}

Future<void> _waitForQuizProgress(ReleaseHarness harness) async {
  var diagnostics = 'quiz progress not read yet';
  await waitUntil(
    () async {
      final db = harness.appDatabase;
      final attempts = (await db.select(db.attemptsLocal).get()).length;
      final reviews = (await db.select(db.reviewStateLocal).get()).length;
      final logs = (await db.select(db.reviewLogs).get()).length;
      diagnostics = 'attempts=$attempts reviews=$reviews reviewLogs=$logs';
      return attempts > 0 && reviews > 0 && logs > 0;
    },
    deadline: DateTime.now().add(const Duration(seconds: 5)),
    diagnostics: () => diagnostics,
  );
}

Future<void> _startFixtureMock(
  WidgetTester tester,
  ReleaseHarness harness,
) async {
  await tester.tap(find.text('Quiz'));
  await tester.pumpAndSettle();

  await _waitForFinder(tester, find.text('Take the exam'), 'mock take button');
  await tester.tap(find.text('Take the exam'));
  await tester.pumpAndSettle();
  expect(find.text('Release E2E Mock Blueprint'), findsOneWidget);
  expect(find.text('Start mock'), findsOneWidget);

  await tester.tap(find.text('Start mock'));
  await tester.pump();
}

Future<void> _waitForMockProgress(
  WidgetTester tester,
  ReleaseHarness harness,
) async {
  var mockCount = 0;
  await waitUntil(
    () async {
      await tester.pump(const Duration(milliseconds: 20));
      mockCount = (await harness.appDatabase
              .select(harness.appDatabase.mockAttempts)
              .get())
          .length;
      return mockCount == 1;
    },
    deadline: DateTime.now().add(const Duration(seconds: 5)),
    diagnostics: () => 'mock attempt count=$mockCount',
  );
}

Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder,
  String label,
) async {
  var matches = 0;
  await waitUntil(
    () async {
      await tester.pump(const Duration(milliseconds: 20));
      matches = finder.evaluate().length;
      return matches > 0;
    },
    deadline: DateTime.now().add(const Duration(seconds: 5)),
    diagnostics: () => '$label matches=$matches',
  );
}

Future<void> _reconstructToHome(
  WidgetTester tester,
  ReleaseHarness harness,
) async {
  await harness.reconstruct(
    disposeAppTree: () async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
  expect(
    await harness.providerContainer.read(isAnonymousProvider.future),
    isTrue,
  );
  await harness.pumpProductionApp(tester);
  await tester.pumpAndSettle();
  expect(find.text('Home'), findsOneWidget);
}

Future<void> _expectProgressPresent(
  ReleaseHarness harness, {
  bool includeMock = false,
}) async {
  final db = harness.appDatabase;
  expect(await db.select(db.lessonBookmarksLocal).get(), isNotEmpty);
  expect(await db.select(db.attemptsLocal).get(), isNotEmpty);
  expect(await db.select(db.reviewStateLocal).get(), isNotEmpty);
  expect(await db.select(db.reviewLogs).get(), isNotEmpty);
  if (includeMock) {
    expect(await db.select(db.mockAttempts).get(), isNotEmpty);
  }
}

Future<void> _waitForLocalDeletion(ReleaseHarness harness) async {
  var diagnostics = 'deletion state not read yet';
  await waitUntil(
    () async {
      final db = harness.appDatabase;
      final bookmarks = (await db.select(db.lessonBookmarksLocal).get()).length;
      final attempts = (await db.select(db.attemptsLocal).get()).length;
      final reviews = (await db.select(db.reviewStateLocal).get()).length;
      final logs = (await db.select(db.reviewLogs).get()).length;
      final mocks = (await db.select(db.mockAttempts).get()).length;
      diagnostics = 'bookmarks=$bookmarks attempts=$attempts reviews=$reviews '
          'reviewLogs=$logs mocks=$mocks';
      return bookmarks == 0 &&
          attempts == 0 &&
          reviews == 0 &&
          logs == 0 &&
          mocks == 0;
    },
    deadline: DateTime.now().add(const Duration(seconds: 5)),
    diagnostics: () => diagnostics,
  );
}

Future<void> _expectProgressGone(ReleaseHarness harness) async {
  final db = harness.appDatabase;
  expect(await db.select(db.lessonBookmarksLocal).get(), isEmpty);
  expect(await db.select(db.attemptsLocal).get(), isEmpty);
  expect(await db.select(db.reviewStateLocal).get(), isEmpty);
  expect(await db.select(db.reviewLogs).get(), isEmpty);
  expect(await db.select(db.mockAttempts).get(), isEmpty);
  expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isFalse);
}
