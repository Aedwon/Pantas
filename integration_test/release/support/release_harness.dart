import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/content_database_opener.dart' as content_db;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/database_opener.dart' as app_db;
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/list_row.dart';

typedef ReleaseAppDatabaseOpener = Future<AppDatabase> Function();
typedef ReleaseContentDatabaseOpener = Future<ContentDatabase> Function();
typedef ReleaseAppTreeDisposer = Future<void> Function();

final class ReleaseHarness {
  ReleaseHarness({
    ReleaseAppDatabaseOpener openAppDatabase = app_db.openEncryptedDatabase,
    ReleaseContentDatabaseOpener openContentDatabase =
        content_db.openContentDatabase,
    List<Override> additionalOverrides = const <Override>[],
  })  : _openAppDatabase = openAppDatabase,
        _openContentDatabase = openContentDatabase,
        _additionalOverrides = List<Override>.unmodifiable(additionalOverrides);

  final ReleaseAppDatabaseOpener _openAppDatabase;
  final ReleaseContentDatabaseOpener _openContentDatabase;
  final List<Override> _additionalOverrides;

  AppDatabase? _appDatabase;
  ContentDatabase? _contentDatabase;
  ProviderContainer? _providerContainer;

  AppDatabase get appDatabase =>
      _appDatabase ?? (throw StateError('Release harness is not open.'));

  ContentDatabase get contentDatabase =>
      _contentDatabase ?? (throw StateError('Release harness is not open.'));

  ProviderContainer get providerContainer =>
      _providerContainer ?? (throw StateError('Release harness is not open.'));

  Future<void> openDatabases() async {
    if (_appDatabase != null ||
        _contentDatabase != null ||
        _providerContainer != null) {
      throw StateError('Release harness is already open.');
    }

    final appDatabase = await _openAppDatabase();
    ContentDatabase? contentDatabase;
    try {
      contentDatabase = await _openContentDatabase();
      final providerContainer = ProviderContainer(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(appDatabase),
          contentDatabaseProvider.overrideWithValue(contentDatabase),
          authStateProvider.overrideWith(
            (_) => Stream.value(
              const AuthState.anonymous(uid: 'release-e2e-anonymous'),
            ),
          ),
          ..._additionalOverrides,
        ],
      );
      _appDatabase = appDatabase;
      _contentDatabase = contentDatabase;
      _providerContainer = providerContainer;
    } catch (_) {
      await contentDatabase?.close();
      await appDatabase.close();
      rethrow;
    }
  }

  Widget buildProductionApp({Flavor flavor = Flavor.dev}) =>
      UncontrolledProviderScope(
        container: providerContainer,
        child: App(flavor: flavor),
      );

  Future<void> pumpProductionApp(
    WidgetTester tester, {
    Flavor flavor = Flavor.dev,
  }) async {
    await tester.pumpWidget(buildProductionApp(flavor: flavor));
    await tester.pump();
  }

  Future<T> readPersisted<T>(
    Future<T> Function(ProviderContainer container) read,
  ) =>
      read(providerContainer);

  Future<void> reconstruct({
    required ReleaseAppTreeDisposer disposeAppTree,
  }) async {
    await disposeAppTree();
    await _closeDatabases();
    await openDatabases();
  }

  Future<void> dispose() => _closeDatabases();

  Future<void> _closeDatabases() async {
    final providerContainer = _providerContainer;
    final contentDatabase = _contentDatabase;
    final appDatabase = _appDatabase;
    _providerContainer = null;
    _contentDatabase = null;
    _appDatabase = null;

    providerContainer?.dispose();
    await contentDatabase?.close();
    await appDatabase?.close();
  }
}

Future<void> tapReleaseControl(WidgetTester tester, Finder target) async {
  await waitUntil(
    () async {
      await tester.pump(const Duration(milliseconds: 50));
      return target.evaluate().length == 1;
    },
    deadline: DateTime.now().add(const Duration(seconds: 10)),
    diagnostics: () => 'waiting for $target',
    delay: tester.pump,
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> completeOnboardingThroughUi(
  WidgetTester tester, {
  String examId = 'release-e2e-exam',
  String studentName = 'Release Tester',
}) async {
  Finder within(String step, Finder target) => find.descendant(
        of: find.byKey(ValueKey<String>(step)),
        matching: target,
      );
  Future<void> tap(String step, String label) =>
      tapReleaseControl(tester, within(step, find.text(label)));

  await tap('welcome', 'Get Started');
  // The birth-year wheel starts at age 14. Continue through the real age gate.
  await tap('ageGate', 'Continue');
  await tapReleaseControl(
    tester,
    within(
      'consent',
      find.byWidgetPredicate(
        (widget) =>
            widget is ListRow &&
            widget.title ==
                'I agree to the Terms of Service and Privacy Policy.',
      ),
    ),
  );
  await tap('consent', 'Continue');
  final exam = within('picker', find.byKey(ValueKey('exam-$examId')));
  await waitUntil(
    () async {
      await tester.pump();
      return exam.evaluate().isNotEmpty;
    },
    deadline: DateTime.now().add(const Duration(seconds: 10)),
    diagnostics: () => 'waiting for exam $examId',
    delay: tester.pump,
  );
  await tapReleaseControl(tester, exam);
  await tap('picker', 'Continue');
  // Published dates may show a confirmation first. Choose an unknown date.
  await tester.pumpAndSettle();
  final differentDate = within('examDate', find.text('Different Date'));
  if (differentDate.evaluate().isNotEmpty) {
    await tapReleaseControl(tester, differentDate);
  }
  await tap('examDate', "I don't know");
  await tapReleaseControl(
    tester,
    within('studyDays', find.byKey(const ValueKey('study-day-1'))),
  );
  await tap('studyDays', 'Continue');
  final name = within('name', find.byType(TextField));
  await tester.enterText(name, studentName);
  await tester.pump();
  await tap('name', 'Done');
}

Future<void> waitUntil(
  FutureOr<bool> Function() predicate, {
  required DateTime deadline,
  required String Function() diagnostics,
  Duration pollInterval = const Duration(milliseconds: 50),
  DateTime Function()? now,
  Future<void> Function(Duration)? delay,
}) async {
  if (pollInterval <= Duration.zero) {
    throw ArgumentError.value(
      pollInterval,
      'pollInterval',
      'must be greater than zero',
    );
  }

  final readNow = now ?? DateTime.now;
  final wait = delay ?? Future<void>.delayed;

  while (true) {
    if (await predicate()) return;

    final current = readNow();
    if (!current.isBefore(deadline)) {
      throw TimeoutException(
        'waitUntil deadline ${deadline.toIso8601String()} reached: '
        '${diagnostics()}',
      );
    }

    final remaining = deadline.difference(current);
    await wait(remaining < pollInterval ? remaining : pollInterval);
  }
}
