import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/attempt_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attempt mapper includes row fields and sync metadata', () {
    final row = AttemptLocalRow(
      id: 'attempt_1',
      examId: 'cse',
      startedAt: DateTime.utc(2026, 5, 18, 1),
      completedAt: DateTime.utc(2026, 5, 18, 1, 5),
      origin: 'drill',
      itemsJson: '[{"questionId":"q1"}]',
      syncState: 'pending',
      syncAttempts: 2,
      lastSyncError: 'timeout',
    );
    final updatedAt = DateTime.utc(2026, 5, 18, 2);

    final doc = const AttemptMapper().toFirestore(
      row,
      updatedAt: updatedAt,
      originDeviceId: 'device-1',
    );

    expect(doc, {
      'id': 'attempt_1',
      'examId': 'cse',
      'startedAt': '2026-05-18T01:00:00.000Z',
      'completedAt': '2026-05-18T01:05:00.000Z',
      'origin': 'drill',
      'itemsJson': '[{"questionId":"q1"}]',
      'updatedAt': '2026-05-18T02:00:00.000Z',
      'originDeviceId': 'device-1',
      'schemaVersion': 1,
    });
  });

  test('attempt mapper round trips nullable completedAt', () {
    final row = AttemptLocalRow(
      id: 'attempt_2',
      examId: 'upcat',
      startedAt: DateTime.utc(2026, 5, 18, 1),
      origin: 'today_topic',
      itemsJson: '[]',
      syncState: 'pending',
      syncAttempts: 0,
    );

    final doc = const AttemptMapper().toFirestore(
      row,
      updatedAt: DateTime.utc(2026, 5, 18, 2),
      originDeviceId: 'device-1',
    );
    final mapped = const AttemptMapper().fromFirestore(doc);

    expect(mapped.completedAt, isNull);
    expect(mapped.id, 'attempt_2');
    expect(mapped.itemsJson, '[]');
    expect(mapped.origin, 'today_topic');
  });

  test('attempt mapper preserves backward-compatible default origin', () {
    final mapped = const AttemptMapper().fromFirestore({
      'id': 'attempt_3',
      'examId': 'cse',
      'startedAt': '2026-05-18T01:00:00.000Z',
      'completedAt': null,
      'itemsJson': '[]',
    });

    expect(mapped.origin, 'today_topic');
  });
}
