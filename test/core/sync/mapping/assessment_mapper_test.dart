import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/assessment_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assessment mapper uses examId as stable document id', () {
    final row = AssessmentResultLocalRow(
      examId: 'cse',
      completedAt: DateTime.utc(2026, 5, 18, 1),
      topicScoresJson: '{"vocab":0.8}',
      syncState: 'pending',
    );

    expect(const AssessmentMapper().documentId(row), 'cse');
  });

  test('assessment mapper preserves topicScoresJson', () {
    final row = AssessmentResultLocalRow(
      examId: 'cse',
      completedAt: DateTime.utc(2026, 5, 18, 1),
      topicScoresJson: '{"vocab":0.8}',
      syncState: 'failed',
    );
    final updatedAt = DateTime.utc(2026, 5, 18, 2);

    final doc = const AssessmentMapper().toFirestore(
      row,
      updatedAt: updatedAt,
      originDeviceId: 'device-1',
    );

    expect(doc, {
      'examId': 'cse',
      'completedAt': '2026-05-18T01:00:00.000Z',
      'topicScoresJson': '{"vocab":0.8}',
      'updatedAt': '2026-05-18T02:00:00.000Z',
      'originDeviceId': 'device-1',
      'schemaVersion': 1,
    });
    expect(const AssessmentMapper().fromFirestore(doc).topicScoresJson,
        '{"vocab":0.8}');
  });
}
