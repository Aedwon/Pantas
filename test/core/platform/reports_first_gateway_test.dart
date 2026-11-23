import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/email_link_auth.dart';
import 'package:pantas/core/platform/reports_first_gateway.dart';
import 'package:pantas/core/platform/restorable_email_link_store.dart';
import 'package:pantas/core/storage/data/report_queue.dart';

import '../../helpers/in_memory_database.dart';

class _Sender implements ReportSender {
  final sent = <String>[];
  Exception? failure;
  Future<void> Function()? hang;

  @override
  Future<void> send(QuestionReport report) async {
    final wait = hang;
    if (wait != null) await wait();
    final error = failure;
    if (error != null) throw error;
    sent.add(report.message);
  }
}

class _Inner implements AccountTransitionGateway {
  final calls = <String>[];

  @override
  Future<void> prepareForSignOut() async => calls.add('signOut');

  @override
  Future<void> prepareForAccountSwitch() async => calls.add('switch');

  @override
  Future<void> prepareForDeleteAccount() async => calls.add('delete');
}

Future<
    (
      ReportsFirstTransitionGateway,
      ReportQueue,
      _Sender,
      _Inner,
      List<String>
    )> _build({
  Duration limit = const Duration(seconds: 2),
  bool closed = false,
  void Function()? onRefused,
}) async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final sender = _Sender();
  final queue = ReportQueue(
    db,
    sender: sender,
    account: () => 'acct-a',
    maxAttempts: 1,
    wait: (_) async {},
  );
  final inner = _Inner();
  final logs = <String>[];
  final gateway = ReportsFirstTransitionGateway(
    inner,
    () => queue,
    limit: limit,
    log: logs.add,
    isClosed: (uid) => closed && uid == 'acct-a',
    onRefused: onRefused,
  );
  return (gateway, queue, sender, inner, logs);
}

final _now = DateTime(2026, 11, 24, 10);

Matcher get _connectionError => throwsA(
      isA<AuthGatewayException>()
          .having((e) => e.code, 'code', 'network-request-failed'),
    );

