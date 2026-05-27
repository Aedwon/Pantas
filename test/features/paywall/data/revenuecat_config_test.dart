import 'package:cse_cet_reviewer/features/paywall/data/revenuecat_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('config is disabled when Android API key is missing', () {
    final config = RevenueCatConfig.fromEnvironment();

    expect(config.isEnabled, isFalse);
    expect(config.androidApiKey, isNull);
  });

  test('config reads Android API key from dart define value', () {
    final config = RevenueCatConfig.fromEnvironment(androidApiKey: 'rc_key');

    expect(config.isEnabled, isTrue);
    expect(config.androidApiKey, 'rc_key');
  });

  test('config trims whitespace-only API key to disabled', () {
    final config = RevenueCatConfig.fromEnvironment(androidApiKey: '   ');

    expect(config.isEnabled, isFalse);
    expect(config.androidApiKey, isNull);
  });
}
