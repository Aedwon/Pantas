import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hashes;
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';
import 'package:pantas/core/content/security/content_package_verifier.dart';
import 'package:pantas/core/content/security/content_signing_keys.dart';

void main() {
  late SimpleKeyPair signingKeyPair;
  late SimplePublicKey signingPublicKey;
  late SimpleKeyPair successorSigningKeyPair;
  late SimplePublicKey successorSigningPublicKey;

  setUp(() async {
    signingKeyPair = await Ed25519().newKeyPairFromSeed(
      List<int>.generate(32, (index) => index + 1),
    );
    signingPublicKey = await signingKeyPair.extractPublicKey();
    successorSigningKeyPair = await Ed25519().newKeyPairFromSeed(
      List<int>.generate(32, (index) => index + 33),
    );
    successorSigningPublicKey =
        await successorSigningKeyPair.extractPublicKey();
  });

  Future<_Fixture> fixture({
    int releaseSequence = 5,
    String signingKeyId = 'content-signing-v1',
    String bootstrapKeyId = 'content-bootstrap-v1',
    SimpleKeyPair? signingKeyPairOverride,
    Uint8List? payloadBytes,
  }) async {
    final payload = payloadBytes ?? Uint8List.fromList(<int>[7, 8, 9, 10]);
    final payloadDigest = hashes.sha256.convert(payload).toString();
    const sourceDigest =
        'eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45';
    final production = ContentPackageManifest.production(
      releaseSequence: releaseSequence,
      sourceContentSha256: sourceDigest,
      payloadSha256: payloadDigest,
    );
    final manifest = ContentPackageManifest(
      formatVersion: production.formatVersion,
      applicationId: production.applicationId,
      releaseChannel: production.releaseChannel,
      releaseSequence: production.releaseSequence,
      payloadPath: production.payloadPath,
      sourceContentSha256: production.sourceContentSha256,
      payloadSha256: production.payloadSha256,
      contentSeedVersion: production.contentSeedVersion,
      contentSchemaVersion: production.contentSchemaVersion,
      readerSchemaMin: production.readerSchemaMin,
      readerSchemaMax: production.readerSchemaMax,
      cipherProfile: production.cipherProfile,
      bootstrapKeyId: bootstrapKeyId,
      signingKeyId: signingKeyId,
    );
    final manifestBytes = Uint8List.fromList(manifest.encode());
    final signature = await Ed25519().sign(
      manifestBytes,
      keyPair: signingKeyPairOverride ?? signingKeyPair,
    );
    return _Fixture(
      manifest: manifest,
      manifestBytes: manifestBytes,
      signatureBytes: Uint8List.fromList(signature.bytes),
      payloadBytes: payload,
    );
  }

  BundledContentPackageVerifier verifier(
    _Fixture fixture, {
    Map<String, ContentSigningKeyEntry>? signingEntries,
    Map<String, ContentBootstrapKeyEntry>? bootstrapEntries,
  }) {
    final assets = <String, Uint8List>{
      ContentPackageAssets.manifestPath: fixture.manifestBytes,
      ContentPackageAssets.signaturePath: fixture.signatureBytes,
      ContentPackageAssets.payloadPath: fixture.payloadBytes,
    };
    final effectiveSigningEntries = signingEntries ??
        <String, ContentSigningKeyEntry>{
          'content-signing-v1': ContentSigningKeyEntry(
            keyId: 'content-signing-v1',
            publicKey: signingPublicKey,
            sequenceWindow: const ContentSequenceWindow(minReleaseSequence: 1),
          ),
        };
    final effectiveBootstrapEntries = bootstrapEntries ??
        <String, ContentBootstrapKeyEntry>{
          'content-bootstrap-v1': ContentBootstrapKeyEntry(
            keyId: 'content-bootstrap-v1',
            keyBytes: Uint8List(32),
            sequenceWindow: const ContentSequenceWindow(minReleaseSequence: 1),
          ),
        };
    return BundledContentPackageVerifier(
      loadAssetBytes: (path) async => assets[path]!,
      signingKeyLookup: (keyId) => effectiveSigningEntries[keyId],
      bootstrapKeyLookup: (keyId) => effectiveBootstrapEntries[keyId],
    );
  }

  test('verifies exact signed bundle and records immutable provenance hashes',
      () async {
    final packageFixture = await fixture();

    final verified = await verifier(packageFixture).verifyBundled();

    expect(verified.manifest.releaseSequence, 5);
    expect(verified.payloadBytes, packageFixture.payloadBytes);
    expect(
      verified.manifestSha256,
      hashes.sha256.convert(packageFixture.manifestBytes).toString(),
    );
    expect(
      verified.signatureSha256,
      hashes.sha256.convert(packageFixture.signatureBytes).toString(),
    );
  });

  test('rejects actual unknown signing and bootstrap ids', () async {
    final unknownSigning = await fixture(signingKeyId: 'content-signing-v99');
    await expectLater(
      verifier(unknownSigning).verifyBundled(),
      throwsFormatException,
    );

    final unknownBootstrap =
        await fixture(bootstrapKeyId: 'content-bootstrap-v99');
    await expectLater(
      verifier(unknownBootstrap).verifyBundled(),
      throwsFormatException,
    );
  });

  test('rejects retired and out-of-window keys plus package tamper', () async {
    final packageFixture = await fixture();

    await expectLater(
      verifier(
        packageFixture,
        signingEntries: <String, ContentSigningKeyEntry>{
          'content-signing-v1': ContentSigningKeyEntry(
            keyId: 'content-signing-v1',
            publicKey: signingPublicKey,
            sequenceWindow: const ContentSequenceWindow(
              minReleaseSequence: 1,
              maxReleaseSequence: 4,
            ),
          ),
        },
      ).verifyBundled(),
      throwsFormatException,
    );
    await expectLater(
      verifier(
        packageFixture,
        bootstrapEntries: <String, ContentBootstrapKeyEntry>{
          'content-bootstrap-v1': ContentBootstrapKeyEntry(
            keyId: 'content-bootstrap-v1',
            keyBytes: Uint8List(32),
            sequenceWindow: const ContentSequenceWindow(
              minReleaseSequence: 6,
              maxReleaseSequence: 9,
            ),
          ),
        },
      ).verifyBundled(),
      throwsFormatException,
    );

    final signatureTampered = _Fixture(
      manifest: packageFixture.manifest,
      manifestBytes: packageFixture.manifestBytes,
      signatureBytes: Uint8List.fromList(packageFixture.signatureBytes)
        ..[0] ^= 0x01,
      payloadBytes: packageFixture.payloadBytes,
    );
    await expectLater(
      verifier(signatureTampered).verifyBundled(),
      throwsFormatException,
    );

    final payloadTampered = _Fixture(
      manifest: packageFixture.manifest,
      manifestBytes: packageFixture.manifestBytes,
      signatureBytes: packageFixture.signatureBytes,
      payloadBytes: Uint8List.fromList(packageFixture.payloadBytes)
        ..[0] ^= 0x01,
    );
    await expectLater(
      verifier(payloadTampered).verifyBundled(),
      throwsFormatException,
    );
  });

  test('permits bounded signing-key rotation overlap and enforces both bounds',
      () async {
    final entries = <String, ContentSigningKeyEntry>{
      'content-signing-v1': ContentSigningKeyEntry(
        keyId: 'content-signing-v1',
        publicKey: signingPublicKey,
        sequenceWindow: const ContentSequenceWindow(
          minReleaseSequence: 1,
          maxReleaseSequence: 5,
        ),
      ),
      'content-signing-v2': ContentSigningKeyEntry(
        keyId: 'content-signing-v2',
        publicKey: successorSigningPublicKey,
        sequenceWindow: const ContentSequenceWindow(
          minReleaseSequence: 5,
          maxReleaseSequence: 8,
        ),
      ),
    };

    final oldAtOverlap = await fixture();
    await expectLater(
      verifier(oldAtOverlap, signingEntries: entries).verifyBundled(),
      completes,
    );

    final successorAtOverlap = await fixture(
      signingKeyId: 'content-signing-v2',
      signingKeyPairOverride: successorSigningKeyPair,
    );
    await expectLater(
      verifier(successorAtOverlap, signingEntries: entries).verifyBundled(),
      completes,
    );

    final oldAfterRetirement = await fixture(releaseSequence: 6);
    await expectLater(
      verifier(oldAfterRetirement, signingEntries: entries).verifyBundled(),
      throwsFormatException,
    );

    final successorBeforeActivation = await fixture(
      releaseSequence: 4,
      signingKeyId: 'content-signing-v2',
      signingKeyPairOverride: successorSigningKeyPair,
    );
    await expectLater(
      verifier(successorBeforeActivation, signingEntries: entries)
          .verifyBundled(),
      throwsFormatException,
    );
  });

  test(
      'permits bounded bootstrap-key rotation overlap and enforces both bounds',
      () async {
    final entries = <String, ContentBootstrapKeyEntry>{
      'content-bootstrap-v1': ContentBootstrapKeyEntry(
        keyId: 'content-bootstrap-v1',
        keyBytes: Uint8List.fromList(List<int>.filled(32, 1)),
        sequenceWindow: const ContentSequenceWindow(
          minReleaseSequence: 1,
          maxReleaseSequence: 5,
        ),
      ),
      'content-bootstrap-v2': ContentBootstrapKeyEntry(
        keyId: 'content-bootstrap-v2',
        keyBytes: Uint8List.fromList(List<int>.filled(32, 2)),
        sequenceWindow: const ContentSequenceWindow(
          minReleaseSequence: 5,
          maxReleaseSequence: 8,
        ),
      ),
    };

    final oldAtOverlap = await fixture();
    await expectLater(
      verifier(oldAtOverlap, bootstrapEntries: entries).verifyBundled(),
      completes,
    );

    final successorAtOverlap = await fixture(
      bootstrapKeyId: 'content-bootstrap-v2',
    );
    await expectLater(
      verifier(successorAtOverlap, bootstrapEntries: entries).verifyBundled(),
      completes,
    );

    final oldAfterRetirement = await fixture(releaseSequence: 6);
    await expectLater(
      verifier(oldAfterRetirement, bootstrapEntries: entries).verifyBundled(),
      throwsFormatException,
    );

    final successorBeforeActivation = await fixture(
      releaseSequence: 4,
      bootstrapKeyId: 'content-bootstrap-v2',
    );
    await expectLater(
      verifier(successorBeforeActivation, bootstrapEntries: entries)
          .verifyBundled(),
      throwsFormatException,
    );
  });

  test('chronology rejects downgrade/fork and allows exact replay or upgrade',
      () async {
    final acceptedFixture = await fixture();
    final accepted = ContentPackageIdentity.fromVerified(
      await verifier(acceptedFixture).verifyBundled(),
    );

    final lowerFixture = await fixture(releaseSequence: 4);
    final lower = ContentPackageIdentity.fromVerified(
      await verifier(lowerFixture).verifyBundled(),
    );
    expect(
      () => ContentPackageChronology.classify(
        accepted: accepted,
        candidate: lower,
      ),
      throwsA(isA<ContentPackageReplayException>()),
    );

    expect(
      ContentPackageChronology.classify(
        accepted: accepted,
        candidate: accepted,
      ),
      ContentPackageChronologyDecision.idempotent,
    );

    final forkFixture = await fixture(
      payloadBytes: Uint8List.fromList(<int>[10, 11, 12, 13]),
    );
    final fork = ContentPackageIdentity.fromVerified(
      await verifier(forkFixture).verifyBundled(),
    );
    expect(
      () => ContentPackageChronology.classify(
        accepted: accepted,
        candidate: fork,
      ),
      throwsA(isA<ContentPackageReplayException>()),
    );

    final higherFixture = await fixture(releaseSequence: 6);
    final higher = ContentPackageIdentity.fromVerified(
      await verifier(higherFixture).verifyBundled(),
    );
    expect(
      ContentPackageChronology.classify(
        accepted: accepted,
        candidate: higher,
      ),
      ContentPackageChronologyDecision.upgrade,
    );
  });

  test('chronology rejects equal-sequence signed-manifest identity fork',
      () async {
    final acceptedFixture = await fixture();
    final acceptedPackage = await verifier(acceptedFixture).verifyBundled();
    final accepted = ContentPackageIdentity.fromVerified(acceptedPackage);

    final signingEntries = <String, ContentSigningKeyEntry>{
      'content-signing-v1': ContentSigningKeyEntry(
        keyId: 'content-signing-v1',
        publicKey: signingPublicKey,
        sequenceWindow: const ContentSequenceWindow(
          minReleaseSequence: 1,
          maxReleaseSequence: 5,
        ),
      ),
      'content-signing-v2': ContentSigningKeyEntry(
        keyId: 'content-signing-v2',
        publicKey: successorSigningPublicKey,
        sequenceWindow: const ContentSequenceWindow(
          minReleaseSequence: 5,
          maxReleaseSequence: 8,
        ),
      ),
    };
    final forkFixture = await fixture(
      signingKeyId: 'content-signing-v2',
      signingKeyPairOverride: successorSigningKeyPair,
    );
    final forkPackage = await verifier(
      forkFixture,
      signingEntries: signingEntries,
    ).verifyBundled();
    final fork = ContentPackageIdentity.fromVerified(forkPackage);

    expect(
      forkPackage.manifest.sourceContentSha256,
      acceptedPackage.manifest.sourceContentSha256,
    );
    expect(
      forkPackage.manifest.payloadSha256,
      acceptedPackage.manifest.payloadSha256,
    );
    expect(
      forkPackage.manifest.signingKeyId,
      isNot(acceptedPackage.manifest.signingKeyId),
    );
    expect(
      () => ContentPackageChronology.classify(
        accepted: accepted,
        candidate: fork,
      ),
      throwsA(isA<ContentPackageReplayException>()),
    );
  });
}

final class _Fixture {
  const _Fixture({
    required this.manifest,
    required this.manifestBytes,
    required this.signatureBytes,
    required this.payloadBytes,
  });

  final ContentPackageManifest manifest;
  final Uint8List manifestBytes;
  final Uint8List signatureBytes;
  final Uint8List payloadBytes;
}
