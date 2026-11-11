import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';
import 'package:pantas/core/content/security/content_package_verifier.dart';
import 'package:pantas/core/content/security/content_signing_keys.dart';

Future<void> main(List<String> args) async {
  if (args.length != 3) {
    stderr.writeln(
      'usage: dart run tools/verify_content_package/verify_content_package.dart '
      '<payload> <manifest> <signature>',
    );
    exitCode = 64;
    return;
  }

  try {
    final bootstrapKey = decodeBootstrapKey(
      Platform.environment['PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64'],
    );
    final manifest = await verifyContentPackage(
      payload: File(args[0]),
      manifest: File(args[1]),
      signature: File(args[2]),
      signingKeyLookup: ContentSigningKeys.lookupEntry,
      bootstrapKeyLookup: (keyId) {
        if (keyId != ContentPackageManifest.bootstrapKeyIdV1) return null;
        return ContentBootstrapKeyEntry(
          keyId: keyId,
          keyBytes: bootstrapKey,
          sequenceWindow: const ContentSequenceWindow(minReleaseSequence: 1),
        );
      },
    );
    stdout.writeln(
      'content package verified: ${manifest.contentSeedVersion} '
      '${manifest.payloadSha256}',
    );
  } on Object catch (error) {
    stderr.writeln('content package verification failed: $error');
    exitCode = 1;
  }
}

Uint8List decodeBootstrapKey(String? encoded) {
  if (encoded == null || encoded.isEmpty) {
    throw const FormatException(
      'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64 is missing',
    );
  }

  final List<int> decoded;
  try {
    decoded = base64Decode(encoded);
  } on FormatException {
    throw const FormatException(
      'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64 must be canonical base64',
    );
  }
  if (decoded.length != 32 || base64Encode(decoded) != encoded) {
    throw const FormatException(
      'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64 must encode exactly 32 bytes',
    );
  }
  return Uint8List.fromList(decoded);
}

Future<ContentPackageManifest> verifyContentPackage({
  required File payload,
  required File manifest,
  required File signature,
  required ContentSigningKeyEntryLookup signingKeyLookup,
  required ContentBootstrapKeyEntryLookup bootstrapKeyLookup,
}) async {
  final verifier = BundledContentPackageVerifier(
    loadAssetBytes: (path) async {
      if (path == ContentPackageAssets.manifestPath) {
        return manifest.readAsBytes();
      }
      if (path == ContentPackageAssets.signaturePath) {
        return signature.readAsBytes();
      }
      if (path == ContentPackageAssets.payloadPath) {
        return payload.readAsBytes();
      }
      throw FormatException('unexpected protected content asset path: $path');
    },
    signingKeyLookup: signingKeyLookup,
    bootstrapKeyLookup: bootstrapKeyLookup,
  );
  final verified = await verifier.verifyBundled();
  ContentCipherProfile.open(payload, verified.bootstrapKeyBytes).close();
  return verified.manifest;
}
