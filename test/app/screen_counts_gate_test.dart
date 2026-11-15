import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/screen_counts_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/client_report.dart';

import '../helpers/in_memory_database.dart';

class _Sender implements ClientReportSender {
  final sent = <Map<String, Object?>>[];

  @override
  Future<void> send(Map<String, Object?> payload) async => sent.add(payload);
}

AuthState _signedIn(String uid) => AuthState.signedIn(
      user: AuthUser(
        uid: uid,
        email: '$uid@example.com',
        displayName: uid,
      ),
    );

void main() {
  late AppDatabase db;
  late _Sender sender;
  late ClientReporter reporter;
  late StreamController<AuthState> visitAuth;

  setUp(() {
    db = inMemoryDatabase();
    sender = _Sender();
    reporter = ClientReporter(
      sender: sender,
      context: () => const ClientReportContext(
        build: 'b1',
        visit: 'return',
        browser: 'chrome',
        mobile: true,
        viewportWidth: 390,
      ),
      screenCounts: true,
    );
    ClientReporter.active = reporter;
    addTearDown(() async {
      reporter.dispose();
      await db.close();
    });
  });

  // One container is one visit. The device database outlives it.
  ProviderContainer openVisit({bool flag = true, String uid = 'learner-a'}) {
    final controller = StreamController<AuthState>();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        screenCountsFlagProvider.overrideWithValue(flag),
        authStateProvider.overrideWith((ref) => controller.stream),
      ],
    );
    addTearDown(() {
      container.dispose();
      // Nothing listens when the flag is off, so closing never completes.
      unawaited(controller.close());
    });
    controller.add(_signedIn(uid));
    container.read(screenCountsGateProvider);
    visitAuth = controller;
    return container;
  }

  Future<void> settle() => pumpEventQueue();

  Future<List<Object?>> countedAfter(
    ProviderContainer visit,
    void Function(ClientReporter) act,
  ) async {
    await settle();
    sender.sent.clear();
    act(reporter);
    reporter.pageHidden();
    await settle();
    return [
      for (final report in sender.sent) report['screens'],
    ];
  }

  test('the first visit never counts, even after the notice is shown',
      () async {
    final visit = openVisit();
    await settle();
    expect(reporter.screenCountsAllowed, isFalse);
    reporter.recordScreen('home');
    await visit.read(screenCountsNoticeStoreProvider).markShown('learner-a');
    await settle();
    expect(reporter.screenCountsAllowed, isFalse);
    expect(await countedAfter(visit, (r) => r.recordScreen('study')), isEmpty);
  });

  test('the next visit counts, from the screen it opened on', () async {
    final first = openVisit();
    await settle();
    await first.read(screenCountsNoticeStoreProvider).markShown('learner-a');
    first.dispose();

    reporter
      ..screenCountsAllowed = false
      ..recordScreen('home');
    final second = openVisit();
    await settle();
    expect(reporter.screenCountsAllowed, isTrue);
    final counted = await countedAfter(second, (r) => r.recordScreen('study'));
    final entries = (counted.single! as List).cast<Map<String, Object?>>();
    expect(entries.map((e) => e['s']), containsAll(['home', 'study']));
  });

  test('another learner on the same device is not counted until shown',
      () async {
    final first = openVisit();
    await settle();
    await first.read(screenCountsNoticeStoreProvider).markShown('learner-a');
    first.dispose();

    final second = openVisit(uid: 'learner-b');
    await settle();
    expect(reporter.screenCountsAllowed, isFalse);
    await second.read(screenCountsNoticeStoreProvider).markShown('learner-b');
    second.dispose();

    final third = openVisit(uid: 'learner-b');
    await settle();
    expect(reporter.screenCountsAllowed, isTrue);
    third.dispose();
  });

  test('signing in as another learner closes and reopens the gate', () async {
    final first = openVisit();
    await settle();
    await first.read(screenCountsNoticeStoreProvider).markShown('learner-a');
    first.dispose();

    final second = openVisit();
    await settle();
    expect(reporter.screenCountsAllowed, isTrue);
    visitAuth.add(_signedIn('learner-b'));
    await settle();
    expect(reporter.screenCountsAllowed, isFalse);
    visitAuth.add(_signedIn('learner-a'));
    await settle();
    expect(reporter.screenCountsAllowed, isTrue);
    second.dispose();
  });

  test('signed out closes the gate', () async {
    final first = openVisit();
    await settle();
    await first.read(screenCountsNoticeStoreProvider).markShown('learner-a');
    first.dispose();

    final second = openVisit();
    await settle();
    visitAuth.add(const AuthState.signedOut());
    await settle();
    expect(reporter.screenCountsAllowed, isFalse);
    second.dispose();
  });

  test('with the flag off the gate stays closed', () async {
    final first = openVisit();
    await settle();
    await first.read(screenCountsNoticeStoreProvider).markShown('learner-a');
    first.dispose();

    final second = openVisit(flag: false);
    await settle();
    expect(reporter.screenCountsAllowed, isFalse);
    second.dispose();
  });
}
