import 'package:flutter/material.dart';
import 'package:pantas/features/settings/domain/theme_preference.dart';

extension ThemePreferenceThemeMode on ThemePreference {
  ThemeMode get themeMode {
    return switch (this) {
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
      ThemePreference.system => ThemeMode.system,
    };
  }
}
