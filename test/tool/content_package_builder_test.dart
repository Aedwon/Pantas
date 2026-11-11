import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hashes;
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';

import '../../tools/build_content_package/build_content_package.dart';

void main() {
  const marker = 'Pick the synonym.';

  group('content package builder', () {
    late Directory tempDir;

    setUp(() {
      tempDir =
          Directory.systemTemp.createTempSync('pantas_content_package_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('protects, identifies, and signs exact package bytes', () async {
      final bootstrapKey = Uint8List.fromList(
        List<int>.generate(32, (index) => index + 1),
      );
      final signingSeed = Uint8List.fromList(
        List<int>.generate(32, (index) => 0xf0 - index),
      );
      final input = File('test/fixtures/sanity/content_sample.json');
      final firstOutput = Directory('${tempDir.path}/first');
      final secondOutput = Directory('${tempDir.path}/second');
      final firstVersion = File('${tempDir.path}/first_version.dart');
      final secondVersion = File('${tempDir.path}/second_version.dart');

      final first = await buildContentPackage(
        releaseSequence: 7,
        inputJson: input,
        outputDirectory: firstOutput,
        bootstrapKey: bootstrapKey,
        signingPrivateKeySeed: signingSeed,
        versionFile: firstVersion,
      );
      final second = await buildContentPackage(
        releaseSequence: 8,
        inputJson: input,
        outputDirectory: secondOutput,
        bootstrapKey: bootstrapKey,
        signingPrivateKeySeed: signingSeed,
        versionFile: secondVersion,
      );

      expect(first.payload.existsSync(), isTrue);
      expect(first.manifest.existsSync(), isTrue);
      expect(first.signature.existsSync(), isTrue);

      final payloadBytes = first.payload.readAsBytesSync();
      expect(
        _containsBytes(payloadBytes, utf8.encode('SQLite format 3')),
        isFalse,
      );
      expect(_containsBytes(payloadBytes, utf8.encode(marker)), isFalse);
      expect(
        hashes.sha256.convert(payloadBytes).toString(),
        first.manifestData.payloadSha256,
      );

      ContentCipherProfile.open(first.payload, bootstrapKey).close();
      expect(
        () => ContentCipherProfile.open(
          first.payload,
          Uint8List.fromList(List<int>.filled(32, 0x55)),
        ),
        throwsA(anything),
      );

      final manifestBytes = first.manifest.readAsBytesSync();
      expect(
        ContentPackageManifest.parse(manifestBytes).validateProduction,
        returnsNormally,
      );
      expect(first.manifestData.formatVersion, 2);
      // The manifest declares the schema of the payload it carries, so an
      // older reader rejects a newer package at the manifest step.
      final payloadSchema = ContentDatabase(NativeDatabase.memory());
      addTearDown(payloadSchema.close);
      expect(
        first.manifestData.contentSchemaVersion,
        payloadSchema.schemaVersion,
      );
      expect(
        first.manifestData.readerSchemaMin,
        payloadSchema.schemaVersion,
      );
      expect(
        first.manifestData.readerSchemaMax,
        payloadSchema.schemaVersion,
      );
      expect(first.manifestData.releaseSequence, 7);
      expect(second.manifestData.releaseSequence, 8);
      expect(
        first.manifestData.sourceContentSha256,
        second.manifestData.sourceContentSha256,
      );
      expect(
        first.manifestData.contentSeedVersion,
        second.manifestData.contentSeedVersion,
      );
      expect(
        first.manifestData.payloadSha256,
        isNot(second.manifestData.payloadSha256),
      );
      expect(
        first.payload.readAsBytesSync(),
        isNot(second.payload.readAsBytesSync()),
      );

      final contentSeedVersion = first.manifestData.contentSeedVersion;
      expect(
        firstVersion.readAsStringSync(),
        contains("const contentSeedVersion = '$contentSeedVersion';"),
      );

      final algorithm = Ed25519();
      final keyPair = await algorithm.newKeyPairFromSeed(signingSeed);
      final publicKey = await keyPair.extractPublicKey();
      final signature = Signature(
        first.signature.readAsBytesSync(),
        publicKey: publicKey,
      );
      expect(
        await algorithm.verify(manifestBytes, signature: signature),
        isTrue,
      );

      final reformatted = utf8.encode(
        '${const JsonEncoder.withIndent('  ').convert(
          first.manifestData.toJson(),
        )}\n',
      );
      expect(reformatted, isNot(manifestBytes));
      expect(
        await algorithm.verify(reformatted, signature: signature),
        isFalse,
      );

      final tamperedPayload = Uint8List.fromList(payloadBytes)
        ..[payloadBytes.length - 1] ^= 0x01;
      expect(
        hashes.sha256.convert(tamperedPayload).toString(),
        isNot(first.manifestData.payloadSha256),
      );

      final privateSeedBase64 = base64Encode(signingSeed);
      for (final file in [first.manifest, first.signature]) {
        expect(
          _containsBytes(
            file.readAsBytesSync(),
            utf8.encode(privateSeedBase64),
          ),
          isFalse,
        );
        expect(_containsBytes(file.readAsBytesSync(), signingSeed), isFalse);
      }
    });

    test('build secrets fail closed when missing or malformed', () {
      final goodBootstrap = base64Encode(List<int>.filled(32, 0x11));
      final goodSigning = base64Encode(List<int>.filled(32, 0x22));

      expect(
        ContentPackageBuildSecrets.fromEnvironment({
          'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64': goodBootstrap,
          'PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64': goodSigning,
        }).bootstrapKey,
        hasLength(32),
      );

      for (final environment in <Map<String, String>>[
        const {},
        {'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64': goodBootstrap},
        {
          'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64': 'not-base64',
          'PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64': goodSigning,
        },
        {
          'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64':
              base64Encode(List<int>.filled(31, 1)),
          'PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64': goodSigning,
        },
        {
          'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64': goodBootstrap,
          'PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64':
              base64Encode(List<int>.filled(31, 2)),
        },
      ]) {
        expect(
          () => ContentPackageBuildSecrets.fromEnvironment(environment),
          throwsFormatException,
        );
      }
    });
  });
}

bool _containsBytes(List<int> haystack, List<int> needle) {
  if (needle.isEmpty) return true;
  for (var start = 0; start <= haystack.length - needle.length; start++) {
    var matches = true;
    for (var offset = 0; offset < needle.length; offset++) {
      if (haystack[start + offset] != needle[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}
