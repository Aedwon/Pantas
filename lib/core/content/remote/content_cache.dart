import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/remote/content_item.dart';
import 'package:pantas/core/storage/data/app_database.dart';

/// Server content kept in the study database.
class ContentCache {
  ContentCache(this._db, {int Function()? nowMs})
      : _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final AppDatabase _db;
  final int Function() _nowMs;

  Future<ContentItem?> get(ContentKind kind, String id) async {
    final row = await (_db.select(_db.cachedContent)
          ..where((t) => t.kind.equals(kind.wire) & t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toItem(row);
  }

  Future<Map<String, String>> versions(
    ContentKind kind,
    Iterable<String> ids,
  ) async {
    final rows = await (_db.select(_db.cachedContent)
          ..where((t) => t.kind.equals(kind.wire) & t.id.isIn(ids.toList())))
        .get();
    return {for (final row in rows) row.id: row.version};
  }

  /// Every stored item, for filling the in-memory content database at start.
  Future<List<ContentItem>> all() async {
    final rows = await _db.select(_db.cachedContent).get();
    return [for (final row in rows) _toItem(row)];
  }

  Future<void> put(ContentItem item) {
    return _db.into(_db.cachedContent).insertOnConflictUpdate(
          CachedContentCompanion.insert(
            kind: item.kind.wire,
            id: item.id,
            version: item.version,
            tier: item.tier,
            dataJson: jsonEncode(item.data),
            fetchedAt: _nowMs(),
          ),
        );
  }

  /// Removes Pro-only fields and relabels every Pro copy as a Free copy.
  /// Returns the items that changed. The result equals what the server sends a
  /// Free account, so the next request answers "unchanged".
  Future<List<ContentItem>> downgradeToFree() async {
    final rows = await (_db.select(_db.cachedContent)
          ..where((t) => t.tier.equals('pro')))
        .get();
    final changed = <ContentItem>[];
    for (final row in rows) {
      final item = _toItem(row);
      final version = item.version.endsWith('.p')
          ? '${item.version.substring(0, item.version.length - 2)}.f'
          : item.version;
      final free = ContentItem(
        kind: item.kind,
        id: item.id,
        version: version,
        tier: 'free',
        data: item.kind == ContentKind.questions
            ? _withoutNotes(item.data)
            : item.data,
      );
      await put(free);
      changed.add(free);
    }
    return changed;
  }

  ContentItem _toItem(CachedContentRow row) => ContentItem(
        kind: ContentKind.values.firstWhere((k) => k.wire == row.kind),
        id: row.id,
        version: row.version,
        tier: row.tier,
        data: (jsonDecode(row.dataJson) as Map).cast<String, Object?>(),
      );

  Map<String, Object?> _withoutNotes(Map<String, Object?> data) {
    final questions = data['questions'];
    if (questions is! List) return data;
    return {
      ...data,
      'questions': [
        for (final raw in questions)
          if (raw is Map && raw['choices'] is List)
            {
              ...raw.cast<String, Object?>(),
              'choices': [
                for (final choice in raw['choices'] as List)
                  if (choice is Map)
                    {
                      for (final entry in choice.entries)
                        if (entry.key != 'rationale')
                          entry.key as String: entry.value,
                    }
                  else
                    choice,
              ],
            }
          else
            raw,
      ],
    };
  }
}
