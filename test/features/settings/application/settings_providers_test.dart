import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('userSettingsProvider reads repository defaults', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final settings = await container.read(userSettingsProvider.future);

    expect(settings.helpImproveApp, isFalse);
    expect(settings.strictMockMode, isFalse);
  });

  test('themeModeProvider initializes from repository', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await DriftSettingsRepository(db).updateThemePreference(
      ThemePreference.dark,
    );
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(themePreferenceProvider.future),
      ThemePreference.dark,
    );
  });

  test('themeModeController writes selected theme', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container
        .read(themePreferenceControllerProvider.notifier)
        .setThemePreference(ThemePreference.light);

    expect(
      await DriftSettingsRepository(db).readThemePreference(),
      ThemePreference.light,
    );
    expect(
      await container.read(themePreferenceProvider.future),
      ThemePreference.light,
    );
  });

  test('analytics consent gateway is invoked when help improve app changes',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final analytics = RecordingAnalyticsConsentGateway();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        analyticsConsentGatewayProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(settingsActionsProvider)
        .setHelpImproveApp(enabled: false);

    expect(analytics.values, [false]);
  });
}

class RecordingAnalyticsConsentGateway implements AnalyticsConsentGateway {
  final values = <bool>[];

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    values.add(enabled);
  }
}
