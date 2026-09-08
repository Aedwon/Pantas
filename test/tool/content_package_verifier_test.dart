import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';

import '../../tools/build_content_package/build_content_package.dart';
import '../../tools/verify_content_package/verify_content_package.dart';

void main() {
  group('protected content package verifier', () {
    late Directory tempDir;
    late ContentPackageBuildResult package;
    late Uint8List bootstrapKey;
    late Uint8List signingSeed;
    late SimplePublicKey publicKey;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('pantas_verify_content_');
      bootstrapKey = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      signingSeed = Uint8List.fromList(List<int>.generate(32, (i) => 0xc0 - i));
      package = await buildContentPackage(
        inputJson: File('test/fixtures/sanity/content_sample.json'),
        outputDirectory: Directory('${tempDir.path}/package'),
        bootstrapKey: bootstrapKey,
        signingPrivateKeySeed: signingSeed,
        versionFile: File('${tempDir.path}/content_seed_version.dart'),
      );
      publicKey = await (await Ed25519().newKeyPairFromSeed(signingSeed))
          .extractPublicKey();
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    SimplePublicKey? trustedLookup(String keyId) =>
        keyId == ContentPackageManifest.signingKeyIdV1 ? publicKey : null;

    Future<ContentPackageManifest> verify({
      File? payload,
      File? manifest,
      File? signature,
      Uint8List? key,
    }) {
      return verifyContentPackage(
        payload: payload ?? package.payload,
        manifest: manifest ?? package.manifest,
        signature: signature ?? package.signature,
        bootstrapKey: key ?? bootstrapKey,
        signingKeyLookup: trustedLookup,
      );
    }

    test('accepts exact signed bytes and correct bootstrap key', () async {
      final manifest = await verify();
      expect(
        manifest.contentSeedVersion,
        package.manifestData.contentSeedVersion,
      );
    });

    test('fails closed for missing or invalid detached signature', () async {
      final missing = File('${tempDir.path}/missing.sig');
      await expectLater(verify(signature: missing), throwsA(anything));

      final invalid = File('${tempDir.path}/invalid.sig')
        ..writeAsBytesSync(package.signature.readAsBytesSync());
      final bytes = invalid.readAsBytesSync()..[0] ^= 0x01;
      invalid.writeAsBytesSync(bytes);
      await expectLater(verify(signature: invalid), throwsA(anything));
    });

    test('signature covers exact manifest bytes', () async {
      final changed = File('${tempDir.path}/changed.manifest.json')
        ..writeAsBytesSync([
          ...package.manifest.readAsBytesSync(),
          ...utf8.encode(' '),
        ]);
      await expectLater(verify(manifest: changed), throwsA(anything));
    });

    test('changed encrypted payload fails signed digest check', () async {
      final changed = File('${tempDir.path}/changed.db')
        ..writeAsBytesSync(package.payload.readAsBytesSync());
      final bytes = changed.readAsBytesSync()
        ..[bytesLength(changed) - 1] ^= 0x01;
      changed.writeAsBytesSync(bytes);
      await expectLater(verify(payload: changed), throwsA(anything));
    });

    test('wrong bootstrap key cannot open protected database', () async {
      await expectLater(
        verify(key: Uint8List.fromList(List<int>.filled(32, 0x55))),
        throwsA(anything),
      );
    });

    test(
        'untrusted signing key id fails before manifest identities '
        'are accepted', () async {
      final changed = await _signedManifest(
        tempDir: tempDir,
        base: package.manifestData,
        signingSeed: signingSeed,
        overrides: const {'signingKeyId': 'untrusted-key'},
        name: 'untrusted',
      );
      await expectLater(
        verify(manifest: changed.manifest, signature: changed.signature),
        throwsA(anything),
      );
    });

    test('signed schema channel application and profile mismatches fail',
        () async {
      final cases = <String, Object>{
        'contentSchemaVersion': 9,
        'releaseChannel': 'staging',
        'applicationId': 'com.example.other',
        'cipherProfile': 'other-profile',
      };
      for (final entry in cases.entries) {
        final changed = await _signedManifest(
          tempDir: tempDir,
          base: package.manifestData,
          signingSeed: signingSeed,
          overrides: {entry.key: entry.value},
          name: entry.key,
        );
        await expectLater(
          verify(manifest: changed.manifest, signature: changed.signature),
          throwsA(anything),
          reason: entry.key,
        );
      }
    });
  });
}

int bytesLength(File file) => file.lengthSync();

Future<({File manifest, File signature})> _signedManifest({
  required Directory tempDir,
  required ContentPackageManifest base,
  required Uint8List signingSeed,
  required Map<String, Object> overrides,
  required String name,
}) async {
  final json = <String, Object>{...base.toJson(), ...overrides};
  final bytes = utf8.encode('${jsonEncode(json)}\n');
  final keyPair = await Ed25519().newKeyPairFromSeed(signingSeed);
  final signature = await Ed25519().sign(bytes, keyPair: keyPair);
  final manifestFile = File('${tempDir.path}/$name.manifest.json')
    ..writeAsBytesSync(bytes);
  final signatureFile = File('${tempDir.path}/$name.manifest.sig')
    ..writeAsBytesSync(signature.bytes);
  return (manifest: manifestFile, signature: signatureFile);
}
