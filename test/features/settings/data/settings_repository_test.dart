import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('returns default user settings when account prefs are missing',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    final settings = await repo.readUserSettings();

    expect(settings.dailyReminderTime, isNull);
    expect(settings.examDate, isNull);
    expect(settings.strictMockMode, isFalse);

    // Off until the student has answered. Consent that defaults to yes is not
    // consent, and nothing may be collected before they have been asked.
    // Section 2 of the platform foundations spec, on RA10173 grounds.
    expect(settings.helpImproveApp, isFalse);
  });

  test('help-improve is on only when the student explicitly said yes',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.updateHelpImproveApp(enabled: true);
    expect((await repo.readUserSettings()).helpImproveApp, isTrue);

    await repo.updateHelpImproveApp(enabled: false);
    expect((await repo.readUserSettings()).helpImproveApp, isFalse);
  });

  test('updates reminder time and bumps updatedAt', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(
      db,
      clock: () => DateTime.utc(2026, 5, 22, 12),
    );

    await repo.updateReminderTime(const SettingsTime(hour: 19, minute: 5));

    final settings = await repo.readUserSettings();
    expect(settings.dailyReminderTime, const SettingsTime(hour: 19, minute: 5));
    expect(settings.updatedAt, DateTime.utc(2026, 5, 22, 12));
  });

  test('updates exam date only for tomorrow or later and bumps updatedAt',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(
      db,
      clock: () => DateTime.utc(2026, 5, 22, 12),
    );

    await repo.updateExamDate(
      ExamDate.onDay(DateTime(2026, 5, 23)),
      today: DateTime(2026, 5, 22),
    );

    expect(
      (await repo.readUserSettings()).examDate,
      ExamDate.onDay(DateTime(2026, 5, 23)),
    );
    await expectLater(
      repo.updateExamDate(
        ExamDate.onDay(DateTime(2026, 5, 22)),
        today: DateTime(2026, 5, 22),
      ),
      throwsA(isA<InvalidExamDateException>()),
    );
  });

  test('month-precision date allows current month while days remain', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.updateExamDate(
      ExamDate.inMonth(year: 2026, month: 5),
      today: DateTime(2026, 5, 22),
    );

    expect(
      (await repo.readUserSettings()).examDate,
      ExamDate.inMonth(year: 2026, month: 5),
    );

    await expectLater(
      repo.updateExamDate(
        ExamDate.inMonth(year: 2026, month: 4),
        today: DateTime(2026, 5, 22),
      ),
      throwsA(isA<InvalidExamDateException>()),
    );
  });

  test('updates strict mock mode in account prefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.updateStrictMockMode(enabled: true);

    expect((await repo.readUserSettings()).strictMockMode, isTrue);
    final rows = await db.select(db.accountPrefs).get();
    expect(
      rows,
      contains(
        const AccountPrefRow(
          key: SettingsPrefKeys.strictMockMode,
          value: 'true',
        ),
      ),
    );
  });

  test('updates help improve app and calls analytics consent gate', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final analytics = RecordingAnalyticsConsentGateway();
    final repo = DriftSettingsRepository(db, analytics: analytics);

    await repo.updateHelpImproveApp(enabled: false);

    expect((await repo.readUserSettings()).helpImproveApp, isFalse);
    expect(analytics.values, [false]);
  });

  test('theme mode defaults to system from device prefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    expect(await repo.readThemePreference(), ThemePreference.system);
  });

  test('theme mode writes only device prefs and never account prefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.updateThemePreference(ThemePreference.dark);

    expect(await repo.readThemePreference(), ThemePreference.dark);
    expect(await db.select(db.accountPrefs).get(), isEmpty);
    expect(await db.select(db.devicePrefs).get(), hasLength(1));
  });

  test('the new preferences have their specified defaults', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    final settings = await repo.readUserSettings();

    expect(settings.name, isNull);
    expect(settings.examDate, isNull);
    expect(settings.carryOverProgress, isTrue);
    expect(settings.sessionOrdering, SessionOrdering.interleavedTail);
    expect(settings.retainTableOrder, isTrue);
  });

  test('the name round trips, and empty is the same state as absent', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.updateName('Aedwon');
    expect((await repo.readUserSettings()).name, 'Aedwon');

    await repo.updateName(null);
    expect((await repo.readUserSettings()).name, isNull);

    await repo.updateName('   ');
    expect((await repo.readUserSettings()).name, isNull);
  });

  test('carry over, ordering and table order round trip', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.updateCarryOverProgress(enabled: false);
    await repo.updateSessionOrdering(SessionOrdering.fullyMixed);
    await repo.updateRetainTableOrder(enabled: false);

    final settings = await repo.readUserSettings();
    expect(settings.carryOverProgress, isFalse);
    expect(settings.sessionOrdering, SessionOrdering.fullyMixed);
    expect(settings.retainTableOrder, isFalse);
  });

  test('acceptance records the time and the policy version', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.recordPolicyAcceptance();

    final rows = await db.select(db.accountPrefs).get();
    final values = {for (final row in rows) row.key: row.value};

    expect(
      values['settings.policy_version'],
      DriftSettingsRepository.currentPolicyVersion,
    );
    expect(
      DateTime.tryParse(values['settings.policy_accepted_at'] ?? ''),
      isNotNull,
    );
  });

  test(
      'updateHelpImproveApp(enabled: false) closes gate, persists false '
      'before cleanup, and rethrows cleanup error', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    late final DriftSettingsRepository repo;
    final gateway = DbObservingFailingAnalyticsConsentGateway(
      onDisable: () async {
        final settings = await repo.readUserSettings();
        expect(settings.helpImproveApp, isFalse);
      },
    );
    repo = DriftSettingsRepository(db, analytics: gateway);

    // Set helpImproveApp to true first
    await repo.updateHelpImproveApp(enabled: true);
    expect((await repo.readUserSettings()).helpImproveApp, isTrue);

    try {
      await repo.updateHelpImproveApp(enabled: false);
      fail('Expected StateError');
    } catch (error, stack) {
      expect(error, isA<StateError>());
      expect(
        (error as StateError).message,
        'Gateway setAnalyticsCollectionEnabled(false) failed',
      );
      expect(
        stack.toString(),
        contains('DbObservingFailingAnalyticsConsentGateway'),
      );
    }

    expect(gateway.gateClosed, isTrue);
    expect(gateway.observedFalse, isTrue);
    expect(gateway.events, ['gate_closed', 'cleanup']);
    expect((await repo.readUserSettings()).helpImproveApp, isFalse);
  });

  test('opt-out reports persistence failure even when SDK cleanup also fails',
      () async {
    final db = inMemoryDatabase();
    final gateway = FailingAnalyticsConsentGateway()..throwOnFalse = true;
    final repo = DriftSettingsRepository(db, analytics: gateway);

    await repo.updateHelpImproveApp(enabled: true);
    await db.close();

    try {
      await repo.updateHelpImproveApp(enabled: false);
      fail('Expected database write error');
    } catch (error) {
      expect(error, isNot(isA<TestFailure>()));
      expect(error.toString(), contains("Can't re-open a database"));
      expect(
        error.toString(),
        isNot(contains('Gateway setAnalyticsCollectionEnabled(false) failed')),
      );
    }

    expect(gateway.gateClosedCalls, 1);
    expect(gateway.values, [true, false]);
  });

  test(
      'updateHelpImproveApp(enabled: true) observes stored false at gateway '
      'and persists true only after gateway success', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    late final DriftSettingsRepository repo;
    var observedFalseAtGateway = false;
    final gateway =
        FunctionAnalyticsConsentGateway(({required bool enabled}) async {
      if (enabled) {
        final settings = await repo.readUserSettings();
        observedFalseAtGateway = !settings.helpImproveApp;
      }
    });
    repo = DriftSettingsRepository(db, analytics: gateway);

    expect((await repo.readUserSettings()).helpImproveApp, isFalse);

    await repo.updateHelpImproveApp(enabled: true);

    expect(observedFalseAtGateway, isTrue);
    expect((await repo.readUserSettings()).helpImproveApp, isTrue);
  });

  test(
      'updateHelpImproveApp(enabled: true) failure leaves storage unchanged '
      'false without a true write', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final gateway = FailingAnalyticsConsentGateway()..throwOnTrue = true;
    final repo = DriftSettingsRepository(
      db,
      analytics: gateway,
      clock: () => DateTime.utc(2026, 8, 26, 10),
    );

    expect((await repo.readUserSettings()).helpImproveApp, isFalse);
    expect((await repo.readUserSettings()).updatedAt, isNull);

    try {
      await repo.updateHelpImproveApp(enabled: true);
      fail('Expected StateError');
    } catch (error, stack) {
      expect(error, isA<StateError>());
      expect(
        (error as StateError).message,
        'Gateway setAnalyticsCollectionEnabled(true) failed',
      );
      expect(stack.toString(), contains('FailingAnalyticsConsentGateway'));
    }

    final settings = await repo.readUserSettings();
    expect(settings.helpImproveApp, isFalse);
    expect(settings.updatedAt, isNull);
  });

  test(
      'simulated true-write failure causes gateway calls [true, false] and '
      'rethrows the write error', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final gateway = ClosingDbAnalyticsConsentGateway(db);
    final repo = DriftSettingsRepository(db, analytics: gateway);

    try {
      await repo.updateHelpImproveApp(enabled: true);
      fail('Expected database write error');
    } catch (error) {
      expect(error, isNotNull);
      expect(error, isNot(isA<TestFailure>()));
    }

    expect(gateway.values, [true, false]);
  });
}

