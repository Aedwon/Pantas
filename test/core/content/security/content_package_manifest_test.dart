import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/security/content_package_manifest.dart';

void main() {
  const sourceDigest =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  const payloadDigest =
      'abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789';

  group('ContentPackageManifest', () {
    test('writes deterministic manifest v1 bytes in the frozen field order',
        () {
      final manifest = ContentPackageManifest.production(
        sourceContentSha256: sourceDigest,
        payloadSha256: payloadDigest,
      );

      expect(
        utf8.decode(manifest.encode()),
        '{"formatVersion":1,"applicationId":"com.aedwon.pantas",'
        '"releaseChannel":"prod",'
        '"payloadPath":"assets/seed/content.db",'
        '"sourceContentSha256":"$sourceDigest",'
        '"payloadSha256":"$payloadDigest",'
        '"contentSeedVersion":"0123456789abcdef",'
        '"contentSchemaVersion":8,"readerSchemaMin":8,'
        '"readerSchemaMax":8,'
        '"cipherProfile":"pantas-sqlite3mc-content-v1",'
        '"bootstrapKeyId":"content-bootstrap-v1",'
        '"signingKeyId":"content-signing-v1"}\n',
      );
    });

    test('parses and validates the production contract', () {
      final original = ContentPackageManifest.production(
        sourceContentSha256: sourceDigest,
        payloadSha256: payloadDigest,
      );
      final parsed = ContentPackageManifest.parse(original.encode());

      expect(parsed.sourceContentSha256, sourceDigest);
      expect(parsed.payloadSha256, payloadDigest);
      expect(parsed.contentSeedVersion, '0123456789abcdef');
      expect(parsed.validateProduction, returnsNormally);
    });

    test('rejects malformed identities and incompatible production fields', () {
      final valid = ContentPackageManifest.production(
        sourceContentSha256: sourceDigest,
        payloadSha256: payloadDigest,
      ).toJson();

      final cases = <Map<String, Object?>>[
        {...valid, 'applicationId': 'com.example.other'},
        {...valid, 'releaseChannel': 'dev'},
        {...valid, 'payloadPath': 'assets/seed/plain.db'},
        {...valid, 'contentSchemaVersion': 9},
        {...valid, 'readerSchemaMin': 9},
        {...valid, 'readerSchemaMax': 7},
        {...valid, 'cipherProfile': 'other'},
        {...valid, 'bootstrapKeyId': 'other'},
        {...valid, 'signingKeyId': 'other'},
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
