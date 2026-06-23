import 'dart:io';
import 'dart:typed_data';

import 'package:cse_cet_reviewer/core/content/bundle/seed_installer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('content_seed_test_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('a first install writes the file', () async {
    final destination = File(p.join(tempDir.path, 'content.db'));
    final installer = SeedInstaller(
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      destinationFile: () async => destination,
    );

    final wrote = await installer.install(
      installedVersion: null,
      bundledVersion: '2026-07-20',
    );

    expect(wrote, isTrue);
    expect(destination.readAsBytesSync(), [1, 2, 3]);
  });

  test('the same version is not rewritten', () async {
    final destination = File(p.join(tempDir.path, 'content.db'))
      ..writeAsBytesSync([9, 9, 9]);
    final installer = SeedInstaller(
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      destinationFile: () async => destination,
    );

    final wrote = await installer.install(
      installedVersion: '2026-07-20',
      bundledVersion: '2026-07-20',
    );

    expect(wrote, isFalse);
    expect(destination.readAsBytesSync(), [9, 9, 9]);
  });

  test('a newer bundled version replaces the installed file', () async {
    final destination = File(p.join(tempDir.path, 'content.db'))
      ..writeAsBytesSync([9, 9, 9]);
    final installer = SeedInstaller(
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      destinationFile: () async => destination,
    );

    final wrote = await installer.install(
      installedVersion: '2026-07-20',
      bundledVersion: '2026-08-02',
    );

    expect(wrote, isTrue);
    expect(destination.readAsBytesSync(), [1, 2, 3]);
  });

  test('a file that vanished is reinstalled even at the same version',
      () async {
    final destination = File(p.join(tempDir.path, 'content.db'));
    final installer = SeedInstaller(
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      destinationFile: () async => destination,
    );

    final wrote = await installer.install(
      installedVersion: '2026-08-02',
      bundledVersion: '2026-08-02',
    );

    expect(wrote, isTrue);
    expect(destination.existsSync(), isTrue);
  });
}
