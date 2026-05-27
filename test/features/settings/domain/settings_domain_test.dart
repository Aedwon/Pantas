import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme preference converts to Flutter theme modes', () {
    expect(ThemePreference.system.themeMode, ThemeMode.system);
    expect(ThemePreference.light.themeMode, ThemeMode.light);
    expect(ThemePreference.dark.themeMode, ThemeMode.dark);
  });

  test('invalid stored theme preference falls back to system', () {
    expect(ThemePreferenceX.fromStorage(null), ThemePreference.system);
    expect(ThemePreferenceX.fromStorage('sepia'), ThemePreference.system);
  });

  test('default user settings opt into analytics and strict mode off', () {
    final settings = UserSettings.defaults();

    expect(settings.dailyReminderTime, isNull);
    expect(settings.examDate, isNull);
    expect(settings.strictMockMode, isFalse);
    expect(settings.helpImproveApp, isTrue);
    expect(settings.updatedAt, isNull);
  });
}
