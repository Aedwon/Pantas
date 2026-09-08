import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('pantas sqlite3mc content profile', () {
    test('protects plaintext in place, checks HMACs, and rekeys safely',
        () async {
      final directory =
          await Directory.systemTemp.createTemp('pantas-e04-profile-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });

      final file = File('${directory.path}/content.db');
      const fixture = 'E04_RAW_FIXTURE_NEEDLE_DO_NOT_SHIP';
      final firstKey = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      final secondKey =
          Uint8List.fromList(List<int>.generate(32, (i) => 255 - i));
      final wrongKey = Uint8List.fromList(List<int>.filled(32, 0x5a));

      expect(
        () => ContentCipherProfile.open(file, Uint8List(31)),
        throwsArgumentError,
      );

      sqlite3.open(file.path)
        ..execute('PRAGMA journal_mode = DELETE;')
        ..execute('CREATE TABLE fixture(value TEXT NOT NULL);')
        ..execute('INSERT INTO fixture(value) VALUES (?)', [fixture])
        ..close();

      expect(
        utf8.decode(file.readAsBytesSync().take(16).toList()),
        'SQLite format 3\u0000',
      );

      ContentCipherProfile.protectPlaintextFile(file, firstKey);

      final protectedBytes = file.readAsBytesSync();
      expect(
        utf8.decode(protectedBytes.take(16).toList(), allowMalformed: true),
        isNot('SQLite format 3\u0000'),
      );
      expect(_containsBytes(protectedBytes, utf8.encode(fixture)), isFalse);

      expect(
        () {
          final unkeyed = sqlite3.open(file.path);
          addTearDown(unkeyed.close);
          unkeyed.select('SELECT value FROM fixture;');
        },
        throwsA(anything),
      );
      expect(
        () => ContentCipherProfile.open(file, wrongKey),
        throwsA(anything),
      );

      final first = ContentCipherProfile.open(file, firstKey);
      expect(
        first.select('SELECT value FROM fixture;').single['value'],
        fixture,
      );
      expect(
        first.select('PRAGMA journal_mode;').single.values.single,
        'delete',
      );
      expect(
        first.select('PRAGMA legacy;').single.values.single.toString(),
        '0',
      );
      expect(
        first.select('PRAGMA hmac_use;').single.values.single.toString(),
        '1',
      );
      expect(
        first.select('PRAGMA hmac_check;').single.values.single.toString(),
        '1',
      );
      expect(
        first
            .select('PRAGMA plaintext_header_size;')
            .single
            .values
            .single
            .toString(),
        '0',
      );
      expect(
        first.select('PRAGMA integrity_check;').single.values.single,
        'ok',
      );
      final pageSize = int.parse(
        first.select('PRAGMA page_size;').single.values.single.toString(),
      );
      first.close();

      final tamperedFile = File('${directory.path}/tampered.db');
      final tamperedBytes = Uint8List.fromList(protectedBytes);
      final tamperOffset = pageSize + 100;
      expect(tamperedBytes.length, greaterThan(tamperOffset));
      tamperedBytes[tamperOffset] ^= 0x01;
      tamperedFile.writeAsBytesSync(tamperedBytes, flush: true);
      expect(
        () {
          final tampered = ContentCipherProfile.open(tamperedFile, firstKey);
          addTearDown(tampered.close);
          tampered.select('SELECT value FROM fixture;');
        },
        throwsA(anything),
      );

      final beforeRekey = ContentCipherProfile.open(file, firstKey);
      expect(
        beforeRekey.select('PRAGMA integrity_check;').single.values.single,
        'ok',
      );
      ContentCipherProfile.rekey(beforeRekey, secondKey);
      beforeRekey.close();

      expect(
        () => ContentCipherProfile.open(file, firstKey),
        throwsA(anything),
      );
      final second = ContentCipherProfile.open(file, secondKey);
      expect(
        second.select('SELECT value FROM fixture;').single['value'],
        fixture,
      );
      expect(
        second.select('PRAGMA hmac_use;').single.values.single.toString(),
        '1',
      );
      expect(
        second.select('PRAGMA hmac_check;').single.values.single.toString(),
        '1',
      );
      expect(
        second.select('PRAGMA integrity_check;').single.values.single,
        'ok',
      );
      second.close();

      final siblings = directory
          .listSync()
          .whereType<File>()
          .map((entry) => entry.uri.pathSegments.last)
          .where(
            (name) =>
                name.endsWith('-wal') ||
                name.endsWith('-shm') ||
                name.endsWith('-journal'),
          )
          .toList();
      expect(siblings, isEmpty);
    });
  });
}

bool _containsBytes(List<int> haystack, List<int> needle) {
  if (needle.isEmpty) return true;
  for (var offset = 0; offset <= haystack.length - needle.length; offset++) {
    var matches = true;
    for (var i = 0; i < needle.length; i++) {
      if (haystack[offset + i] != needle[i]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}
