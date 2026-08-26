import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'AndroidManifest.xml defaults Analytics and Crashlytics collection to false',
      () {
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
}
