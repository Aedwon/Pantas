import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/bundle/seed_installer.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/content_database_opener.dart';
import 'package:pantas/core/content/security/content_cipher_profile.dart';

import '../../../tools/build_content_seed/seed_writer.dart';
import 'test_content_fixture.dart';

typedef ReleaseTestContentOpener = Future<ContentDatabase> Function(
  Uint8List fixtureKey,
);

final class ReleaseTestContentInstallation {
  ReleaseTestContentInstallation({
    required this.exportJson,
    required this.generatedSeed,
    required this.providerContainer,
    required this.database,
    required this.openInstalledContent,
  });

  final File exportJson;
  final File generatedSeed;
  final ProviderContainer providerContainer;
  final ContentDatabase database;
  final Future<ContentDatabase> Function() openInstalledContent;

  bool _disposed = false;

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    providerContainer.dispose();
    await database.close();
  }
}

Future<ReleaseTestContentInstallation> installReleaseTestContent({
  required Directory buildDirectory,
  DestinationFileResolver? destinationFile,
  ReleaseTestContentOpener? openContent,
}) async {
  await buildDirectory.create(recursive: true);
  final exportJson = File('${buildDirectory.path}/release-e2e-content.json');
  final generatedSeed = File('${buildDirectory.path}/release-e2e-content.db');

  await exportJson.writeAsString(jsonEncode(releaseTestContentDocument()));
  if (generatedSeed.existsSync()) {
    await generatedSeed.delete();
  }
  await writeContentSeed(inputJson: exportJson, outputDb: generatedSeed);
  final fixtureKey = Uint8List.fromList(List<int>.filled(32, 0x52));
  ContentCipherProfile.protectPlaintextFile(generatedSeed, fixtureKey);

  final installer = SeedInstaller(
    loadAssetBytes: (_) async =>
        Uint8List.fromList(await generatedSeed.readAsBytes()),
    destinationFile: destinationFile,
  );
  await installer.install(
    installedVersion: null,
    bundledVersion: 'release-e2e-fixture-v1',
  );

  final resolvedOpenContent =
      openContent ?? (key) => openProtectedContentDatabase(key: key);
  final overrides = await bootstrapContentOverrides(
    open: () => resolvedOpenContent(fixtureKey),
  );
  final providerContainer = ProviderContainer(overrides: overrides);
  final database = providerContainer.read(contentDatabaseProvider);

  return ReleaseTestContentInstallation(
    exportJson: exportJson,
    generatedSeed: generatedSeed,
    providerContainer: providerContainer,
    database: database,
    openInstalledContent: () => resolvedOpenContent(fixtureKey),
  );
}
