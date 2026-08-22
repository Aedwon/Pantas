import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools/lesson_illustrations/upload_assets.dart';

void main() {
  late Directory tempDir;
  late File imageFile;
  late String digest;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('lesson_assets_');
    imageFile = File('${tempDir.path}/content/illustrations/diagram.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(<int>[1, 2, 3, 4]);
    digest = sha256.convert(imageFile.readAsBytesSync()).toString();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('uploads a new asset and writes the complete asset map', () async {
    final uploader = _MemoryUploader();
    final mapFile = File('${tempDir.path}/content/illustrations/assets.json');

    final result = await synchronizeAssets(
      assetMapFile: mapFile,
      dryRun: false,
      records: [_record(digest)],
      repositoryRoot: tempDir,
      strategy: _strategy,
      uploader: uploader,
    );

    expect(result.writes, 1);
    expect(result.ready, 1);
    expect(uploader.uploadedKeys, ['science/biology/cells#1']);
    final json = jsonDecode(mapFile.readAsStringSync()) as Map<String, Object?>;
    expect(
      json['science/biology/cells#1'],
      containsPair('assetId', 'image-new'),
    );
    expect(
      json['science/biology/cells#1'],
      containsPair('sha256', digest),
    );
    expect(
      json['science/biology/cells#1'],
      containsPair('creditKey', 'science/biology/cells#1'),
    );
  });

  test('skips an asset whose committed digest is unchanged', () async {
    final uploader = _MemoryUploader();
    final mapFile = await _writeAssetMap(tempDir, digest: digest);

    final result = await synchronizeAssets(
      assetMapFile: mapFile,
      dryRun: false,
      records: [_record(digest)],
      repositoryRoot: tempDir,
      strategy: _strategy,
      uploader: uploader,
    );

    expect(result.unchanged, 1);
    expect(result.writes, 0);
    expect(uploader.uploadedKeys, isEmpty);
  });

  test('uploads a replacement when the digest changed', () async {
    final uploader = _MemoryUploader();
    final mapFile = await _writeAssetMap(tempDir, digest: _zeroDigest);

    final result = await synchronizeAssets(
      assetMapFile: mapFile,
      dryRun: false,
      records: [_record(digest)],
      repositoryRoot: tempDir,
      strategy: _strategy,
      uploader: uploader,
    );

    expect(result.replaced, 1);
    expect(result.writes, 1);
    expect(uploader.uploadedKeys, ['science/biology/cells#1']);
  });

  test('live uploader rejects missing credentials', () {
    expect(
      () => SanityAssetUploader.fromEnvironment(const {}),
      throwsA(
        isA<AssetUploadException>().having(
          (error) => error.message,
          'message',
          contains('SANITY_PROJECT_ID'),
        ),
      ),
    );
  });

  test('rejects a license that forbids commercial reuse', () async {
    expect(
      () => synchronizeAssets(
        assetMapFile: File(
          '${tempDir.path}/content/illustrations/assets.json',
        ),
        dryRun: true,
        records: [_record(digest, license: 'CC BY-NC 4.0')],
        repositoryRoot: tempDir,
        strategy: _strategy,
        uploader: _MemoryUploader(),
      ),
      throwsA(isA<AssetManifestException>()),
    );
  });

  test('dry-run validates readiness without upload or map write', () async {
    final uploader = _MemoryUploader();
    final mapFile = File('${tempDir.path}/content/illustrations/assets.json');

    final result = await synchronizeAssets(
      assetMapFile: mapFile,
      dryRun: true,
      records: [_record(digest)],
      repositoryRoot: tempDir,
      strategy: _strategy,
      uploader: uploader,
    );

    expect(result.ready, 1);
    expect(result.missing, 0);
    expect(result.writes, 0);
    expect(uploader.uploadedKeys, isEmpty);
    expect(mapFile.existsSync(), isFalse);
  });

  test('loads the frozen YAML and strategy TSV contracts', () {
    final manifest = File('${tempDir.path}/open-a.yaml')..writeAsStringSync('''
version: 1
assets:
  - key: science/biology/cells#1
    sourcePage: https://commons.wikimedia.org/wiki/File:Cell.svg
    directUrl: https://upload.wikimedia.org/cell.svg
    license: CC BY-SA 4.0
    creator: Example Author
    credit: Example Author, CC BY-SA 4.0.
    target: content/illustrations/diagram.png
    sha256: $digest
''');
    final strategyFile = File('${tempDir.path}/strategy.tsv')
      ..writeAsStringSync(
        'subject\ttopic\tlesson\tseq\ttarget_file\tdescription\t'
        'strategy\tbatch\n'
        'science\tbiology\tcells\t1\tcontent/illustrations/diagram.png\t'
        'A labeled cell diagram.\topen\topen-a\n',
      );

    final records = loadOpenAssetManifests([manifest]);
    final strategy = loadOpenStrategy(strategyFile);

    expect(records, hasLength(1));
    expect(records.single.sha256, digest);
    expect(records.single.license, 'CC BY-SA 4.0');
    expect(strategy['science/biology/cells#1']?.alt, 'A labeled cell diagram.');
  });

  test('does not replace assets.json when any upload fails', () async {
    final second = File(
      '${tempDir.path}/content/illustrations/second.png',
    )
      ..createSync(recursive: true)
      ..writeAsBytesSync(<int>[5, 6, 7, 8]);
    final secondDigest = sha256.convert(second.readAsBytesSync()).toString();
    final mapFile = await _writeAssetMap(tempDir, digest: _zeroDigest);
    final original = mapFile.readAsStringSync();
    final uploader = _MemoryUploader(failOnKey: 'science/biology/cells#2');

    await expectLater(
      () => synchronizeAssets(
        assetMapFile: mapFile,
        dryRun: false,
        records: [
          _record(digest),
          _record(
            secondDigest,
            key: 'science/biology/cells#2',
            target: 'content/illustrations/second.png',
          ),
        ],
        repositoryRoot: tempDir,
        strategy: {
          ..._strategy,
          'science/biology/cells#2': const StrategyAsset(
            alt: 'A second cell diagram.',
            key: 'science/biology/cells#2',
            target: 'content/illustrations/second.png',
          ),
        },
        uploader: uploader,
      ),
      throwsA(isA<AssetUploadException>()),
    );

    expect(mapFile.readAsStringSync(), original);
  });
}

const _strategy = <String, StrategyAsset>{
  'science/biology/cells#1': StrategyAsset(
    alt: 'A labeled cell diagram.',
    key: 'science/biology/cells#1',
    target: 'content/illustrations/diagram.png',
  ),
};

const _zeroDigest =
    '0000000000000000000000000000000000000000000000000000000000000000';

OpenAssetRecord _record(
  String digest, {
  String key = 'science/biology/cells#1',
  String license = 'CC BY 4.0',
  String target = 'content/illustrations/diagram.png',
}) =>
    OpenAssetRecord(
      creator: 'OpenStax',
      credit: 'OpenStax, CC BY 4.0.',
      directUrl: Uri.parse('https://openstax.org/image.png'),
      key: key,
      license: license,
      sha256: digest,
      sourcePage: Uri.parse('https://openstax.org/books/biology/pages/1'),
      target: target,
    );

Future<File> _writeAssetMap(
  Directory directory, {
  required String digest,
}) async {
  final file = File('${directory.path}/content/illustrations/assets.json')
    ..createSync(recursive: true);
  await file.writeAsString(
    jsonEncode({
      'science/biology/cells#1': {
        'assetId': 'image-old',
        'url': 'https://cdn.sanity.io/images/demo/production/old.png',
        'sha256': digest,
        'alt': 'A labeled cell diagram.',
        'creditKey': 'science/biology/cells#1',
      },
    }),
  );
  return file;
}

class _MemoryUploader implements AssetUploader {
  _MemoryUploader({this.failOnKey});

  final String? failOnKey;
  final List<String> uploadedKeys = [];

  @override
  Future<UploadedAsset> upload(OpenAssetRecord record, File file) async {
    if (record.key == failOnKey) {
      throw AssetUploadException('Upload failed for ${record.key}.');
    }
    uploadedKeys.add(record.key);
    return const UploadedAsset(
      assetId: 'image-new',
      url: 'https://cdn.sanity.io/images/demo/production/new.png',
    );
  }
}
