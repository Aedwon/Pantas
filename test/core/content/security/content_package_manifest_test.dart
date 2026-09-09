import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';

void main() {
  const sourceDigest =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  const payloadDigest =
      'abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789';

  group('ContentPackageManifest', () {
    test('writes deterministic manifest v2 bytes in the frozen field order',
        () {
      final manifest = ContentPackageManifest.production(
        releaseSequence: 7,
        sourceContentSha256: sourceDigest,
        payloadSha256: payloadDigest,
      );

      expect(
        utf8.decode(manifest.encode()),
        '{"formatVersion":2,"applicationId":"com.aedwon.pantas",'
        '"releaseChannel":"prod","releaseSequence":7,'
        '"payloadPath":"assets/seed/content.db",'
        '"sourceContentSha256":"$sourceDigest",'
        '"payloadSha256":"$payloadDigest",'
        '"contentSeedVersion":"0123456789abcdef",'
        '"contentSchemaVersion":9,"readerSchemaMin":9,'
        '"readerSchemaMax":9,'
        '"cipherProfile":"pantas-sqlite3mc-content-v1",'
        '"bootstrapKeyId":"content-bootstrap-v1",'
        '"signingKeyId":"content-signing-v1"}\n',
      );
    });

    test('parses and validates the production v2 contract', () {
      final original = ContentPackageManifest.production(
        releaseSequence: 7,
        sourceContentSha256: sourceDigest,
        payloadSha256: payloadDigest,
      );
      final parsed = ContentPackageManifest.parse(original.encode());

      expect(parsed.formatVersion, 2);
      expect(parsed.releaseSequence, 7);
      expect(parsed.sourceContentSha256, sourceDigest);
      expect(parsed.payloadSha256, payloadDigest);
      expect(parsed.contentSeedVersion, '0123456789abcdef');
      expect(parsed.validateProduction, returnsNormally);
    });

    test('rejects v1, missing, zero, and negative release sequences', () {
      final valid = ContentPackageManifest.production(
        releaseSequence: 7,
        sourceContentSha256: sourceDigest,
        payloadSha256: payloadDigest,
      ).toJson();

      final v1 = <String, Object?>{...valid, 'formatVersion': 1}
        ..remove('releaseSequence');
      expect(
        () => ContentPackageManifest.parse(
          utf8.encode('${jsonEncode(v1)}\n'),
        ),
        throwsFormatException,
      );

      for (final releaseSequence in <int>[0, -1]) {
        final bytes = utf8.encode(
          '${jsonEncode({...valid, 'releaseSequence': releaseSequence})}\n',
        );
        final parsed = ContentPackageManifest.parse(bytes);
        expect(parsed.validateProduction, throwsFormatException);
      }
    });

    test('rejects malformed identities and incompatible production fields', () {
      final valid = ContentPackageManifest.production(
        releaseSequence: 7,
        sourceContentSha256: sourceDigest,
        payloadSha256: payloadDigest,
      ).toJson();

      final cases = <Map<String, Object?>>[
        {...valid, 'applicationId': 'com.example.other'},
        {...valid, 'releaseChannel': 'dev'},
        {...valid, 'payloadPath': 'assets/seed/plain.db'},
        {...valid, 'contentSchemaVersion': 10},
        {...valid, 'readerSchemaMin': 10},
        {...valid, 'readerSchemaMax': 8},
        {...valid, 'cipherProfile': 'other'},
        {...valid, 'bootstrapKeyId': ''},
        {...valid, 'signingKeyId': ''},
        {...valid, 'sourceContentSha256': sourceDigest.toUpperCase()},
        {...valid, 'payloadSha256': 'not-a-digest'},
        {...valid, 'contentSeedVersion': 'ffffffffffffffff'},
      ];

      for (final json in cases) {
        final bytes = utf8.encode('${jsonEncode(json)}\n');
        final parsed = ContentPackageManifest.parse(bytes);
        expect(parsed.validateProduction, throwsFormatException);
      }
    });
  });
}
