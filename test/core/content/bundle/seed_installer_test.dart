import 'dart:io';
import 'dart:typed_data';

import 'package:cse_cet_reviewer/core/content/bundle/seed_installer.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('install copies bundled content db when destination is missing',
      () async {
    final destination = File('${tempDir.path}/content.db');
    final installer = SeedInstaller(
      destinationFile: () async => destination,
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
    );

    await installer.install();

    expect(destination.readAsBytesSync(), equals([1, 2, 3]));
  });

  test('install does not overwrite an existing destination', () async {
    final destination = File('${tempDir.path}/content.db');
    await destination.writeAsBytes([9, 9]);
    final installer = SeedInstaller(
      destinationFile: () async => destination,
      loadAssetBytes: (_) async => Uint8List.fromList([1, 2, 3]),
    );

    await installer.install();

    expect(destination.readAsBytesSync(), equals([9, 9]));
  });

  test('install throws when asset copy fails', () async {
    final destination = File('${tempDir.path}/content.db');
    final installer = SeedInstaller(
      destinationFile: () async => destination,
      loadAssetBytes: (_) => throw StateError('missing asset'),
    );

    expect(installer.install, throwsStateError);
  });
}
