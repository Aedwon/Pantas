import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/platform/report_providers.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/storage.dart';

import '../../helpers/in_memory_database.dart';

class _Sender implements ReportSender {
  final sent = <String>[];
  @override
  Future<void> send(QuestionReport report) async => sent.add(report.message);
}

Future<void> _flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
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
    await container
        .read(reportQueueProvider)
        .add('q1', 'Queued before start', DateTime(2026, 11, 23));
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
