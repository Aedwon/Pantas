const revenueCatAndroidApiKeyDefine = 'REVENUECAT_ANDROID_API_KEY';

class RevenueCatConfig {
  RevenueCatConfig._({required this.androidApiKey});

  factory RevenueCatConfig.fromEnvironment({
    String androidApiKey = const String.fromEnvironment(
      revenueCatAndroidApiKeyDefine,
    ),
  }) {
    final trimmed = androidApiKey.trim();
    return RevenueCatConfig._(
      androidApiKey: trimmed.isEmpty ? null : trimmed,
    );
  }

  final String? androidApiKey;

  bool get isEnabled => androidApiKey != null;
}
