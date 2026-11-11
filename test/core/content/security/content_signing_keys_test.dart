import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';
import 'package:pantas/core/content/security/content_signing_keys.dart';

void main() {
  test('malformed sequence window fails closed without relying on assertions',
      () {
    const malformed = ContentSequenceWindow(
      minReleaseSequence: 6,
      maxReleaseSequence: 5,
    );

    expect(malformed.contains(5), isFalse);
    expect(malformed.contains(6), isFalse);
    expect(malformed.contains(7), isFalse);
  });

  test('production keyring authorizes the approved Ed25519 public key', () {
    final key =
        ContentSigningKeys.lookup(ContentPackageManifest.signingKeyIdV1);
    expect(key, isNotNull);
    expect(key!.type, KeyPairType.ed25519);
    expect(key.bytes, hasLength(32));
    expect(
      base64Encode(key.bytes),
      'XnN4p2v7DcmcaCOq2AnFsUc7Ivdt3u6pglU+ui+E9yU=',
    );

    final entry =
        ContentSigningKeys.lookupEntry(ContentPackageManifest.signingKeyIdV1);
    expect(entry, isNotNull);
    expect(entry!.keyId, ContentPackageManifest.signingKeyIdV1);
    expect(entry.publicKey.bytes, key.bytes);
    expect(entry.sequenceWindow.minReleaseSequence, 1);
    expect(entry.sequenceWindow.maxReleaseSequence, isNull);
    expect(entry.sequenceWindow.contains(0), isFalse);
    expect(entry.sequenceWindow.contains(1), isTrue);
    expect(entry.sequenceWindow.contains(2), isTrue);
  });

  test('unknown signing keys still fail closed', () {
    expect(ContentSigningKeys.lookup('untrusted-signing-key'), isNull);
    expect(ContentSigningKeys.lookupEntry('untrusted-signing-key'), isNull);
  });
}
