import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/sync/mapping/attempt_mapper.dart';
import 'package:pantas/core/sync/mapping/mock_attempt_mapper.dart';

void main() {
  test('sync preserves quiz mistake tags and notes', () {
    final row = AttemptLocalRow(
      id: 'attempt1',
      examId: 'upcat',
      startedAt: DateTime.utc(2026, 10, 6),
      origin: 'drill',
      itemsJson: jsonEncode([
        {
          'questionId': 'q1',
          'questionVersion': 1,
          'chosenChoiceId': 'c2',
          'correctChoiceId': 'c1',
          'responseMs': 1200,
          'mistakeTag': 'other',
          'mistakeNote': 'Wrong formula',
        },
      ]),
      syncState: 'pending',
      syncAttempts: 0,
    );
    const mapper = AttemptMapper();
    final restored = mapper.fromFirestore(
      mapper.toFirestore(
        row,
        updatedAt: DateTime.utc(2026, 10, 6),
        originDeviceId: 'device1',
      ),
    );
    expect(restored.itemsJson, row.itemsJson);
    final items = jsonDecode(restored.itemsJson) as List<dynamic>;
    final item = AttemptItem.fromJson(items.single as Map<String, dynamic>);
    expect(item.toJson()['mistakeTag'], 'other');
    expect(item.toJson()['mistakeNote'], 'Wrong formula');
  });

  test('sync preserves mock reasons and section wrong and blank counts', () {
    final now = DateTime.utc(2026, 10, 6);
    final row = MockAttemptLocalRow(
      id: 'mock1',
      userId: 'user1',
      examId: 'upcat',
      blueprintId: 'bp1',
      blueprintName: 'UPCAT',
      durationMinutes: 60,
      status: 'completed',
      strictMode: true,
      sampledQuestionsJson: '[]',
      elapsedSeconds: 60,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{"q1":{"idx":1,"atSec":12,"missReason":"other", '
          '"blankReason":null,"reasonNote":"Wrong formula"}, '
          '"q2":{"idx":-1,"atSec":20,"missReason":null, '
          '"blankReason":"ranOutOfTime","reasonNote":null}}',
      flagsJson: '[]',
      currentIndex: 0,
      sectionResultsJson:
          '[{"sectionId":"s1","correct":3,"wrong":1,"blank":1}]',
      startedAt: now,
      lastFlushedAt: now,
      updatedAt: now,
    );
    const mapper = MockAttemptMapper();
    final restored = mapper.fromFirestore(
      mapper.toFirestore(row, updatedAt: now, originDeviceId: 'device1'),
    );
    expect(restored.answersJson, row.answersJson);
    expect(restored.sectionResultsJson, row.sectionResultsJson);
  });
}
