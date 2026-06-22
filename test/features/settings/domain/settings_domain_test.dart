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

  test('default user settings collect nothing until the student says yes', () {
    final settings = UserSettings.defaults();

    expect(settings.dailyReminderTime, isNull);
    expect(settings.examDate, isNull);
    expect(settings.strictMockMode, isFalse);

    // Changed 3 August 2026, when this switch started governing crash reports
    // and analytics. It used to default to true, which opted an unanswered
    // student in. Consent that defaults to yes is not consent.
    expect(settings.helpImproveApp, isFalse);
    expect(settings.updatedAt, isNull);
  });
}