void main() {
  for (final switching in [false, true]) {
    final name = switching ? 'an account switch' : 'sign-out';
    Future<void> run(ReportsFirstTransitionGateway g) =>
        switching ? g.prepareForAccountSwitch() : g.prepareForSignOut();
    final inner = switching ? 'switch' : 'signOut';

    test('$name sends the pending report first, then goes on', () async {
      final (gateway, queue, sender, innerGateway, _) = await _build();
      await queue.add('q', 'A concern', _now);

      await run(gateway);

      expect(sender.sent, ['A concern']);
      expect(innerGateway.calls, [inner]);
    });

    test(
        '$name with a report that cannot be sent is refused, nothing else runs',
        () async {
      final (gateway, queue, sender, innerGateway, _) = await _build();
      sender.failure = Exception('offline');
      await queue.add('q', 'A concern', _now);

      await expectLater(run(gateway), _connectionError);

      expect(innerGateway.calls, isEmpty, reason: 'no teardown started');
      expect((await queue.pending()).single.message, 'A concern');
    });

    test('$name with nobody to send as is refused while a report waits',
        () async {
      final (gateway, queue, sender, innerGateway, _) = await _build();
      sender.failure = const ReportUnavailable();
      await queue.add('q', 'A concern', _now);

      await expectLater(run(gateway), _connectionError);

      expect(innerGateway.calls, isEmpty);
    });

    test('$name with a report the server refused for good is not blocked',
        () async {
      final (gateway, queue, sender, innerGateway, logs) = await _build();
      sender.failure = const ReportRefused('question-limit');
      await queue.add('q', 'A concern', _now);
      await queue.add('q2', 'Another', _now);

      await run(gateway);

      expect(innerGateway.calls, [inner]);
      expect(logs, hasLength(1));
      expect(logs.single, contains('question-limit'));
      expect(logs.single, contains('2'));
    });

    test('$name with nothing pending just goes on, and logs nothing', () async {
      final (gateway, _, _, innerGateway, logs) = await _build();

      await run(gateway);

      expect(innerGateway.calls, [inner]);
      expect(logs, isEmpty);
    });

    test('$name with a send that hangs refuses at the limit', () async {
      final (gateway, queue, sender, innerGateway, _) = await _build(
        limit: const Duration(milliseconds: 80),
      );
      sender.hang = () => Completer<void>().future;
      await queue.add('q', 'A concern', _now);

      await expectLater(
        run(gateway).timeout(const Duration(seconds: 2)),
        _connectionError,
      );

      expect(innerGateway.calls, isEmpty);
    });
  }

  group("with the real sign-out and main's sequence", () {
    Future<(AuthRepository, List<String>, ReportQueue, _Sender)> repo() async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final ops = <String>[];
      final sender = _Sender();
      final queue = ReportQueue(
        db,
        sender: sender,
        account: () => 'acct-a',
        maxAttempts: 1,
        wait: (_) async {},
      );
      final repository = AuthRepository(
        gateway: _Gw(ops),
        googleGateway: _Google(ops),
        functionsGateway: _Functions(),
        accountTransitionGateway: ReportsFirstTransitionGateway(
          _Inner(),
          () => queue,
        ),
        localStateWiper: _Wiper(ops),
      )..beforeIdentityChange = () async {
          ops.add('clearPayment');
        };
      return (repository, ops, queue, sender);
    }

    test('offline with a pending report: refused, no state change', () async {
      final (repository, ops, queue, sender) = await repo();
      sender.failure = Exception('offline');
      await queue.add('q', 'A concern', _now);

      await expectLater(repository.signOut(), _connectionError);

      expect(ops, isEmpty, reason: 'no Pro change, no wipe, no sign-out');
      expect((await queue.pending()).single.message, 'A concern');
    });

    test('a report the server refused does not hold sign-out', () async {
      final (repository, ops, queue, sender) = await repo();
      sender.failure = const ReportRefused('question-limit');
      await queue.add('q', 'A concern', _now);

      await repository.signOut();

      expect(ops, [
        'clearPayment',
        'wipeAll',
        'signOut',
        'googleSignOut',
        'signInAnonymously',
      ]);
    });

    test("online, sign-out is main's sequence", () async {
      final (repository, ops, queue, sender) = await repo();
      await queue.add('q', 'A concern', _now);

      await repository.signOut();

      expect(sender.sent, ['A concern']);
      expect(ops.first, 'clearPayment');
      expect(ops, contains('wipeAll'));
    });
  });

  group('a closed account', () {
    test('is not held by its reports: they are discarded and counted',
        () async {
      final (gateway, queue, sender, innerGateway, logs) =
          await _build(closed: true);
      sender.failure = Exception('offline');
      await queue.add('q', 'A concern', _now);
      await queue.add('q2', 'Another', _now);

      await gateway.prepareForSignOut();

      expect(innerGateway.calls, ['signOut']);
      expect(
        sender.sent,
        isEmpty,
        reason: 'nothing is sent for a closed account',
      );
      expect(logs.single, contains('account-closed'));
      expect(logs.single, contains('2'));
    });

    test('proceeds even if the queue cannot be read', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final inner = _Inner();
      final gateway = ReportsFirstTransitionGateway(
        inner,
        () => _StalledQueue(db, stallPending: true),
        limit: const Duration(milliseconds: 80),
        isClosed: (_) => true,
        log: (_) {},
      );

      await gateway.prepareForSignOut().timeout(const Duration(seconds: 2));

      expect(inner.calls, ['signOut']);
    });

    test('the real sign-out wipes although a report waits', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final ops = <String>[];
      final sender = _Sender()..failure = Exception('offline');
      final queue = ReportQueue(
        db,
        sender: sender,
        account: () => 'acct-a',
        maxAttempts: 1,
        wait: (_) async {},
      );
      await queue.add('q', 'A concern', _now);
      final repository = AuthRepository(
        gateway: _Gw(ops),
        googleGateway: _Google(ops),
        functionsGateway: _Functions(),
        accountTransitionGateway: ReportsFirstTransitionGateway(
          _Inner(),
          () => queue,
          isClosed: (uid) => uid == 'acct-a',
          log: (_) {},
        ),
        localStateWiper: _Wiper(ops),
      );

      await repository.signOut();

      expect(ops, contains('wipeAll'));
      expect(ops, contains('signOut'));
    });
  });

  group('the whole check shares one bound', () {
    for (final stall in ['pending', 'refusedReasons']) {
      test('a stalled $stall read refuses at the limit', () async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        final inner = _Inner();
        final gateway = ReportsFirstTransitionGateway(
          inner,
          () => _StalledQueue(
            db,
            stallPending: stall == 'pending',
            stallRefused: stall == 'refusedReasons',
          ),
          limit: const Duration(milliseconds: 80),
          log: (_) {},
        );

        await expectLater(
          gateway.prepareForSignOut().timeout(const Duration(seconds: 2)),
          _connectionError,
        );

        expect(inner.calls, isEmpty);
      });
    }

    test('a read that fails refuses', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final gateway = ReportsFirstTransitionGateway(
        _Inner(),
        () => _StalledQueue(db, failPending: true),
        log: (_) {},
      );
      await expectLater(gateway.prepareForSignOut(), _connectionError);
    });

    test('a slow send and slow reads together stop at one limit', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final gateway = ReportsFirstTransitionGateway(
        _Inner(),
        () => _StalledQueue(db, slowEach: const Duration(milliseconds: 150)),
        limit: const Duration(milliseconds: 250),
        log: (_) {},
      );
      final started = DateTime.now();
      await expectLater(gateway.prepareForSignOut(), _connectionError);
      expect(
        DateTime.now().difference(started),
        lessThan(const Duration(milliseconds: 420)),
      );
    });
  });

  group('a refused sign-out', () {
    test('leaves a pending email-link sign-in as it was', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final ops = <String>[];
      final sender = _Sender()..failure = Exception('offline');
      final queue = ReportQueue(
        db,
        sender: sender,
        account: () => 'acct-a',
        maxAttempts: 1,
        wait: (_) async {},
      );
      await queue.add('q', 'A concern', _now);
      final store = RestorableEmailLinkStore(_MemoryLinkStore('a@b.example'));
      final repository = AuthRepository(
        gateway: _Gw(ops),
        googleGateway: _Google(ops),
        functionsGateway: _Functions(),
        emailLinkStore: store,
        accountTransitionGateway: ReportsFirstTransitionGateway(
          _Inner(),
          () => queue,
          onRefused: store.restore,
          log: (_) {},
        ),
        localStateWiper: _Wiper(ops),
      );

      await expectLater(repository.signOut(), _connectionError);

      expect(repository.pendingEmailLinkEmail, 'a@b.example');
      expect(ops, isEmpty);
    });

    test('a sign-out that goes through still clears it', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final ops = <String>[];
      final queue = ReportQueue(db, account: () => 'acct-a');
      final store = RestorableEmailLinkStore(_MemoryLinkStore('a@b.example'));
      final repository = AuthRepository(
        gateway: _Gw(ops),
        googleGateway: _Google(ops),
        functionsGateway: _Functions(),
        emailLinkStore: store,
        accountTransitionGateway: ReportsFirstTransitionGateway(
          _Inner(),
          () => queue,
          onRefused: store.restore,
          log: (_) {},
        ),
        localStateWiper: _Wiper(ops),
      );

      await repository.signOut();

      expect(repository.pendingEmailLinkEmail, isNull);
    });

    test('a new link started later is not overwritten by a restore', () {
      final store = RestorableEmailLinkStore(_MemoryLinkStore('old@b.example'))
        ..email = null
        ..email = 'new@b.example'
        ..restore();
      expect(store.email, 'new@b.example');
    });
  });

  test('delete account is not held by reports', () async {
    final (gateway, queue, sender, innerGateway, _) = await _build();
    sender.failure = Exception('offline');
    await queue.add('q', 'A concern', _now);

    await gateway.prepareForDeleteAccount();

    expect(innerGateway.calls, ['delete']);
  });

  test("another account's pending report does not hold this one", () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Sender()..failure = Exception('offline');
    var who = 'acct-b';
    final queue = ReportQueue(db, sender: sender, account: () => who);
    await queue.add('q', 'B concern', _now);
    who = 'acct-a';
    final inner = _Inner();
    final gateway = ReportsFirstTransitionGateway(inner, () => queue);

    await gateway.prepareForSignOut();

    expect(inner.calls, ['signOut']);
  });
}

