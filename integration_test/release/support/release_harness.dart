import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/content_database_opener.dart' as content_db;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/database_opener.dart' as app_db;
import 'package:pantas/core/storage/storage.dart';

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

Future<void> completeOnboardingThroughUi(
  WidgetTester tester, {
  String examName = 'Release E2E Exam',
  String studentName = 'Release Tester',
}) async {
  await tester.tap(find.text('Get started'));
  await tester.pumpAndSettle();

  await tester.drag(
    find.byType(CupertinoPicker),
    const Offset(0, -40),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  await tester.tap(find.textContaining('I agree to the'));
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  await tester.tap(find.text(examName));
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  await tester.tap(find.text("I don't know yet"));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), studentName);
  await tester.pump();
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
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
