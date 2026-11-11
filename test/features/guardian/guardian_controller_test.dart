import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';

import '../../helpers/in_memory_database.dart';
import 'fake_guardian_gateway.dart';

void main() {
  late AppDatabase db;
  late FakeGuardianGateway gateway;
  late ProviderContainer container;
  setUp(() {
    db = inMemoryDatabase();
    gateway = FakeGuardianGateway();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        guardianGatewayProvider.overrideWithValue(gateway),
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

  test('a minor with no request needs to give a contact', () async {
    await container.read(appPreferencesRepositoryProvider).setAgeGroup('minor');
    expect(await gate(), GuardianGate.needsContact);
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
    expect(await gate(), GuardianGate.needsContact);
  });

  test('declined and expired stay on Waiting', () async {
    await container.read(appPreferencesRepositoryProvider).setAgeGroup('minor');
    for (final status in [
      GuardianConsentStatus.declined,
      GuardianConsentStatus.expired,
      GuardianConsentStatus.pending,
    ]) {
      gateway.current = GuardianStatus(status: status);
      container.invalidate(guardianGateProvider);
      expect(await gate(), GuardianGate.waiting, reason: '$status');
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

  test('offline with nothing cached, a minor still needs to give a contact',
      () async {
    await container.read(appPreferencesRepositoryProvider).setAgeGroup('minor');
    gateway.failure = const GuardianGatewayException('unavailable');
    expect(await gate(), GuardianGate.needsContact);
  });
}
