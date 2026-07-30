import 'dart:io';

import 'package:pantas/core/content/content_database_opener.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef AssetBytesLoader = Future<Uint8List> Function(String assetPath);
typedef DestinationFileResolver = Future<File> Function();

class SeedInstaller {
  SeedInstaller({
    AssetBytesLoader? loadAssetBytes,
    DestinationFileResolver? destinationFile,
    this.assetPath = 'assets/seed/content.db',
  })  : _loadAssetBytes = loadAssetBytes ?? _loadFromRootBundle,
        _destinationFile = destinationFile ?? _defaultDestinationFile;

  final AssetBytesLoader _loadAssetBytes;
  final DestinationFileResolver _destinationFile;
  final String assetPath;

  /// Writes the bundled database to disk when the installed copy is missing or
  /// older than the bundled one. Returns true when it wrote.
  ///
  /// The file's existence is checked as well as the version, because the two
  /// can disagree: the OS may clear application support without the recorded
  /// version changing, and trusting the version alone would leave the app with
  /// no database at all.
  Future<bool> install({
    required String? installedVersion,
    required String bundledVersion,
  }) async {
    final destination = await _destinationFile();
    final upToDate =
        installedVersion == bundledVersion && destination.existsSync();
    if (upToDate) return false;

    await destination.parent.create(recursive: true);
    final bytes = await _loadAssetBytes(assetPath);
    await destination.writeAsBytes(bytes, flush: true);
    return true;
  }

  static Future<Uint8List> _loadFromRootBundle(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  static Future<File> _defaultDestinationFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, contentDbFileName));
  }
}
