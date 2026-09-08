import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hashes;
import 'package:cryptography/cryptography.dart';

import 'content_package_manifest.dart';
import 'content_signing_keys.dart';

typedef ContentPackageAssetLoader = Future<Uint8List> Function(String path);

abstract final class ContentPackageAssets {
  static const manifestPath = 'assets/seed/content.manifest.json';
  static const signaturePath = 'assets/seed/content.manifest.sig';
  static const payloadPath = ContentPackageManifest.productionPayloadPath;
}

final class VerifiedContentPackage {
  VerifiedContentPackage({
    required this.manifest,
    required Uint8List payloadBytes,
    required Uint8List bootstrapKeyBytes,
    required this.manifestSha256,
    required this.signatureSha256,
  })  : payloadBytes = Uint8List.fromList(payloadBytes),
        bootstrapKeyBytes = Uint8List.fromList(bootstrapKeyBytes);

  final ContentPackageManifest manifest;
  final Uint8List payloadBytes;
  final Uint8List bootstrapKeyBytes;
  final String manifestSha256;
  final String signatureSha256;
}

abstract interface class ContentPackageVerifier {
  Future<VerifiedContentPackage> verifyBundled();
}

final class BundledContentPackageVerifier implements ContentPackageVerifier {
  const BundledContentPackageVerifier({
    required ContentPackageAssetLoader loadAssetBytes,
    required ContentSigningKeyEntryLookup signingKeyLookup,
    required ContentBootstrapKeyEntryLookup bootstrapKeyLookup,
  })  : _loadAssetBytes = loadAssetBytes,
        _signingKeyLookup = signingKeyLookup,
        _bootstrapKeyLookup = bootstrapKeyLookup;

  final ContentPackageAssetLoader _loadAssetBytes;
  final ContentSigningKeyEntryLookup _signingKeyLookup;
  final ContentBootstrapKeyEntryLookup _bootstrapKeyLookup;

  @override
  Future<VerifiedContentPackage> verifyBundled() async {
    final manifestBytes =
        await _loadAssetBytes(ContentPackageAssets.manifestPath);
    final signatureBytes =
        await _loadAssetBytes(ContentPackageAssets.signaturePath);

    // Parse only far enough to select the claimed verification key. All
    // manifest-controlled semantics remain untrusted until the exact bytes are
    // authenticated by Ed25519 below.
    final manifest = ContentPackageManifest.parse(manifestBytes);
    final signingEntry = _signingKeyLookup(manifest.signingKeyId);
    if (signingEntry == null || signingEntry.keyId != manifest.signingKeyId) {
      throw const FormatException('untrusted content signing key id');
    }

    final signatureValid = await _verifySignature(
      manifestBytes: manifestBytes,
      signatureBytes: signatureBytes,
      publicKey: signingEntry.publicKey,
    );
    if (!signatureValid) {
      throw const FormatException('invalid content manifest signature');
    }

    manifest.validateProduction();
    if (!signingEntry.sequenceWindow.contains(manifest.releaseSequence)) {
      throw const FormatException(
          'content signing key is out of sequence window');
    }

    final bootstrapEntry = _bootstrapKeyLookup(manifest.bootstrapKeyId);
    if (bootstrapEntry == null ||
        bootstrapEntry.keyId != manifest.bootstrapKeyId) {
      throw const FormatException('untrusted content bootstrap key id');
    }
    if (bootstrapEntry.keyBytes.length != 32) {
      throw const FormatException(
          'content bootstrap key must be exactly 32 bytes');
    }
    if (!bootstrapEntry.sequenceWindow.contains(manifest.releaseSequence)) {
      throw const FormatException(
          'content bootstrap key is out of sequence window');
    }

    final payloadBytes = await _loadAssetBytes(manifest.payloadPath);
    final payloadSha256 = hashes.sha256.convert(payloadBytes).toString();
    if (payloadSha256 != manifest.payloadSha256) {
      throw const FormatException('protected content payload digest mismatch');
    }

    return VerifiedContentPackage(
      manifest: manifest,
      payloadBytes: payloadBytes,
      bootstrapKeyBytes: bootstrapEntry.keyBytes,
      manifestSha256: hashes.sha256.convert(manifestBytes).toString(),
      signatureSha256: hashes.sha256.convert(signatureBytes).toString(),
    );
  }

  Future<bool> _verifySignature({
    required Uint8List manifestBytes,
    required Uint8List signatureBytes,
    required SimplePublicKey publicKey,
  }) async {
    try {
      return await Ed25519().verify(
        manifestBytes,
        signature: Signature(signatureBytes, publicKey: publicKey),
      );
    } on Object {
      return false;
    }
  }
}

final class ContentPackageIdentity {
  const ContentPackageIdentity({
    required this.formatVersion,
    required this.releaseSequence,
    required this.manifestSha256,
    required this.signatureSha256,
    required this.payloadSha256,
  });

  factory ContentPackageIdentity.fromVerified(VerifiedContentPackage package) {
    return ContentPackageIdentity(
      formatVersion: package.manifest.formatVersion,
      releaseSequence: package.manifest.releaseSequence,
      manifestSha256: package.manifestSha256,
      signatureSha256: package.signatureSha256,
      payloadSha256: package.manifest.payloadSha256,
    );
  }

  final int formatVersion;
  final int releaseSequence;
  final String manifestSha256;
  final String signatureSha256;
  final String payloadSha256;

  bool hasExactBoundIdentity(ContentPackageIdentity other) =>
      formatVersion == other.formatVersion &&
      releaseSequence == other.releaseSequence &&
      manifestSha256 == other.manifestSha256 &&
      signatureSha256 == other.signatureSha256 &&
      payloadSha256 == other.payloadSha256;
}

enum ContentPackageChronologyDecision { freshInstall, idempotent, upgrade }

final class ContentPackageReplayException implements Exception {
  const ContentPackageReplayException(this.message);

  final String message;

  @override
  String toString() => 'ContentPackageReplayException: $message';
}

abstract final class ContentPackageChronology {
  static ContentPackageChronologyDecision classify({
    required ContentPackageIdentity? accepted,
    required ContentPackageIdentity candidate,
  }) {
    if (accepted == null) {
      return ContentPackageChronologyDecision.freshInstall;
    }
    if (candidate.releaseSequence < accepted.releaseSequence) {
      throw const ContentPackageReplayException(
        'candidate release sequence is lower than accepted sequence',
      );
    }
    if (candidate.releaseSequence == accepted.releaseSequence) {
      if (!candidate.hasExactBoundIdentity(accepted)) {
        throw const ContentPackageReplayException(
          'candidate forks the accepted release sequence',
        );
      }
      return ContentPackageChronologyDecision.idempotent;
    }
    return ContentPackageChronologyDecision.upgrade;
  }
}
