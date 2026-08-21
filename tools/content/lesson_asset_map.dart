import 'dart:convert';
import 'dart:io';

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
  });

  final String url;
  final String alt;
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

/// Lookup map for lesson illustration assets.
class LessonAssetMap {
  const LessonAssetMap(this._entries) : isConfigured = true;

  const LessonAssetMap.empty()
      : _entries = const {},
        isConfigured = true;

  const LessonAssetMap.unconfigured()
      : _entries = const {},
        isConfigured = false;

  const LessonAssetMap.disabled()
      : _entries = const {},
        isConfigured = false;

  factory LessonAssetMap.fromMap(Map<String, Object?> map) {
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
    return LessonAssetMap(entries);
  }

  factory LessonAssetMap.fromJsonString(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    return LessonAssetMap.fromMap(decoded);
  }

  factory LessonAssetMap.fromJsonFile(File file) {
    if (!file.existsSync()) return const LessonAssetMap.unconfigured();
    return LessonAssetMap.fromJsonString(file.readAsStringSync());
  }

  final Map<String, LessonAssetEntry> _entries;
  final bool isConfigured;

  bool get isUnconfigured => !isConfigured;
  bool get isDisabled => !isConfigured;

  LessonAssetEntry? get(String key) => _entries[key];

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

  bool contains(String key) => _entries.containsKey(key);

  int get length => _entries.length;
}
