import 'dart:io';
import 'dart:typed_data';

import 'package:cse_cet_reviewer/core/content/content_database_opener.dart';
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

  Future<void> install() async {
    final destination = await _destinationFile();
    if (destination.existsSync()) return;
    await destination.parent.create(recursive: true);
    final bytes = await _loadAssetBytes(assetPath);
    await destination.writeAsBytes(bytes, flush: true);
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
