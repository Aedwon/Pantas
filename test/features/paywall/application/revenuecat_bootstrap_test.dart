import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  test('bootstrap hydrates even when Android API key is absent', () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.configure(RevenueCatConfig.fromEnvironment());

    expect(gateway.initializeCount, 1);
    expect(gateway.configuredKeys, isEmpty);
  });

  test('bootstrap configures gateway when Android API key is present',
      () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.configure(
      RevenueCatConfig.fromEnvironment(androidApiKey: 'rc_key'),
    );

    expect(gateway.initializeCount, 1);
    expect(gateway.configuredKeys, ['rc_key']);
  });

  test('bootstrap swallows initialization failure', () async {
    final gateway = BootstrapGateway(failInitialize: true);
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.configure(
      RevenueCatConfig.fromEnvironment(androidApiKey: 'rc_key'),
    );

    expect(gateway.initializeCount, 1);
    expect(gateway.configuredKeys, isEmpty);
  });

  test('auth uid association calls logIn for anonymous and named UIDs',
      () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.associateUid('anon_uid');
    await bootstrapper.associateUid('named_uid');

    expect(gateway.loggedInUids, ['anon_uid', 'named_uid']);
  });

  test('AC-5 no Firebase user clears the cache and logs out once', () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);
    await bootstrapper.associateUid('account-a');
    await bootstrapper.associateUid(null);
    expect(gateway.clearCount, 1);
    expect(gateway.logoutCount, 1);
    await bootstrapper.associateUid('account-b');
    expect(gateway.loggedInUids, ['account-a', 'account-b']);
  });

  test('same uid is not logged in repeatedly', () async {
    final gateway = BootstrapGateway();
    final bootstrapper = RevenueCatBootstrapper(gateway);

    await bootstrapper.associateUid('uid_1');
    await bootstrapper.associateUid('uid_1');

    expect(gateway.loggedInUids, ['uid_1']);
  });

  test('AC-5 identity changes during initial login are never missed', () async {
    final gateway = DelayedBootstrapGateway();
    final binding = RevenueCatAuthBinding(RevenueCatBootstrapper(gateway));
    final changes = StreamController<AuthState>.broadcast();
    final start = binding.start(
      initialState: const AuthState.anonymous(uid: 'account-a'),
      changes: changes.stream,
    );
    await pumpEventQueue();
    changes.add(const AuthState.anonymous(uid: 'account-b'));
    await pumpEventQueue();
    gateway.release.complete();
    await start;
    await pumpEventQueue();
    expect(gateway.attemptedUids, ['account-a', 'account-b']);
    await binding.dispose();
    await changes.close();
  });

  test('AC-5 queued sign-out never logs out a Firebase account that now exists',
      () async {
    final gateway = BootstrapGateway();
    var currentUid = 'account-a';
    final binding = RevenueCatAuthBinding(
      RevenueCatBootstrapper(gateway),
      currentFirebaseUid: () => currentUid,
    );
    final changes = StreamController<AuthState>();
    await binding.start(
      initialState: const AuthState.anonymous(uid: 'account-a'),
      changes: changes.stream,
    );
    currentUid = 'account-b';
    changes.add(const AuthState.signedOut());
    await pumpEventQueue();
    expect(gateway.logoutCount, 0);
    expect(gateway.loggedInUids, ['account-a', 'account-b']);
    await binding.dispose();
    await changes.close();
  });

  test('AC-5 linking an anonymous account logs in the same named uid',
      () async {
    final gateway = BootstrapGateway();
    final binding = RevenueCatAuthBinding(RevenueCatBootstrapper(gateway));
    final changes = StreamController<AuthState>();
    await binding.start(
      initialState: const AuthState.anonymous(uid: 'account-a'),
      changes: changes.stream,
    );
    changes.add(
      const AuthState.signedIn(
        user: AuthUser(
          uid: 'account-a',
          email: 'student@example.test',
          displayName: 'Student',
        ),
      ),
    );
    await pumpEventQueue();
    expect(gateway.loggedInUids, ['account-a', 'account-a']);
    await binding.dispose();
    await changes.close();
  });

  test('auth binding associates the initial anonymous uid before returning',
      () async {
    final gateway = BootstrapGateway();
    final binding = RevenueCatAuthBinding(RevenueCatBootstrapper(gateway));
    final changes = StreamController<AuthState>();
    addTearDown(() async {
      await binding.dispose();
      await changes.close();
    });

    await binding.start(
      initialState: const AuthState.anonymous(uid: 'anon_initial'),
      changes: changes.stream,
    );

    expect(gateway.loggedInUids, ['anon_initial']);
  });

  test('auth binding ignores repeated uid and propagates a later uid change',
      () async {
    final gateway = BootstrapGateway();
    final binding = RevenueCatAuthBinding(RevenueCatBootstrapper(gateway));
    final changes = StreamController<AuthState>();
    addTearDown(() async {
      await binding.dispose();
      await changes.close();
    });

    await binding.start(
      initialState: const AuthState.anonymous(uid: 'anon_uid'),
      changes: changes.stream,
    );
    changes
      ..add(const AuthState.anonymous(uid: 'anon_uid'))
      ..add(
        const AuthState.signedIn(
          user: AuthUser(
            uid: 'named_uid',
            email: 'student@example.test',
            displayName: 'Student',
          ),
        ),
      );
    await Future<void>.delayed(Duration.zero);

    expect(gateway.loggedInUids, ['anon_uid', 'named_uid']);
  });

  test('failed initial uid association remains retryable on the auth stream',
      () async {
    final gateway = BootstrapGateway(failLogInAttempts: 1);
    final binding = RevenueCatAuthBinding(RevenueCatBootstrapper(gateway));
    final changes = StreamController<AuthState>();
    addTearDown(() async {
      await binding.dispose();
      await changes.close();
    });

    await binding.start(
      initialState: const AuthState.anonymous(uid: 'anon_retry'),
      changes: changes.stream,
    );
    expect(gateway.attemptedUids, ['anon_retry']);
    expect(gateway.loggedInUids, isEmpty);

    changes.add(const AuthState.anonymous(uid: 'anon_retry'));
    await Future<void>.delayed(Duration.zero);

    expect(gateway.attemptedUids, ['anon_retry', 'anon_retry']);
    expect(gateway.loggedInUids, ['anon_retry']);
  });
}

