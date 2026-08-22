import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const _apiVersion = 'v2024-06-24';
const _requiredEnvironment = <String>[
  'SANITY_PROJECT_ID',
  'SANITY_DATASET',
  'SANITY_WRITE_TOKEN',
];

/// One normalized open-source image and its provenance.
class OpenAssetRecord {
  const OpenAssetRecord({
    required this.creator,
    required this.credit,
    required this.directUrl,
    required this.key,
    required this.license,
    required this.sha256,
    required this.sourcePage,
    required this.target,
  });

  final String creator;
  final String credit;
  final Uri directUrl;
  final String key;
  final String license;
  final String sha256;
  final Uri sourcePage;
  final String target;
}

/// The frozen strategy fields needed in the committed asset map.
class StrategyAsset {
  const StrategyAsset({
    required this.alt,
    required this.key,
    required this.target,
  });

  final String alt;
  final String key;
  final String target;
}

/// The stable result returned by the external upload port.
class UploadedAsset {
  const UploadedAsset({required this.assetId, required this.url});

  final String assetId;
  final String url;
}

/// External port for a Sanity image upload.
// The approved plan names this port so tests never touch the network.
// ignore: one_member_abstracts
abstract interface class AssetUploader {
  Future<UploadedAsset> upload(OpenAssetRecord record, File file);
}

/// Summary printed by dry-run and live modes.
class AssetUploadResult {
  const AssetUploadResult({
    required this.missing,
    required this.ready,
    required this.replaced,
    required this.unchanged,
    required this.writes,
  });

  final int missing;
  final int ready;
  final int replaced;
  final int unchanged;
  final int writes;
}

class AssetManifestException implements Exception {
  const AssetManifestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AssetUploadException implements Exception {
  const AssetUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Content Lake Assets API adapter.
class SanityAssetUploader implements AssetUploader {
  SanityAssetUploader._({
    required this.dataset,
    required this.projectId,
    required this.token,
    HttpClient? client,
  }) : _client = client ?? HttpClient();

  factory SanityAssetUploader.fromEnvironment(
    Map<String, String> environment, {
    HttpClient? client,
  }) {
    final missing = <String>[];
    for (final name in _requiredEnvironment) {
      if ((environment[name] ?? '').trim().isEmpty) missing.add(name);
    }
    if (missing.isNotEmpty) {
      throw AssetUploadException(
        'Missing required environment variables: ${missing.join(', ')}.',
      );
    }

    final projectId = environment['SANITY_PROJECT_ID']!.trim();
    final dataset = environment['SANITY_DATASET']!.trim();
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(projectId)) {
      throw const AssetUploadException('SANITY_PROJECT_ID is invalid.');
    }
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(dataset)) {
      throw const AssetUploadException('SANITY_DATASET is invalid.');
    }

    return SanityAssetUploader._(
      client: client,
      dataset: dataset,
      projectId: projectId,
      token: environment['SANITY_WRITE_TOKEN']!,
    );
  }

  final String dataset;
  final String projectId;
  final String token;
  final HttpClient _client;

  @override
  Future<UploadedAsset> upload(OpenAssetRecord record, File file) async {
    final uri = Uri.https(
      '$projectId.api.sanity.io',
      '/$_apiVersion/assets/images/$dataset',
      <String, String>{
        'creditLine': record.credit,
        'filename': p.basename(file.path),
        'sourceName': record.creator,
        'sourceUrl': record.sourcePage.toString(),
      },
    );

    try {
      final request = await _client.postUrl(uri);
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token')
        ..contentType = ContentType('image', 'png');
      request.contentLength = await file.length();
      await request.addStream(file.openRead());
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AssetUploadException(
          'Sanity upload failed for ${record.key} '
          '(HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw AssetUploadException(
          'Sanity returned an invalid response for ${record.key}.',
        );
      }
      final responseMap = decoded.cast<String, Object?>();
      final documentValue = responseMap['document'];
      final document = documentValue is Map
          ? documentValue.cast<String, Object?>()
          : responseMap;
      final assetId = document['_id'] ?? document['assetId'];
      final url = document['url'];
      if (assetId is! String || assetId.isEmpty || url is! String) {
        throw AssetUploadException(
          'Sanity returned an incomplete response for ${record.key}.',
        );
      }
      final parsedUrl = Uri.tryParse(url);
      if (parsedUrl == null || parsedUrl.scheme != 'https') {
        throw AssetUploadException(
          'Sanity returned an invalid URL for ${record.key}.',
        );
      }
      return UploadedAsset(assetId: assetId, url: url);
    } on AssetUploadException {
      rethrow;
    } on Object {
      throw AssetUploadException('Sanity upload failed for ${record.key}.');
    }
  }
}

