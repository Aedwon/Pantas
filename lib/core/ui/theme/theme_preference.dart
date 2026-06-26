enum ThemePreference {
  light('light'),
  dark('dark'),
  system('system');

  const ThemePreference(this.storageValue);

  final String storageValue;
}

extension ThemePreferenceX on ThemePreference {
  static ThemePreference fromStorage(String? value) {
    return switch (value) {
      'light' => ThemePreference.light,
      'dark' => ThemePreference.dark,
      'system' || _ => ThemePreference.system,
    };
  }
}