class BootstrapGateway extends DisabledRevenueCatGateway {
  BootstrapGateway({
    this.failInitialize = false,
    int failLogInAttempts = 0,
  }) : _remainingLogInFailures = failLogInAttempts;

  final bool failInitialize;
  int _remainingLogInFailures;
  final configuredKeys = <String>[];
  final attemptedUids = <String>[];
  final loggedInUids = <String>[];
  int initializeCount = 0;
  int clearCount = 0;
  int logoutCount = 0;
  @override
  Future<void> clearIdentity() async {
    clearCount++;
  }

  @override
  Future<void> logOut() async {
    logoutCount++;
  }

  @override
  Future<void> initialize() async {
    initializeCount += 1;
    if (failInitialize) throw Exception('storage unavailable');
  }

  @override
  Future<void> configure({required String androidApiKey}) async {
    configuredKeys.add(androidApiKey);
  }

  @override
  Future<void> logIn(String uid) async {
    attemptedUids.add(uid);
    if (_remainingLogInFailures > 0) {
      _remainingLogInFailures -= 1;
      throw Exception('RevenueCat login unavailable');
    }
    loggedInUids.add(uid);
  }
}

class DelayedBootstrapGateway extends BootstrapGateway {
  final release = Completer<void>();
  @override
  Future<void> logIn(String uid) async {
    if (uid == 'account-a') await release.future;
    await super.logIn(uid);
  }
}
