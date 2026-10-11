import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'AndroidManifest.xml defaults Analytics and Crashlytics collection to '
      'false', () {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    expect(manifestFile.existsSync(), isTrue);

    final content = manifestFile.readAsStringSync();

    final analyticsRegex = RegExp(
      r'<meta-data\s+[^>]*android:name="firebase_analytics_collection_enabled"\s+[^>]*android:value="false"',
    );
    final crashlyticsRegex = RegExp(
      r'<meta-data\s+[^>]*android:name="firebase_crashlytics_collection_enabled"\s+[^>]*android:value="false"',
    );

    expect(
      analyticsRegex.hasMatch(content),
      isTrue,
      reason: 'firebase_analytics_collection_enabled must default to false',
    );
    expect(
      crashlyticsRegex.hasMatch(content),
      isTrue,
      reason: 'firebase_crashlytics_collection_enabled must default to false',
    );
  });

  test('production bootstrap wires and applies persisted telemetry consent',
      () {
    final bootstrapFile = File('lib/app/bootstrap.dart');
    expect(bootstrapFile.existsSync(), isTrue);

    final source = bootstrapFile.readAsStringSync();
    // Startup recovery can render before data exists. Consent still precedes
    // the real App inside the shipping initializer.
    final initializer = source.indexOf('Future<void> _bootstrap(');
    expect(initializer, greaterThanOrEqualTo(0));
    final content = source.substring(initializer);
    final overrideIndex = content.indexOf('...telemetryConsentOverrides');
    final applyIndex =
        content.indexOf('applyPersistedTelemetryConsent(container)');
    final runAppIndex = content.indexOf('runApp(');

    expect(overrideIndex, greaterThanOrEqualTo(0));
    expect(applyIndex, greaterThan(overrideIndex));
    expect(runAppIndex, greaterThan(applyIndex));
  });
}
