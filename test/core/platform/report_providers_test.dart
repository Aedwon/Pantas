import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/platform/report_providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/storage.dart';

import '../../helpers/in_memory_database.dart';

class _Sender implements ReportSender {
  final sent = <String>[];
  @override
  Future<void> send(QuestionReport report) async => sent.add(report.message);
}

Future<void> _flush() async {
  // Storage answers on later turns of the event loop.
  await Future<void>.delayed(const Duration(milliseconds: 200));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, _Sender, StreamController<AuthState>)> start(
    AuthState first,
  ) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Sender();
    final auth = StreamController<AuthState>();
    addTearDown(auth.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        reportSenderProvider.overrideWithValue(sender),
        authStateProvider.overrideWith((ref) => auth.stream),
      ],
    );
    addTearDown(container.dispose);
    // Queued earlier, by the guest, before the app started.
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: ReportQueue.storageKey,
            value: '[{"id":"report-id-0000000000000001","accountId":"guest", '
                '"questionId":"q1","message":"Queued before start", '
                '"createdAt":"2026-11-23T00:00:00.000"}]',
          ),
        );
    container.read(reportSyncProvider);
    auth.add(first);
    await _flush();
    return (container, sender, auth);
  }

  test('a signed-in account sends what was queued at start', () async {
    final (_, sender, _) = await start(
      const AnonymousAuthState(uid: 'guest'),
    );
    expect(sender.sent, ['Queued before start']);
  });

  test('with nobody signed in nothing is sent, then it is on sign-in',
      () async {
    final (_, sender, auth) = await start(const SignedOutAuthState());
    expect(sender.sent, isEmpty);
    auth.add(const AnonymousAuthState(uid: 'guest'));
    await _flush();
    expect(sender.sent, ['Queued before start']);
  });

  test('returning to the app sends what was queued meanwhile', () async {
    final (container, sender, _) = await start(
      const AnonymousAuthState(uid: 'guest'),
    );
    await container
        .read(reportQueueProvider)
        .add('q2', 'Queued later', DateTime(2026, 11, 23));
    expect(sender.sent, hasLength(1));
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await _flush();
    expect(sender.sent, ['Queued before start', 'Queued later']);
  });

  test('a guest who becomes another account keeps its unsent reports hidden',
      () async {
    final (container, sender, auth) = await start(
      const AnonymousAuthState(uid: 'guest'),
    );
    await container
        .read(reportQueueProvider)
        .add('q2', 'Guest second', DateTime(2026, 11, 23));
    auth.add(const SignedOutAuthState());
    await _flush();
    auth.add(
      const SignedInAuthState(
        user: AuthUser(uid: 'named', email: 'n@example.com', displayName: ''),
      ),
    );
    await _flush();
    final queue = container.read(reportQueueProvider);
    expect(await queue.history(), isEmpty, reason: 'scoped to the account');
    expect(sender.sent, ['Queued before start']);
    // The guest's unsent report is not deleted because the account changed
    // (another tab may have switched it); only the sign-out wipe removes it.
    auth.add(const AnonymousAuthState(uid: 'guest'));
    await _flush();
    expect(sender.sent, ['Queued before start', 'Guest second']);
  });

  test('old reports are never sent, even to the account that owned the device',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: ReportQueue.storageKey,
            value: '[{"questionId":"q","message":"Old",'
                '"createdAt":"2026-11-20T09:00:00.000"}]',
          ),
        );
    await db.customStatement(
      'insert into sync_meta (key,value) '
      "values ('local_data_owner_uid','owner-a')",
    );
    final sender = _Sender();
    final auth = StreamController<AuthState>();
    addTearDown(auth.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        reportSenderProvider.overrideWithValue(sender),
        authStateProvider.overrideWith((ref) => auth.stream),
      ],
    );
    addTearDown(container.dispose);
    container.read(reportSyncProvider);
    auth.add(const AnonymousAuthState(uid: 'owner-b'));
    await _flush();
    expect(sender.sent, isEmpty);
    auth.add(const AnonymousAuthState(uid: 'owner-a'));
    await _flush();
    expect(sender.sent, isEmpty);
  });

  test('after the container is gone, returning to the app does nothing',
      () async {
    final (container, sender, _) = await start(
      const AnonymousAuthState(uid: 'guest'),
    );
    container.dispose();
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await _flush();
    expect(sender.sent, hasLength(1));
  });
}
