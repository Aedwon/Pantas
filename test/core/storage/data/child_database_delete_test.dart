import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/child_database_name.dart';
import 'package:pantas/core/storage/data/database_opener_native.dart';

void main() {
  test('a child store is named from a hash of the uid, as T6 names it',
      () async {
    final digest = await Sha256().hash(utf8.encode('child-1'));
    final expected = 'pantas-child-'
        '${base64Url.encode(digest.bytes).replaceAll('=', '')}';
    expect(await childDatabaseName('child-1'), expected);
    expect(await childDatabaseName('child-2'), isNot(expected));
  });

  group('deleting a store file (native)', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('pantas-store'));
    tearDown(() => dir.deleteSync(recursive: true));

    File file(String name) => File('${dir.path}/$name');

    test('removes the database and its sidecar files, and only those',
        () async {
      for (final name in [
        'pantas-child-a.db',
        'pantas-child-a.db-wal',
        'pantas-child-a.db-shm',
        'pantas-child-a.db-journal',
        'pantas-child-b.db',
        'pantas.db',
      ]) {
        file(name).writeAsStringSync('x');
      }
      await deleteEncryptedDatabase(
        databaseName: 'pantas-child-a',
        directory: dir,
      );
      expect(file('pantas-child-a.db').existsSync(), isFalse);
      expect(file('pantas-child-a.db-wal').existsSync(), isFalse);
      expect(file('pantas-child-a.db-shm').existsSync(), isFalse);
      expect(file('pantas-child-a.db-journal').existsSync(), isFalse);
      expect(file('pantas-child-b.db').existsSync(), isTrue);
      expect(file('pantas.db').existsSync(), isTrue);
    });

    test('a store that is not there is not an error', () async {
      await deleteEncryptedDatabase(
        databaseName: 'pantas-child-missing',
        directory: dir,
      );
    });
  });
}
