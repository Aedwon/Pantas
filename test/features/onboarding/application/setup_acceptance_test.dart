import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/application/setup_acceptance.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

import '../../../helpers/in_memory_database.dart';

class _Gateway implements SetupAcceptanceGateway {
  final versions = <String>[];
  Exception? failure;
  AccountAcceptance? stored;
  Exception? readFailure;
  Completer<AccountAcceptance?>? readGate;
  int reads = 0;

  @override
  Future<void> record(String version) async {
    if (failure != null) throw failure!;
    versions.add(version);
  }

  @override
  Future<AccountAcceptance?> read() async {
    reads++;
    if (readFailure != null) throw readFailure!;
    if (readGate != null) return readGate!.future;
    return stored;
  }
}

void main() {
  late AppDatabase db;
  late _Gateway gateway;
  late ProviderContainer container;
  AuthUser? user;

  setUp(() {
    db = inMemoryDatabase();
    gateway = _Gateway();
    user = null;
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        setupAcceptanceGatewayProvider.overrideWithValue(gateway),
        termsSkipBoundProvider
            .overrideWithValue(const Duration(milliseconds: 50)),
        currentUserProvider.overrideWith((ref) async => user),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  const named = AuthUser(uid: 'u1', email: 'a@b.co', displayName: 'A');
  Future<void> accept() => container
      .read(appPreferencesRepositoryProvider)
      .setSetupAcceptanceVersion(SetupAcceptance.version);
  Future<void> record(String? uid) =>
      container.read(setupAcceptanceRecorderProvider).recordIfNeeded(uid);

  test('the version is the wording that names study records', () {
    expect(SetupAcceptance.version, '2026-11-09');
  });

  test('an anonymous account records nothing', () async {
    await accept();
    await record(null);
    expect(gateway.versions, isEmpty);
  });

  test('a named account that never accepted records nothing', () async {
    await record('u1');
    expect(gateway.versions, isEmpty);
  });

  test('a named account records once, then the marker stops repeats', () async {
    await accept();
    await record('u1');
    await record('u1');
    expect(gateway.versions, ['2026-11-09']);
    expect(
      await container
          .read(appPreferencesRepositoryProvider)
          .setupAcceptanceRecordedFor(),
      'u1|2026-11-09',
    );
  });

  test('a failure leaves no marker, so the next start tries again', () async {
    await accept();
    gateway.failure = Exception('offline');
    await record('u1');
    expect(gateway.versions, isEmpty);
    expect(
      await container
          .read(appPreferencesRepositoryProvider)
          .setupAcceptanceRecordedFor(),
      isNull,
    );
    gateway.failure = null;
    await record('u1');
    expect(gateway.versions, ['2026-11-09']);
  });

  test('a different account on the same device records again', () async {
    await accept();
    await record('u1');
    await record('u2');
    expect(gateway.versions, hasLength(2));
  });

  group('the account record lets a returning student skip Terms', () {
    final acceptedAt = DateTime.utc(2026, 11, 9, 2);
    final current = AccountAcceptance(
      version: SetupAcceptance.version,
      acceptedAt: acceptedAt,
    );
    Future<bool> skip(String uid) => container.read(termsSkipProvider)(uid);
    Future<String?> deviceMarker() => container
        .read(appPreferencesRepositoryProvider)
        .setupAcceptanceRecordedFor();

    test('a current record restores the acceptance with its own time',
        () async {
      gateway.stored = current;
      final helpBefore = await container
          .read(settingsRepositoryProvider)
          .readUserSettings()
          .then((s) => s.helpImproveApp);
      expect(await skip('u1'), isTrue);
      final settings =
          await container.read(settingsRepositoryProvider).readUserSettings();
      expect(settings.acceptedTermsAt, acceptedAt);
      expect(settings.helpImproveApp, helpBefore);
      expect(
        await container
            .read(appPreferencesRepositoryProvider)
            .setupAcceptanceVersion(),
        SetupAcceptance.version,
      );
      expect(await deviceMarker(), 'u1|2026-11-09');
      // The recorder sees the marker and writes nothing back.
      await record('u1');
      expect(gateway.versions, isEmpty);
    });

    test('an older version is not skipped and writes nothing', () async {
      gateway.stored =
          AccountAcceptance(version: '2026-10-01', acceptedAt: acceptedAt);
      expect(await skip('u1'), isFalse);
      final settings =
          await container.read(settingsRepositoryProvider).readUserSettings();
      expect(settings.acceptedTermsAt, isNull);
      expect(await deviceMarker(), isNull);
    });

    test('no record is not skipped', () async {
      expect(await skip('u1'), isFalse);
      expect(
        (await container.read(settingsRepositoryProvider).readUserSettings())
            .acceptedTermsAt,
        isNull,
      );
    });

    test('a failed read is not skipped', () async {
      gateway.readFailure = Exception('offline');
      expect(await skip('u1'), isFalse);
    });

    test('a read that never answers is not skipped after the bound', () async {
      gateway.readGate = Completer<AccountAcceptance?>();
      expect(await skip('u1'), isFalse);
    });
  });

  test('an account that becomes named after accepting is recorded once',
      () async {
    await accept();
    container.read(setupAcceptanceSyncProvider);
    await container.read(currentUserProvider.future);
    await Future<void>.delayed(Duration.zero);
    expect(gateway.versions, isEmpty, reason: 'still anonymous');

    user = named;
    container.invalidate(currentUserProvider);
    await container.read(currentUserProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(gateway.versions, ['2026-11-09']);
  });
}
