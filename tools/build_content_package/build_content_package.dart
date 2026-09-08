import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hashes;
import 'package:cryptography/cryptography.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';

import '../build_content_seed/seed_writer.dart';

Future<void> main(List<String> args) async {
  if (args.length != 4) {
    stderr.writeln(
      'usage: dart run tools/build_content_package/build_content_package.dart '
      '<input-json> <output-directory> <version-file> <release-sequence>',
    );
    exitCode = 64;
    return;
  }

  final releaseSequence = int.tryParse(args[3]);
  if (releaseSequence == null || releaseSequence <= 0) {
    stderr.writeln('release sequence must be a positive integer');
    exitCode = 64;
    return;
  }

  final secrets = ContentPackageBuildSecrets.fromEnvironment(
    Platform.environment,
  );
  await buildContentPackage(
    releaseSequence: releaseSequence,
    inputJson: File(args[0]),
    outputDirectory: Directory(args[1]),
    bootstrapKey: secrets.bootstrapKey,
    signingPrivateKeySeed: secrets.signingPrivateKeySeed,
    versionFile: File(args[2]),
  );
}

final class ContentPackageBuildSecrets {
  ContentPackageBuildSecrets._({
    required this.bootstrapKey,
    required this.signingPrivateKeySeed,
  });

  factory ContentPackageBuildSecrets.fromEnvironment(
    Map<String, String> environment,
  ) {
    return ContentPackageBuildSecrets._(
      bootstrapKey: _decodeKey(
        environment,
        bootstrapKeyEnvironmentVariable,
      ),
      signingPrivateKeySeed: _decodeKey(
        environment,
        signingPrivateKeyEnvironmentVariable,
      ),
    );
  }

  static const bootstrapKeyEnvironmentVariable =
      'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64';
  static const signingPrivateKeyEnvironmentVariable =
      'PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64';

  final Uint8List bootstrapKey;
  final Uint8List signingPrivateKeySeed;

  static Uint8List _decodeKey(
    Map<String, String> environment,
    String name,
  ) {
    final encoded = environment[name];
    if (encoded == null || encoded.isEmpty) {
      throw FormatException('required environment variable $name is missing');
    }

    final List<int> decoded;
    try {
      decoded = base64Decode(encoded);
    } on FormatException {
      throw FormatException('$name must be canonical base64');
    }
    if (decoded.length != 32 || base64Encode(decoded) != encoded) {
      throw FormatException('$name must encode exactly 32 bytes');
    }
    return Uint8List.fromList(decoded);
  }
}

final class ContentPackageBuildResult {
  const ContentPackageBuildResult({
    required this.payload,
    required this.manifest,
    required this.signature,
    required this.manifestData,
  });

  final File payload;
  final File manifest;
  final File signature;
  final ContentPackageManifest manifestData;
}

Future<ContentPackageBuildResult> buildContentPackage({
  required int releaseSequence,
  required File inputJson,
  required Directory outputDirectory,
  required Uint8List bootstrapKey,
  required Uint8List signingPrivateKeySeed,
  required File versionFile,
}) async {
  _requireExactKey(bootstrapKey, 'bootstrapKey');
  _requireExactKey(signingPrivateKeySeed, 'signingPrivateKeySeed');

  final buildTemp = await Directory.systemTemp.createTemp(
    'pantas_content_package_build_',
  );
  try {
    final plaintextThenProtected = File('${buildTemp.path}/content.db');
    await writeContentSeed(
      inputJson: inputJson,
      outputDb: plaintextThenProtected,
    );

    final sourceBytes = await plaintextThenProtected.readAsBytes();
    final sourceContentSha256 = hashes.sha256.convert(sourceBytes).toString();

    ContentCipherProfile.protectPlaintextFile(
      plaintextThenProtected,
      bootstrapKey,
    );

    ContentCipherProfile.open(
      plaintextThenProtected,
      bootstrapKey,
    ).close();

    final payloadBytes = await plaintextThenProtected.readAsBytes();
    final payloadSha256 = hashes.sha256.convert(payloadBytes).toString();
    final manifestData = ContentPackageManifest.production(
      releaseSequence: releaseSequence,
      sourceContentSha256: sourceContentSha256,
      payloadSha256: payloadSha256,
    )..validateProduction();
    final manifestBytes = manifestData.encode();

    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPairFromSeed(signingPrivateKeySeed);
    final detachedSignature = await algorithm.sign(
      manifestBytes,
      keyPair: keyPair,
    );
    final verified = await algorithm.verify(
      manifestBytes,
      signature: detachedSignature,
    );
    if (!verified) {
      throw StateError('generated content manifest signature did not verify');
    }

    await outputDirectory.create(recursive: true);
    final payload = File('${outputDirectory.path}/content.db');
    final manifest = File('${outputDirectory.path}/content.manifest.json');
    final signature = File('${outputDirectory.path}/content.manifest.sig');

    await payload.writeAsBytes(payloadBytes, flush: true);
    await manifest.writeAsBytes(manifestBytes, flush: true);
    await signature.writeAsBytes(detachedSignature.bytes, flush: true);
    await _writeVersionFile(
      versionFile,
      manifestData.contentSeedVersion,
    );

    final emittedPayloadSha256 =
        hashes.sha256.convert(await payload.readAsBytes()).toString();
    if (emittedPayloadSha256 != manifestData.payloadSha256) {
      throw StateError('emitted protected payload digest changed');
    }

    return ContentPackageBuildResult(
      payload: payload,
      manifest: manifest,
      signature: signature,
      manifestData: manifestData,
    );
  } finally {
    if (buildTemp.existsSync()) {
      await buildTemp.delete(recursive: true);
    }
  }
}

Future<void> _writeVersionFile(
  File target,
  String contentSeedVersion,
) async {
  await target.parent.create(recursive: true);
  await target.writeAsString('''
// Written by tools/build_content_package/build_content_package.dart.
// Do not edit by hand.
//
// This revision is derived from the approved plaintext content database
// immediately before protection. Protected payload bytes are intentionally
// randomized and therefore do not define the logical content revision.

const contentSeedVersion = '$contentSeedVersion';
''');
}

void _requireExactKey(Uint8List key, String name) {
  if (key.length != 32) {
    throw ArgumentError.value(key.length, '$name.length', 'must be 32 bytes');
  }
}
