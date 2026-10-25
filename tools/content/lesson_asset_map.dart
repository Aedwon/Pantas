import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

/// Represents the identity and location of a lesson markdown file.
class LessonIdentity {
  const LessonIdentity({
    required this.path,
    required this.subject,
    required this.topic,
    required this.lesson,
  });

  /// Factory constructor to derive LessonIdentity from a relative or absolute
  /// file path.
  factory LessonIdentity.fromPath(String path) {
    final normalized = path.replaceAll(r'\', '/');
    final match = RegExp(r'content/lessons/([^/]+)/(?:([^/]+)/)?([^/]+)\.md$')
        .firstMatch(normalized);
    if (match != null) {
      return LessonIdentity(
        path: path,
        subject: match.group(1)!,
        topic: match.group(2) ?? '',
        lesson: match.group(3)!,
      );
    }
    final parts = normalized.split('/');
    final filename = parts.last.replaceAll('.md', '');
    final subject = parts.length > 2 ? parts[parts.length - 3] : '';
    final topic = parts.length > 1 ? parts[parts.length - 2] : '';
    return LessonIdentity(
      path: path,
      subject: subject,
      topic: topic,
      lesson: filename,
    );
  }

  final String path;
  final String subject;
  final String topic;
  final String lesson;

  /// Returns the asset key prefix: `subject/topic/lesson` or `subject/lesson` when topic is empty.
  String get assetKeyPrefix =>
      topic.isEmpty ? '$subject/$lesson' : '$subject/$topic/$lesson';

  /// Returns the asset key for the [seq]-th illustration: `subject/topic/lesson#seq`.
  String assetKey(int seq) => '$assetKeyPrefix#$seq';

  @override
  String toString() => 'LessonIdentity($path, $assetKeyPrefix)';
}

/// Metadata entry for a resolved lesson asset.
class LessonAssetEntry {
  const LessonAssetEntry({
    required this.url,
    required this.alt,
    this.assetId,
    this.sha256,
    this.creditKey,
    this.file,
  });

  final String url;
  final String alt;

  /// The local figure file this entry was built from, or null for an entry
  /// that came from the asset map.
  final String? file;
  final String? assetId;
  final String? sha256;
  final String? creditKey;

  Map<String, Object?> toMap() => {
        'url': url,
        'alt': alt,
        if (assetId != null) 'assetId': assetId,
        if (sha256 != null) 'sha256': sha256,
        if (creditKey != null) 'creditKey': creditKey,
      };
}

/// The path rule for a local lesson figure, relative to the illustrations
/// folder. The upload tool applies the same rule.
const figurePathRule = '<subject>/<topic>/<lesson>/NN-slug.svg or .png '
    '(lowercase letters, digits and hyphens; '
    'NN is two or more digits, 01 or more)';
final _figureExtension =
    RegExp(r'\.(svg|png|jpe?g|gif|webp)$', caseSensitive: false);
final _figurePath = RegExp(
  r'^([a-z0-9-]+)/([a-z0-9-]+)/([a-z0-9-]+)/([0-9]{2,})-[a-z0-9-]+\.(svg|png)$',
);

/// Lookup map for lesson illustration assets.
class LessonAssetMap {
  const LessonAssetMap(this._entries, {Map<String, String> credits = const {}})
      : _credits = credits,
        isConfigured = true;

  const LessonAssetMap.empty()
      : _entries = const {},
        _credits = const {},
        isConfigured = true;

  const LessonAssetMap.unconfigured()
      : _entries = const {},
        _credits = const {},
        isConfigured = false;

  const LessonAssetMap.disabled()
      : _entries = const {},
        _credits = const {},
        isConfigured = false;

  factory LessonAssetMap.fromMap(
    Map<String, Object?> map, {
    Map<String, String> credits = const {},
  }) {
    final entries = <String, LessonAssetEntry>{};
    for (final entry in map.entries) {
      final val = entry.value;
      if (val is Map) {
        entries[entry.key] = LessonAssetEntry(
          url: (val['url'] as String?) ?? '',
          alt: (val['alt'] as String?) ?? '',
          assetId: val['assetId'] as String?,
          sha256: val['sha256'] as String?,
          creditKey: val['creditKey'] as String?,
        );
      }
    }
    return LessonAssetMap(entries, credits: credits);
  }

  factory LessonAssetMap.fromJsonString(
    String jsonStr, {
    Map<String, String> credits = const {},
  }) {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    return LessonAssetMap.fromMap(decoded, credits: credits);
  }