class RecordingAnalyticsConsentGateway implements AnalyticsConsentGateway {
  final values = <bool>[];

  @override
  void closeTelemetryGate() {}

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    values.add(enabled);
  }
}

class FailingAnalyticsConsentGateway implements AnalyticsConsentGateway {
  bool throwOnFalse = false;
  bool throwOnTrue = false;
  final values = <bool>[];
  int gateClosedCalls = 0;

  @override
  void closeTelemetryGate() {
    gateClosedCalls++;
  }

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    values.add(enabled);
    if (enabled && throwOnTrue) {
      throw StateError('Gateway setAnalyticsCollectionEnabled(true) failed');
    }
    if (!enabled && throwOnFalse) {
      throw StateError('Gateway setAnalyticsCollectionEnabled(false) failed');
    }
  }
}

class ClosingDbAnalyticsConsentGateway implements AnalyticsConsentGateway {
  ClosingDbAnalyticsConsentGateway(this.db);
  final AppDatabase db;
  final values = <bool>[];

  @override
  void closeTelemetryGate() {}

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    values.add(enabled);
    if (enabled) {
      await db.customStatement('DROP TABLE account_prefs;');
    }
  }
}

class DbObservingFailingAnalyticsConsentGateway
    implements AnalyticsConsentGateway {
  DbObservingFailingAnalyticsConsentGateway({required this.onDisable});

  final Future<void> Function() onDisable;
  bool gateClosed = false;
  bool observedFalse = false;
  final events = <String>[];

  @override
  void closeTelemetryGate() {
    gateClosed = true;
    events.add('gate_closed');
  }

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    if (!enabled) {
      events.add('cleanup');
      await onDisable();
      observedFalse = true;
      throw StateError('Gateway setAnalyticsCollectionEnabled(false) failed');
    }
  }
}

class FunctionAnalyticsConsentGateway implements AnalyticsConsentGateway {
  FunctionAnalyticsConsentGateway(this.onSetConsent);

  final Future<void> Function({required bool enabled}) onSetConsent;

  @override
  void closeTelemetryGate() {}

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    await onSetConsent(enabled: enabled);
  }
}