class _Gw implements AuthGateway {
  _Gw(this.ops);
  final List<String> ops;

  @override
  AuthSession? currentSession = const AuthSession(uid: 'acct-a');

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(currentSession);

  @override
  Future<AuthSession> signInAnonymously() async {
    ops.add('signInAnonymously');
    return currentSession = const AuthSession(uid: 'anon', isAnonymous: true);
  }

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();

  @override
  Future<AuthSession> signInWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();

  @override
  Future<void> reauthenticateWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {
    ops.add('signOut');
    currentSession = null;
  }
}

class _Google implements GoogleSignInGateway {
  _Google(this.ops);
  final List<String> ops;

  @override
  Future<GoogleAuthTokens?> signIn() async => null;

  @override
  Future<void> signOut() async => ops.add('googleSignOut');
}

class _Functions implements AuthFunctionsGateway {
  @override
  Future<void> recordSignInEvent() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<Uri> exportData() async => Uri.parse('https://example.com/x');
}

class _Wiper implements LocalStateWiper {
  _Wiper(this.ops);
  final List<String> ops;

  @override
  Future<bool> hasMeaningfulProgress() async => false;

  @override
  Future<void> wipeAll() async => ops.add('wipeAll');
}

class _MemoryLinkStore implements EmailLinkStore {
  _MemoryLinkStore(this._email);
  String? _email;

  @override
  String? get email => _email;

  @override
  set email(String? value) => _email = value;
}

/// A queue whose reads can stall, fail or be slow.
class _StalledQueue extends ReportQueue {
  _StalledQueue(
    super.db, {
    this.stallPending = false,
    this.stallRefused = false,
    this.failPending = false,
    this.slowEach,
  }) : super(account: () => 'acct-a');

  final bool stallPending;
  final bool stallRefused;
  final bool failPending;
  final Duration? slowEach;

  @override
  Future<int> sendPending() async {
    if (slowEach != null) await Future<void>.delayed(slowEach!);
    return 0;
  }

  @override
  Future<List<QuestionReport>> pending() async {
    if (failPending) throw StateError('db');
    if (stallPending) return Completer<List<QuestionReport>>().future;
    if (slowEach != null) await Future<void>.delayed(slowEach!);
    return [];
  }

  @override
  Future<Map<String, int>> refusedReasons() async {
    if (stallRefused) return Completer<Map<String, int>>().future;
    if (slowEach != null) await Future<void>.delayed(slowEach!);
    return {};
  }
}