/// Validates all local files first, then uploads changed digests. The map is
/// replaced only after every requested upload succeeds.
Future<AssetUploadResult> synchronizeAssets({
  required File assetMapFile,
  required bool dryRun,
  required List<OpenAssetRecord> records,
  required Directory repositoryRoot,
  required Map<String, StrategyAsset> strategy,
  required AssetUploader uploader,
}) async {
  final seenKeys = <String>{};
  final seenTargets = <String>{};
  final files = <String, File>{};
  var missing = 0;

  for (final record in records) {
    _validateRecord(record);
    if (!seenKeys.add(record.key)) {
      throw AssetManifestException('Duplicate asset key: ${record.key}.');
    }
    if (!seenTargets.add(record.target)) {
      throw AssetManifestException(
        'Duplicate asset target: ${record.target}.',
      );
    }
    final planned = strategy[record.key];
    if (planned == null || planned.target != record.target) {
      throw AssetManifestException(
        'Manifest target does not match strategy for ${record.key}.',
      );
    }

    final file = File(p.join(repositoryRoot.path, record.target));
    if (!file.existsSync()) {
      missing++;
      continue;
    }
    final actualDigest = sha256.convert(await file.readAsBytes()).toString();
    if (actualDigest != record.sha256) {
      throw AssetManifestException(
        'SHA-256 mismatch for ${record.key}: expected ${record.sha256}, '
        'got $actualDigest.',
      );
    }
    files[record.key] = file;
  }

  missing += strategy.keys.where((key) => !seenKeys.contains(key)).length;

  final ready = strategy.length - missing;
  if (dryRun) {
    return AssetUploadResult(
      missing: missing,
      ready: ready,
      replaced: 0,
      unchanged: 0,
      writes: 0,
    );
  }
  if (missing != 0) {
    throw AssetUploadException(
      '$missing asset ${missing == 1 ? 'file is' : 'files are'} missing.',
    );
  }

  final existing = await _readAssetMap(assetMapFile);
  final next = <String, Map<String, Object?>>{
    for (final entry in existing.entries) entry.key: {...entry.value},
  };
  var replaced = 0;
  var unchanged = 0;
  var writes = 0;
  var mapChanged = false;

  for (final record in records) {
    final planned = strategy[record.key]!;
    final prior = existing[record.key];
    final priorAssetId = prior?['assetId'];
    final priorUrl = prior?['url'];
    if (prior?['sha256'] == record.sha256 &&
        priorAssetId is String &&
        priorUrl is String) {
      unchanged++;
      final refreshed = _assetMapEntry(
        assetId: priorAssetId,
        record: record,
        strategy: planned,
        url: priorUrl,
      );
      if (jsonEncode(prior) != jsonEncode(refreshed)) mapChanged = true;
      next[record.key] = refreshed;
      continue;
    }

    final uploaded = await uploader.upload(record, files[record.key]!);
    if (prior != null) replaced++;
    writes++;
    mapChanged = true;
    next[record.key] = _assetMapEntry(
      assetId: uploaded.assetId,
      record: record,
      strategy: planned,
      url: uploaded.url,
    );
  }

  if (mapChanged || !assetMapFile.existsSync()) {
    await _writeAssetMapAtomically(assetMapFile, next);
  }
  return AssetUploadResult(
    missing: missing,
    ready: ready,
    replaced: replaced,
    unchanged: unchanged,
    writes: writes,
  );
}

Map<String, Object?> _assetMapEntry({
  required String assetId,
  required OpenAssetRecord record,
  required StrategyAsset strategy,
  required String url,
}) =>
    <String, Object?>{
      'assetId': assetId,
      'url': url,
      'sha256': record.sha256,
      'alt': strategy.alt,
      'creditKey': record.key,
    };