  factory LessonAssetMap.fromJsonFile(File file) {
    final credits = <String, String>{
      ..._loadCredits(Directory('${file.parent.path}/sources')),
    };
    final prior = file.existsSync()
        ? LessonAssetMap.fromJsonString(
            file.readAsStringSync(),
            credits: credits,
          )
        : const LessonAssetMap.unconfigured();
    final entries = <String, LessonAssetEntry>{...prior._entries};
    final found = <String, File>{};
    final seen = <String>{};
    if (file.parent.existsSync()) {
      final files = file.parent
          .listSync(recursive: true, followLinks: false)
          .where((entity) => entity is File || entity is Link)
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      for (final image in files) {
        final relative = image.path
            .substring(file.parent.path.length + 1)
            .replaceAll(r'\', '/');
        if (!_figureExtension.hasMatch(relative)) continue;
        final match = _figurePath.firstMatch(relative);
        if (match == null) {
          throw FormatException(
            'Illustration file name does not match $figurePathRule: '
            '${image.path}',
          );
        }
        final sequence = int.parse(match[4]!);
        if (sequence < 1) {
          throw FormatException(
            'Illustration sequence must be 1 or more, as in $figurePathRule: '
            '${image.path}',
          );
        }
        if (image is! File) {
          throw FormatException(
            'Illustration file must not be a symbolic link: ${image.path}',
          );
        }
        final key = '${match[1]}/${match[2]}/${match[3]}#$sequence';
        final previous = found[key];
        if (!seen.add('$key/${match[5]}')) {
          throw FormatException(
            'Duplicate illustration sequence: ${image.path}',
          );
        }
        // An SVG replaces the old PNG for the same marker slot.
        if (previous == null || match[5] == 'svg') found[key] = image;
      }
    }
    for (final item in found.entries) {
      if (entries.containsKey(item.key) && !item.value.path.endsWith('.svg')) {
        continue;
      }
      final mime =
          item.value.path.endsWith('.svg') ? 'image/svg+xml' : 'image/png';
      final creditKey = prior.get(item.key)?.creditKey ?? item.key;
      credits.putIfAbsent(creditKey, () => 'Pantas');
      entries[item.key] = LessonAssetEntry(
        url: Uri.dataFromBytes(item.value.readAsBytesSync(), mimeType: mime)
            .toString(),
        alt: prior.get(item.key)?.alt ?? '',
        creditKey: creditKey,
        file: item.value.path,
      );
    }
    if (entries.isEmpty && !prior.isConfigured) {
      return const LessonAssetMap.unconfigured();
    }
    return LessonAssetMap(entries, credits: credits);
  }

  final Map<String, LessonAssetEntry> _entries;
  final Map<String, String> _credits;
  final bool isConfigured;

  bool get isUnconfigured => !isConfigured;
  bool get isDisabled => !isConfigured;

  LessonAssetEntry? get(String key) => _entries[key];

  String? creditFor(LessonAssetEntry entry) => _credits[entry.creditKey];

  static Map<String, String> _loadCredits(Directory sources) {
    if (!sources.existsSync()) return const {};
    final files = sources
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.yaml'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    final credits = <String, String>{};
    for (final file in files) {
      final doc = loadYaml(file.readAsStringSync()) as YamlMap;
      for (final source in (doc['assets'] as YamlList).cast<YamlMap>()) {
        final key = source['key'];
        final credit = source['credit'];
        if (key is String && credit is String && credit.trim().isNotEmpty) {
          credits[key] = credit;
        }
      }
    }
    return credits;
  }

  LessonAssetEntry? lookup(LessonIdentity lesson, int seq) =>
      get(lesson.assetKey(seq));

  /// Returns all entries for [lesson] sorted by sequence number ascending.
  List<MapEntry<int, LessonAssetEntry>> orderedEntriesFor(
    LessonIdentity lesson,
  ) {
    final prefix = '${lesson.assetKeyPrefix}#';
    final results = <MapEntry<int, LessonAssetEntry>>[];
    for (final entry in _entries.entries) {
      if (entry.key.startsWith(prefix)) {
        final seqStr = entry.key.substring(prefix.length);
        final seq = int.tryParse(seqStr);
        if (seq != null) {
          results.add(MapEntry(seq, entry.value));
        }
      }
    }
    results.sort((a, b) => a.key.compareTo(b.key));
    return results;
  }

  /// The local figure files for [lesson], in marker order.
  List<String> localFiguresFor(LessonIdentity lesson) => [
        for (final entry in orderedEntriesFor(lesson))
          if (entry.value.file != null) entry.value.file!,
      ];

  /// Throws when a local figure belongs to no lesson in [lessons], for example
  /// after a lesson was renamed and its figures were left behind.
  void assertNoOrphanFigures(Iterable<LessonIdentity> lessons) {
    final known = {for (final lesson in lessons) lesson.assetKeyPrefix};
    for (final entry in _entries.entries) {
      final file = entry.value.file;
      if (file == null) continue;
      final lessonKey = entry.key.substring(0, entry.key.lastIndexOf('#'));
      if (!known.contains(lessonKey)) {
        throw FormatException(
          'Figure file belongs to no lesson ($lessonKey.md): $file',
        );
      }
    }
  }

  bool contains(String key) => _entries.containsKey(key);

  int get length => _entries.length;
}
