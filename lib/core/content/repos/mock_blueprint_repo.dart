import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/domain/mock_blueprint.dart';
import 'package:drift/drift.dart';

class MockBlueprintRepo {
  MockBlueprintRepo(this._db);

  final ContentDatabase _db;
  ContentDatabase get database => _db;

  Future<List<MockBlueprint>> byExam(String examId) async {
    final rows = await (_db.select(_db.contentMockBlueprints)
          ..where(
            (row) => row.examId.equals(examId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
    return [
      for (final row in rows)
        MockBlueprint(
          id: row.id,
          examId: row.examId,
          name: row.name,
          durationMinutes: row.durationMinutes,
          sectionsJson: row.sectionsJson,
          sectionalTiming: _timingFrom(row.sectionalTiming),
          scoreBands: _bandsFrom(row.scoreBandsJson),
          totalPublishedItems: row.totalPublishedItems,
          source: _sourceFrom(row.source),
          sourceNote: row.sourceNote,
        ),
    ];
  }
}

SectionalTiming? _timingFrom(String? stored) {
  if (stored == null) return null;
  for (final value in SectionalTiming.values) {
    if (value.name == stored) return value;
  }
  return null;
}

BlueprintSource? _sourceFrom(String? stored) {
  if (stored == null) return null;
  for (final value in BlueprintSource.values) {
    if (value.name == stored) return value;
  }
  return null;
}

ScoreBands? _bandsFrom(String? stored) {
  if (stored == null) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(stored);
  } on FormatException {
    return null;
  }
  if (decoded is! Map) return null;
  final pass = decoded['passAtPercent'];
  final close = decoded['closeAtPercent'];
  if (pass is! int || close is! int) return null;
  return ScoreBands(passAtPercent: pass, closeAtPercent: close);
}