void _validateRecord(OpenAssetRecord record) {
  if (!RegExp(r'^[a-z0-9-]+/[a-z0-9-]+/[a-z0-9-]+#[1-9][0-9]*$')
      .hasMatch(record.key)) {
    throw AssetManifestException('Invalid asset key: ${record.key}.');
  }
  if (!record.target.startsWith('content/illustrations/') ||
      !record.target.endsWith('.png') ||
      p.isAbsolute(record.target) ||
      p.split(record.target).contains('..')) {
    throw AssetManifestException('Invalid target for ${record.key}.');
  }
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(record.sha256)) {
    throw AssetManifestException('Invalid SHA-256 for ${record.key}.');
  }
  if (record.creator.trim().isEmpty || record.credit.trim().isEmpty) {
    throw AssetManifestException('Missing credit fields for ${record.key}.');
  }
  if (record.sourcePage.scheme != 'https' ||
      record.directUrl.scheme != 'https') {
    throw AssetManifestException(
      'Source URLs must use HTTPS for ${record.key}.',
    );
  }
  if (!_isApprovedSourcePage(record.sourcePage)) {
    throw AssetManifestException(
      'Unapproved source family for ${record.key}: '
      '${record.sourcePage.host}.',
    );
  }
  if (!_isApprovedSourcePage(record.directUrl)) {
    throw AssetManifestException(
      'Unapproved direct download host for ${record.key}: '
      '${record.directUrl.host}.',
    );
  }
  if (!_licenseAllowsCommercialModification(record.license)) {
    throw AssetManifestException(
      'Rejected license for ${record.key}: ${record.license}.',
    );
  }
}

bool _isApprovedSourcePage(Uri uri) {
  final host = uri.host.toLowerCase();
  const roots = <String>[
    'openstax.org',
    'rice.edu',
    'usgs.gov',
    'nasa.gov',
    'noaa.gov',
    'wikimedia.org',
  ];
  return roots.any((root) => host == root || host.endsWith('.$root'));
}

bool _licenseAllowsCommercialModification(String raw) {
  final license = raw.toLowerCase().replaceAll('_', ' ').trim();
  if (license.isEmpty ||
      license.contains('noncommercial') ||
      license.contains('no derivatives') ||
      RegExp(r'(^|[- ])nc([ -]|$)').hasMatch(license) ||
      RegExp(r'(^|[- ])nd([ -]|$)').hasMatch(license) ||
      license.contains('all rights reserved')) {
    return false;
  }
  return license.contains('public domain') ||
      license.startsWith('cc0') ||
      license.startsWith('cc by') ||
      license.startsWith('cc-by') ||
      license.contains('creative commons attribution') ||
      license.startsWith('gfdl');
}

Future<Map<String, Map<String, Object?>>> _readAssetMap(File file) async {
  if (!file.existsSync()) return <String, Map<String, Object?>>{};
  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! Map) {
    throw const AssetManifestException('assets.json must contain an object.');
  }
  final result = <String, Map<String, Object?>>{};
  for (final entry in decoded.entries) {
    if (entry.key is! String || entry.value is! Map) {
      throw const AssetManifestException('assets.json is malformed.');
    }
    result[entry.key as String] = (entry.value as Map).cast<String, Object?>();
  }
  return result;
}

Future<void> _writeAssetMapAtomically(
  File destination,
  Map<String, Map<String, Object?>> contents,
) async {
  await destination.parent.create(recursive: true);
  final orderedKeys = contents.keys.toList()..sort();
  final ordered = <String, Map<String, Object?>>{
    for (final key in orderedKeys) key: contents[key]!,
  };
  final temporary = File(
    '${destination.path}.tmp-$pid-${DateTime.now().microsecondsSinceEpoch}',
  );
  try {
    await temporary.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(ordered)}\n',
      flush: true,
    );
    await temporary.rename(destination.path);
  } finally {
    if (temporary.existsSync()) await temporary.delete();
  }
}

