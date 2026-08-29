import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';

void main() {
  const mapper = TrackScopeMapper();
  final updatedAt = DateTime.utc(2026, 8, 30, 2);

  test('metadata document round-trips typed custom-track payload', () {
    const row = CustomTrackMetaLocalRow(
      examId: 'exam:custom/a.b',
      name: 'Scholarship / STEM',
    );
    final rowId = mapper.metadataDocumentId(row);
    final doc = mapper.metadataToFirestore(
      row,
      updatedAt: updatedAt,
      originDeviceId: 'device-1',
    );
    final restored = mapper.fromFirestore(rowId, doc);

    expect(restored.kind, TrackScopeDocumentKind.metadata);
    expect(restored.examId, row.examId);
    expect(restored.name, row.name);
    expect(restored.topicId, isNull);
    expect(doc['kind'], 'custom_track');
  });

  test('scope document round-trips typed exclusion payload', () {
    const row = TrackScopeExclusionRow(
      examId: 'exam:custom/a.b',
      topicId: 'topic:math/a.b',
    );
    final rowId = mapper.scopeDocumentId(row);
    final doc = mapper.scopeToFirestore(
      row,
      updatedAt: updatedAt,
      originDeviceId: 'device-1',
    );
    final restored = mapper.fromFirestore(rowId, doc);

    expect(restored.kind, TrackScopeDocumentKind.scope);
    expect(restored.examId, row.examId);
    expect(restored.topicId, row.topicId);
    expect(restored.name, isNull);
    expect(doc['kind'], 'scope');
  });

  test('document IDs remain collision-safe for punctuation-heavy identifiers',
      () {
    final first = TrackScopeDocumentId.scope('a:b', 'c/d.e');
    final second = TrackScopeDocumentId.scope('a', 'b:c/d.e');

    expect(first, isNot(second));
    expect(TrackScopeDocumentId.parse(first).examId, 'a:b');
    expect(TrackScopeDocumentId.parse(first).topicId, 'c/d.e');
    expect(TrackScopeDocumentId.parse(second).examId, 'a');
    expect(TrackScopeDocumentId.parse(second).topicId, 'b:c/d.e');
  });

  test('payload identity must match encoded document identity', () {
    final rowId = TrackScopeDocumentId.metadata('exam-a');
    final doc = <String, Object?>{
      'kind': 'custom_track',
      'examId': 'exam-b',
      'name': 'Wrong',
      'schemaVersion': 1,
    };

    expect(() => mapper.fromFirestore(rowId, doc), throwsFormatException);
  });
}
