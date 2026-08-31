import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/review_log_mapper.dart';

void main() {
  test('review log mapper round-trips append-only identity and payload', () {
    const mapper = ReviewLogMapper();
    final reviewAt = DateTime.utc(2026, 8, 30, 1);
    final row = ReviewLogRow(
      id: 'review:1/a',
      questionId: 'question:1/a',
      rating: 3,
      state: 2,
      due: reviewAt.add(const Duration(days: 3)),
      stability: 2.5,
      difficulty: 4.5,
      elapsedDays: 1,
      lastElapsedDays: 1,
      scheduledDays: 3,
      review: reviewAt,
      durationMs: 900,
      isCorrect: true,
      heuristicVersion: 2,
    );

    final doc = mapper.toFirestore(
      row,
      updatedAt: DateTime.utc(2026, 8, 30, 2),
      originDeviceId: 'device-1',
    );
    final restored = mapper.fromFirestore(doc);

    expect(mapper.documentId(row), 'review:1/a');
    expect(restored.id, row.id);
    expect(restored.questionId, row.questionId);
    expect(restored.rating, row.rating);
    expect(restored.state, row.state);
    expect(restored.due, row.due);
    expect(restored.review, row.review);
    expect(restored.heuristicVersion, 2);
    expect(doc['schemaVersion'], ReviewLogMapper.schemaVersion);
  });
}
