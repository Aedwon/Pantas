import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/mapping/question_flag_mapper.dart';

void main() {
  const mapper = QuestionFlagMapper();

  test('a flag row becomes a firestore document', () {
    final doc = mapper.toFirestore(
      QuestionFlagLocalRow(
        questionId: 'q1',
        flaggedAt: DateTime.utc(2026, 8, 2, 9, 30),
        sortIndex: 3,
        syncState: 'pending',
      ),
      updatedAt: DateTime.utc(2026, 8, 2, 10),
      originDeviceId: 'device-1',
    );

    expect(doc, {
      'questionId': 'q1',
      'flaggedAt': '2026-08-02T09:30:00.000Z',
      'sortIndex': 3,
      'updatedAt': '2026-08-02T10:00:00.000Z',
      'originDeviceId': 'device-1',
      'schemaVersion': 1,
    });
  });

  test('a firestore document becomes a synced flag row', () {
    final row = mapper.fromFirestore({
      'questionId': 'q1',
      'flaggedAt': '2026-08-02T09:30:00.000Z',
      'sortIndex': null,
    });

    expect(row.questionId, 'q1');
    expect(row.flaggedAt, DateTime.utc(2026, 8, 2, 9, 30));
    expect(row.sortIndex, isNull);
    expect(row.syncState, 'synced');
  });

  test('the document id is the question id', () {
    expect(
      mapper.documentId(
        QuestionFlagLocalRow(
          questionId: 'q7',
          flaggedAt: DateTime.utc(2026, 8, 2),
          syncState: 'pending',
        ),
      ),
      'q7',
    );
  });

  test('question flags are an active sync collection', () {
    final entry = activeSyncCollections
        .firstWhere((entry) => entry.tableType == 'question_flags');

    expect(entry.firestorePath, 'question_flags');
    expect(entry.mapper, isA<QuestionFlagMapper>());
  });
}
