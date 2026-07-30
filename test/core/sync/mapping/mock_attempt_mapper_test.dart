import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/mock_attempt_mapper.dart';

void main() {
  test(
    'mock attempt mapper preserves terminal attempt fields and json snapshots',
    () {
      const mapper = MockAttemptMapper();
      final startedAt = DateTime.utc(2026, 5, 19, 1);
      final submittedAt = DateTime.utc(2026, 5, 19, 2);
      final row = MockAttemptLocalRow(
        id: 'mock_1',
        userId: 'user_1',
        examId: 'exam_cse',
        blueprintId: 'bp_cse',
        blueprintName: 'CSE Practice',
        durationMinutes: 90,
        status: 'completed',
        strictMode: true,
        sampledQuestionsJson: '[{"sectionId":"s1","questionIds":["q1"]}]',
        elapsedSeconds: 3600,
        accumulatedPausedSeconds: 60,
        pausedAtLastFlush: false,
        answersJson: '{"q1":{"idx":0,"atSec":12}}',
        flagsJson: '["q1"]',
        currentIndex: 0,
        scoreRaw: 1,
        scoreTotal: 1,
        sectionResultsJson: '[{"sectionId":"s1","correct":1}]',
        totalTimeSeconds: 3600,
        startedAt: startedAt,
        lastFlushedAt: submittedAt,
        submittedAt: submittedAt,
        updatedAt: submittedAt,
      );

      final doc = mapper.toFirestore(
        row,
        updatedAt: submittedAt,
        originDeviceId: 'device_1',
      );

      expect(doc['id'], 'mock_1');
      expect(doc['examId'], 'exam_cse');
      expect(doc['status'], 'completed');
      expect(doc['strictMode'], isTrue);
      expect(doc['sampledQuestionsJson'], contains('q1'));
      expect(doc['answersJson'], contains('atSec'));
      expect(doc['scoreRaw'], 1);
      expect(doc['originDeviceId'], 'device_1');
      expect(doc['schemaVersion'], MockAttemptMapper.schemaVersion);
    },
  );
}
