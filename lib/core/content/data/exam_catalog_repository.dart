import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pantas/core/content/content_database.dart';

class PublishedExamSitting {
  const PublishedExamSitting({
    required this.firstDay,
    required this.lastDay,
    required this.sourceUrl,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final String sourceUrl;
}

class ExamCatalogEntry {
  const ExamCatalogEntry({
    required this.id,
    required this.name,
    required this.shortName,
    required this.priceTier,
    required this.group,
    required this.comingSoon,
    required this.publishedSittings,
    required this.hasContent,
  });

  final String id;
  final String name;
  final String shortName;
  final String priceTier;
  final String group;
  final bool comingSoon;
  final List<PublishedExamSitting> publishedSittings;
  final bool hasContent;

  bool get isSelectable => !comingSoon && hasContent;

  ExamCatalogEntry _withContent(bool value) => ExamCatalogEntry(
        id: id,
        name: name,
        shortName: shortName,
        priceTier: priceTier,
        group: group,
        comingSoon: comingSoon,
        publishedSittings: publishedSittings,
        hasContent: value,
      );
}

class ExamCatalogRepository {
  ExamCatalogRepository(this._db, {AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  final ContentDatabase _db;
  final AssetBundle _assetBundle;
  late final Future<List<ExamCatalogEntry>> _catalog = _load();

  Future<ExamCatalogEntry> entry(String examId) async {
    final catalog = await _catalog;
    final item = catalog.firstWhere((entry) => entry.id == examId);
    final row = await (_db.select(_db.contentExams)
          ..where((table) => table.id.equals(examId)))
        .getSingleOrNull();
    return item._withContent(row != null);
  }

  Stream<List<ExamCatalogEntry>> watchAll() =>
      _db.select(_db.contentExams).watch().asyncMap((rows) async {
        final ids = rows.map((row) => row.id).toSet();
        return [
          for (final item in await _catalog)
            item._withContent(ids.contains(item.id)),
        ];
      });

  Future<List<ExamCatalogEntry>> _load() async {
    final json = await _assetBundle.loadString('content/exams/catalog.json');
    final entries =
        (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>();
    return List.unmodifiable([
      for (final entry in entries)
        ExamCatalogEntry(
          id: entry['id'] as String,
          name: entry['name'] as String,
          shortName: entry['shortName'] as String,
          priceTier: entry['priceTier'] as String,
          group: entry['group'] as String,
          comingSoon: entry['comingSoon'] as bool,
          publishedSittings:
              _sittings(entry['publishedSittings'] as List<dynamic>),
          hasContent: false,
        ),
    ]);
  }

  List<PublishedExamSitting> _sittings(List<dynamic> values) {
    final result = [
      for (final json in values.cast<Map<String, dynamic>>())
        PublishedExamSitting(
          firstDay: DateTime.parse('${json['firstDay']}T00:00:00Z'),
          lastDay: DateTime.parse('${json['lastDay']}T00:00:00Z'),
          sourceUrl: json['sourceUrl'] as String,
        ),
    ]..sort((a, b) => a.firstDay.compareTo(b.firstDay));
    return List.unmodifiable(result);
  }
}
