import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android release preflight requires the signed protected package', () {
    final release = File('tools/release/android/release.sh').readAsStringSync();

    expect(release, contains('assets/seed/content.db'));
    expect(release, contains('assets/seed/content.manifest.json'));
    expect(release, contains('assets/seed/content.manifest.sig'));
    expect(
      release,
      contains('tools/verify_content_package/verify_content_package.dart'),
    );
    expect(
      release,
      contains('require_env PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64'),
    );
    expect(release, isNot(contains('require_env APPROVED_CONTENT_DB_SHA256')));
    expect(
      release,
      isNot(contains('require_env PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64')),
    );
    final dollar = String.fromCharCode(36);
    expect(
      release,
      contains(
        '--dart-define=PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64="'
        '$dollar'
        'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64"',
      ),
    );

    final verifyIndex = release.indexOf(
      'tools/verify_content_package/verify_content_package.dart',
    );
    final buildIndex = release.indexOf('flutter build appbundle');
    expect(verifyIndex, greaterThanOrEqualTo(0));
    expect(buildIndex, greaterThan(verifyIndex));
  });
}
