import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';

import '../../core/auth/auth_repository_sign_out_test.dart'
    show SignOutAuthGateway;
import '../../helpers/in_memory_database.dart';
import 'fake_guardian_gateway.dart';

void main() {
  late AppDatabase db;
  late _DeferredGuardianGateway gateway;
  late SignOutAuthGateway auth;
  late ProviderContainer container;
  late List<String> authOperations;
  setUp(() {
    db = inMemoryDatabase();
    gateway = _DeferredGuardianGateway();
    authOperations = [];
    auth = SignOutAuthGateway(authOperations);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        guardianGatewayProvider.overrideWithValue(gateway),
        authRepositoryProvider.overrideWithValue(
          AuthRepository(gateway: auth),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<GuardianGate> gate() => container.read(guardianGateProvider.future);

  test('a student with no age group is not held', () async {
    expect(await gate(), GuardianGate.notRequired);
  });

  test('an adult is not held', () async {
    await container.read(appPreferencesRepositoryProvider).setAgeGroup('adult');
    expect(await gate(), GuardianGate.notRequired);
  });

  // Option C (Nov 25): under-18 sign-up is closed, so nobody is asked for a
  // guardian contact. A device that was already in the flow lands on the
  // blocked page, and the block is saved.
  test('a minor with no request is blocked, and the block is saved', () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    expect(await gate(), GuardianGate.closed);
    expect(await repo.blockedMinimumAge(), 18);
  });

  test('a saved block keeps the device closed without asking the server',
      () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setBlockedMinimumAge(18);
    gateway.current = const GuardianStatus(
      status: GuardianConsentStatus.pending,
    );
    expect(await gate(), GuardianGate.closed);
  });

  test('a send the server refuses as closed ends on the saved block', () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setGuardianContact(name: 'Maria', email: 'maria@gmail.com');
    gateway.failure = const GuardianSignupClosedException();
    await expectLater(
      container.read(guardianControllerProvider).sendLink(
            guardianName: 'Maria',
            guardianEmail: 'maria@gmail.com',
          ),
      throwsA(isA<GuardianSignupClosedException>()),
    );
    expect(await repo.blockedMinimumAge(), 18);
    expect(await repo.guardianContact(), isNull);
    gateway.failure = null;
    expect(await gate(), GuardianGate.closed);
  });

  test('Resend refused as closed also ends on the saved block', () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setGuardianContact(name: 'Maria', email: 'maria@gmail.com');
    gateway.failure = const GuardianSignupClosedException();
    await expectLater(
      container.read(guardianControllerProvider).resend(),
      throwsA(isA<GuardianSignupClosedException>()),
    );
    expect(await repo.blockedMinimumAge(), 18);
  });

  test('sending a link keeps the contact, caches the status and waits',
      () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    final status = await container.read(guardianControllerProvider).sendLink(
          guardianName: 'Maria',
          guardianEmail: ' Maria@Gmail.com ',
        );
    expect(status.maskedEmail, 'm***@g***.com');
    expect(gateway.sent.single.email, 'maria@gmail.com');
    final contact = await repo.guardianContact();
    expect(contact?.name, 'Maria');
    expect(contact?.email, 'maria@gmail.com');
    expect(await repo.guardianStatusCache(), 'pending');
    expect(await gate(), GuardianGate.waiting);
    expect(await repo.hasPassedAgeGate(), isFalse);
  });

  test(
      'sending a link carries the age check notice version stored with the '
      'age group', () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setAgeCheckNoticeVersion('2026-11-09');
    await container.read(guardianControllerProvider).sendLink(
          guardianName: 'Maria',
          guardianEmail: 'maria@gmail.com',
        );
    expect(gateway.sent.single.ageCheckNoticeVersion, '2026-11-09');
  });

  test('a failed send keeps the student where they were', () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    gateway.failure = const GuardianRateLimitedException();
    await expectLater(
      container.read(guardianControllerProvider).sendLink(
            guardianName: 'Maria',
            guardianEmail: 'maria@gmail.com',
          ),
      throwsA(isA<GuardianRateLimitedException>()),
    );
    expect(await repo.guardianContact(), isNull);
    expect(await repo.blockedMinimumAge(), isNull, reason: 'nothing decided');
  });

  test('a pending request keeps its waiting page', () async {
    await container.read(appPreferencesRepositoryProvider).setAgeGroup('minor');
    gateway.current = const GuardianStatus(
      status: GuardianConsentStatus.pending,
    );
    expect(await gate(), GuardianGate.waiting);
  });

  test('a declined or expired request, or none, ends on the saved block',
      () async {
    for (final status in [
      GuardianConsentStatus.declined,
      GuardianConsentStatus.expired,
      GuardianConsentStatus.none,
    ]) {
      final repo = container.read(appPreferencesRepositoryProvider);
      await repo.setAgeGroup('minor');
      await repo.setGuardianContact(name: 'Maria', email: 'maria@gmail.com');
      gateway.current = GuardianStatus(status: status);
      container.invalidate(guardianGateProvider);
      expect(await gate(), GuardianGate.closed, reason: '$status');
      expect(await repo.blockedMinimumAge(), 18, reason: '$status');
      expect(await repo.guardianContact(), isNull, reason: '$status');
      await db.delete(db.devicePrefs).go();
    }
  });

  test('checking again after confirmation passes the age gate and clears',
      () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await container.read(guardianControllerProvider).sendLink(
          guardianName: 'Maria',
          guardianEmail: 'maria@gmail.com',
        );
    gateway.current = const GuardianStatus(
      status: GuardianConsentStatus.confirmed,
    );
    final status = await container.read(guardianControllerProvider).refresh();
    expect(status.status, GuardianConsentStatus.confirmed);
    expect(await repo.hasPassedAgeGate(), isTrue);
    expect(await repo.guardianContact(), isNull, reason: 'contact dropped');
    expect(await container.read(passedAgeGateProvider.future), isTrue);
    expect(await gate(), GuardianGate.cleared);
  });

  test('offline, the cached status decides; a confirmed cache clears',
      () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setGuardianStatusCache('pending');
    gateway.failure = const GuardianGatewayException('unavailable');
    expect(await gate(), GuardianGate.waiting);
    await repo.setGuardianStatusCache('confirmed');
    container.invalidate(guardianGateProvider);
    expect(await gate(), GuardianGate.cleared);
  });

  test('app start learning of a confirmation erases the contact', () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setGuardianContact(name: 'Maria', email: 'maria@gmail.com');
    gateway.current = const GuardianStatus(
      status: GuardianConsentStatus.confirmed,
    );
    expect(await gate(), GuardianGate.cleared);
    expect(await repo.guardianContact(), isNull);
  });

  test('a confirmed status cached offline also erases the contact', () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setGuardianContact(name: 'Maria', email: 'maria@gmail.com');
    await repo.setGuardianStatusCache('confirmed');
    gateway.failure = const GuardianGatewayException('unavailable');
    expect(await gate(), GuardianGate.cleared);
    expect(await repo.guardianContact(), isNull);
  });

  test('a pending status keeps the contact for Resend', () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setGuardianContact(name: 'Maria', email: 'maria@gmail.com');
    gateway.current = const GuardianStatus(
      status: GuardianConsentStatus.pending,
    );
    expect(await gate(), GuardianGate.waiting);
    expect((await repo.guardianContact())?.email, 'maria@gmail.com');
    final resent = await container.read(guardianControllerProvider).resend();
    expect(resent, isNotNull);
    expect(gateway.sent.last.email, 'maria@gmail.com');
  });

  // A block lasts, so only an answer from the server saves one. Offline, a
  // request that may still be open waits on the Waiting page, which asks the
  // server again when it opens.
  test('offline with nothing cached, a minor waits and is not blocked yet',
      () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    gateway.failure = const GuardianGatewayException('unavailable');
    expect(await gate(), GuardianGate.waiting);
    expect(await repo.blockedMinimumAge(), isNull);
    gateway.failure = null;
    container.invalidate(guardianGateProvider);
    expect(await gate(), GuardianGate.closed);
    expect(await repo.blockedMinimumAge(), 18);
  });

  test('offline with a declined status cached, a minor is not blocked yet',
      () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    await repo.setGuardianStatusCache('declined');
    gateway.failure = const GuardianGatewayException('unavailable');
    expect(await gate(), GuardianGate.waiting);
    expect(await repo.blockedMinimumAge(), isNull);
  });
  test('withdrawn status is final, signs out, and never clears from the cache',
      () async {
    final prefs = container.read(appPreferencesRepositoryProvider);
    await prefs.setAgeGroup('minor');
    await prefs.setPassedAgeGate(value: true);
    await prefs.setGuardianStatusCache('confirmed');
    gateway.current = GuardianStatus.fromJson({'status': 'withdrawn'});
    expect(await gate().then((value) => value.name), 'withdrawn');
    expect(authOperations, contains('firebaseSignOut'));
    expect(
      container.read(authRepositoryProvider).currentSession?.isAnonymous,
      isTrue,
    );
    gateway.failure = const GuardianGatewayException('unavailable');
    container.invalidate(guardianGateProvider);
    expect(await gate().then((value) => value.name), 'withdrawn');
  });

  test('account-closed refusal overrides a confirmed offline cache', () async {
    final prefs = container.read(appPreferencesRepositoryProvider);
    await prefs.setAgeGroup('minor');
    await prefs.setGuardianStatusCache('confirmed');
    gateway.failure = const GuardianGatewayException('account-closed');
    expect(await gate().then((value) => value.name), 'withdrawn');
    expect(authOperations, contains('firebaseSignOut'));
  });

  test('refresh of withdrawn status signs out instead of reopening onboarding',
      () async {
    final prefs = container.read(appPreferencesRepositoryProvider);
    await prefs.setAgeGroup('minor');
    gateway.current = GuardianStatus.fromJson({'status': 'withdrawn'});
    final status = await container.read(guardianControllerProvider).refresh();
    expect(status.status.wire, 'withdrawn');
    expect(authOperations, contains('firebaseSignOut'));
    expect(await prefs.hasPassedAgeGate(), isFalse);
  });
  test('a link sent as another account cannot write its contact back',
      () async {
    final repo = container.read(appPreferencesRepositoryProvider);
    await repo.setAgeGroup('minor');
    final pending = Completer<GuardianStatus>();
    gateway.nextSend = pending.future;
    final sent = container.read(guardianControllerProvider).sendLink(
          guardianName: 'Maria',
          guardianEmail: 'maria@gmail.com',
        );
    await Future<void>.delayed(Duration.zero);
    // The student signs out, or another account takes over, mid-request.
    auth.currentSession = const AuthSession(uid: 'other-student');
    pending.complete(
      const GuardianStatus(status: GuardianConsentStatus.pending),
    );
    await expectLater(sent, throwsA(isA<GuardianGatewayException>()));
    expect(await repo.guardianContact(), isNull);
    expect(await repo.guardianStatusCache(), isNull);
  });

  test('a late withdrawn refresh cannot close a different identity', () async {
    final pending = Completer<GuardianStatus>();
    gateway.nextStatus = pending.future;
    final refreshed = container.read(guardianControllerProvider).refresh();
    auth.currentSession = const AuthSession(uid: 'other-student');
    pending.complete(
      const GuardianStatus(
        status: GuardianConsentStatus.withdrawn,
      ),
    );
    await expectLater(refreshed, throwsA(isA<GuardianGatewayException>()));
    expect(authOperations, isEmpty);
    expect(container.read(guardianAccountClosedProvider), isNull);
  });

  test('a late withdrawn gate result cannot hold a different identity',
      () async {
    final prefs = container.read(appPreferencesRepositoryProvider);
    await prefs.setAgeGroup('minor');
    await prefs.setGuardianStatusCache('confirmed');
    final pending = Completer<GuardianStatus>();
    gateway.nextStatus = pending.future;
    final checked = gate();
    // Let the provider reach the pending server response.
    await Future<void>.delayed(Duration.zero);
    auth.currentSession = const AuthSession(uid: 'other-student');
    pending.complete(
      const GuardianStatus(
        status: GuardianConsentStatus.withdrawn,
      ),
    );
    expect(await checked, GuardianGate.notRequired);
    expect(await prefs.guardianStatusCache(), 'confirmed');
    expect(authOperations, isEmpty);
    expect(container.read(guardianAccountClosedProvider), isNull);
  });
}

class _DeferredGuardianGateway extends FakeGuardianGateway {
  Future<GuardianStatus>? nextStatus;
  Future<GuardianStatus>? nextSend;

  @override
  Future<GuardianStatus> status() => nextStatus ?? super.status();

  @override
  Future<GuardianStatus> sendLink({
    required String guardianName,
    required String guardianEmail,
    String? ageCheckNoticeVersion,
  }) =>
      nextSend ??
      super.sendLink(
        guardianName: guardianName,
        guardianEmail: guardianEmail,
        ageCheckNoticeVersion: ageCheckNoticeVersion,
      );
}
