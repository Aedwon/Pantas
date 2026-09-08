import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';
import 'package:pantas/core/content/security/content_signing_keys.dart';

void main() {
  test('malformed sequence window fails closed without relying on assertions',
      () {
    final malformed = ContentSequenceWindow(
      minReleaseSequence: 6,
      maxReleaseSequence: 5,
    );

    expect(malformed.contains(5), isFalse);
    expect(malformed.contains(6), isFalse);
    expect(malformed.contains(7), isFalse);
  });

  test('production keyring fails closed until an authorized key is committed',
      () {
    expect(
      ContentSigningKeys.lookup(ContentPackageManifest.signingKeyIdV1),
      isNull,
    );
    expect(ContentSigningKeys.lookup('untrusted-signing-key'), isNull);
  });
}
