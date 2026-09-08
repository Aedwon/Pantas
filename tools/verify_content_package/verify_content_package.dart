import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hashes;
import 'package:cryptography/cryptography.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';
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
      bootstrapKey: bootstrapKey,
      signingKeyLookup: ContentSigningKeys.lookup,
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
  required Uint8List bootstrapKey,
  required ContentSigningKeyLookup signingKeyLookup,
}) async {
  if (bootstrapKey.length != 32) {
    throw const FormatException('bootstrap key must be exactly 32 bytes');
  }

  final manifestBytes = await manifest.readAsBytes();
  final signatureBytes = await signature.readAsBytes();

  // Parse only far enough to select a candidate public key. No other
  // manifest-controlled identity is accepted until the detached signature
  // over these exact bytes verifies.
  final manifestData = ContentPackageManifest.parse(manifestBytes);
  final publicKey = signingKeyLookup(manifestData.signingKeyId);
  if (publicKey == null) {
    throw const FormatException('untrusted content signing key id');
  }

  final verified = await Ed25519().verify(
    manifestBytes,
    signature: Signature(signatureBytes, publicKey: publicKey),
  );
  if (!verified) {
    throw const FormatException('invalid content manifest signature');
  }

  // Only authenticated manifest identities are validated/trusted below.
  manifestData.validateProduction();

  final payloadBytes = await payload.readAsBytes();
  final payloadSha256 = hashes.sha256.convert(payloadBytes).toString();
  if (payloadSha256 != manifestData.payloadSha256) {
    throw const FormatException('protected content payload digest mismatch');
  }

  ContentCipherProfile.open(payload, bootstrapKey).close();
  return manifestData;
}