/// Loads the exact manifest shape produced by the two open-asset workers.
List<OpenAssetRecord> loadOpenAssetManifests(List<File> files) {
  final records = <OpenAssetRecord>[];
  for (final file in files) {
    if (!file.existsSync()) {
      throw AssetManifestException('Manifest not found: ${file.path}.');
    }
    final root = loadYaml(file.readAsStringSync());
    if (root is! YamlMap || root['version'] != 1) {
      throw AssetManifestException('Invalid manifest version: ${file.path}.');
    }
    final rawAssets = root['assets'];
    if (rawAssets is! YamlList) {
      throw AssetManifestException('Missing assets list: ${file.path}.');
    }
    for (final raw in rawAssets) {
      if (raw is! YamlMap) {
        throw AssetManifestException('Invalid asset record: ${file.path}.');
      }
      final key = _yamlString(raw, 'key');
      final sourcePage = Uri.tryParse(_yamlString(raw, 'sourcePage'));
      final directUrl = Uri.tryParse(_yamlString(raw, 'directUrl'));
      if (sourcePage == null || directUrl == null) {
        throw AssetManifestException('Invalid URL for $key.');
      }
      records.add(
        OpenAssetRecord(
          creator: _yamlString(raw, 'creator'),
          credit: _yamlString(raw, 'credit'),
          directUrl: directUrl,
          key: key,
          license: _yamlString(raw, 'license'),
          sha256: _yamlString(raw, 'sha256'),
          sourcePage: sourcePage,
          target: _yamlString(raw, 'target'),
        ),
      );
    }
  }
  return records;
}

String _yamlString(YamlMap map, String field) {
  final value = map[field];
  if (value is! String || value.trim().isEmpty) {
    throw AssetManifestException('Missing manifest field: $field.');
  }
  return value;
}

Map<String, StrategyAsset> loadOpenStrategy(File file) {
  if (!file.existsSync()) {
    throw AssetManifestException('Strategy not found: ${file.path}.');
  }
  final lines = file.readAsLinesSync();
  if (lines.isEmpty) {
    throw const AssetManifestException('Strategy file is empty.');
  }
  final header = lines.first.split('\t');
  final columns = <String, int>{
    for (var index = 0; index < header.length; index++) header[index]: index,
  };
  for (final name in <String>[
    'subject',
    'topic',
    'lesson',
    'seq',
    'target_file',
    'description',
    'strategy',
  ]) {
    if (!columns.containsKey(name)) {
      throw AssetManifestException('Strategy column is missing: $name.');
    }
  }

  final result = <String, StrategyAsset>{};
  for (final line in lines.skip(1)) {
    if (line.trim().isEmpty) continue;
    final fields = line.split('\t');
    String field(String name) {
      final index = columns[name]!;
      if (index >= fields.length) {
        throw AssetManifestException('Malformed strategy row: $line.');
      }
      return fields[index];
    }

    if (field('strategy') != 'open') continue;
    final key = '${field('subject')}/${field('topic')}/${field('lesson')}'
        '#${field('seq')}';
    if (result.containsKey(key)) {
      throw AssetManifestException('Duplicate strategy key: $key.');
    }
    result[key] = StrategyAsset(
      alt: field('description'),
      key: key,
      target: field('target_file'),
    );
  }
  return result;
}

class _DryRunUploader implements AssetUploader {
  const _DryRunUploader();

  @override
  Future<UploadedAsset> upload(OpenAssetRecord record, File file) {
    throw StateError('Dry-run must never call the uploader.');
  }
}

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final strategyIndex = args.indexOf('--strategy');
  if (strategyIndex == -1 ||
      strategyIndex + 1 >= args.length ||
      args[strategyIndex + 1] != 'open') {
    stderr.writeln(
      'Usage: dart run tools/lesson_illustrations/upload_assets.dart '
      '[--dry-run] --strategy open',
    );
    exitCode = 64;
    return;
  }

  final root = Directory.current;
  final illustrationRoot = Directory(
    p.join(root.path, 'content', 'illustrations'),
  );
  try {
    final records = loadOpenAssetManifests(<File>[
      File(p.join(illustrationRoot.path, 'sources', 'open-a.yaml')),
      File(p.join(illustrationRoot.path, 'sources', 'open-b.yaml')),
    ]);
    final strategy = loadOpenStrategy(
      File(
        p.join(
          root.path,
          'docs',
          'content',
          'illustrations',
          'strategy.tsv',
        ),
      ),
    );
    final uploader = dryRun
        ? const _DryRunUploader()
        : SanityAssetUploader.fromEnvironment(Platform.environment);
    final result = await synchronizeAssets(
      assetMapFile: File(p.join(illustrationRoot.path, 'assets.json')),
      dryRun: dryRun,
      records: records,
      repositoryRoot: root,
      strategy: strategy,
      uploader: uploader,
    );
    stdout.writeln(
      '${result.ready} ready, ${result.missing} missing, '
      '${result.writes} writes, ${result.unchanged} unchanged, '
      '${result.replaced} replaced',
    );
    if (result.missing != 0) exitCode = 1;
  } on AssetManifestException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on AssetUploadException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}
