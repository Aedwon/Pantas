import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/application/minor_sharing.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

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

  GuardianStatus status({required bool sharingAllowed}) => GuardianStatus(
        status: GuardianConsentStatus.confirmed,
        sharingAllowed: sharingAllowed,
      );

  Future<bool> sharingOn() async =>
      (await container.read(settingsRepositoryProvider).readUserSettings())
          .helpImproveApp;

  Future<MinorSharing> sync() =>
      container.read(minorSharingGateProvider).sync();

  Future<void> makeMinor() =>
      container.read(appPreferencesRepositoryProvider).setAgeGroup('minor');

  test('an adult is left alone and the server is not asked', () async {
    await container.read(appPreferencesRepositoryProvider).setAgeGroup('adult');
    gateway.current = status(sharingAllowed: true);
    expect(await sync(), MinorSharing.notMinor);
    expect(await sharingOn(), isFalse);
  });

  test('a minor whose guardian has not allowed sharing stays off and locked',
      () async {
    await makeMinor();
    gateway.current = status(sharingAllowed: false);
    expect(await sync(), MinorSharing.locked);
    expect(await sharingOn(), isFalse);
  });

  test('a minor with sharing already on is turned off when it reads false',
      () async {
    await makeMinor();
    await container
        .read(settingsRepositoryProvider)
        .updateHelpImproveApp(enabled: true);
    gateway.current = status(sharingAllowed: false);
    expect(await sync(), MinorSharing.locked);
    expect(await sharingOn(), isFalse);
  });

  test('allowed turns sharing on once, then the student may turn it off',
      () async {
    await makeMinor();
    gateway.current = status(sharingAllowed: true);
    expect(await sync(), MinorSharing.allowed);
    expect(await sharingOn(), isTrue);
    expect(
      await container
          .read(appPreferencesRepositoryProvider)
          .guardianSharingApplied(),
      isTrue,
    );

    // The student turns it off. A later sync must not turn it back on.
    await container
        .read(settingsRepositoryProvider)
        .updateHelpImproveApp(enabled: false);
    expect(await sync(), MinorSharing.allowed);
    expect(await sharingOn(), isFalse);
  });

  test(
      'revoked turns sharing off and clears the flag, so a re-allow applies '
      'once again', () async {
    await makeMinor();
    gateway.current = status(sharingAllowed: true);
    await sync();
    expect(await sharingOn(), isTrue);

    gateway.current = status(sharingAllowed: false);
    expect(await sync(), MinorSharing.locked);
    expect(await sharingOn(), isFalse);
    expect(
      await container
          .read(appPreferencesRepositoryProvider)
          .guardianSharingApplied(),
      isFalse,
    );

    gateway.current = status(sharingAllowed: true);
    expect(await sync(), MinorSharing.allowed);
    expect(await sharingOn(), isTrue);
  });

  test('a server error changes nothing and keeps a never-allowed minor locked',
      () async {
    await makeMinor();
    gateway.failure = const GuardianGatewayException('unavailable');
    expect(await sync(), MinorSharing.locked);
    expect(await sharingOn(), isFalse);
  });
}
