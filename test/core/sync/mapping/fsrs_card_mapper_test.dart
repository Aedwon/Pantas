import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/mapping/fsrs_card_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fsrs mapper preserves scheduling fields and omits dirty', () {
    final row = ReviewStateLocalRow(
      questionId: 'q1',
      questionVersion: 3,
      stage: 'review',
      stability: 4.5,
      difficulty: 6.5,
      due: DateTime.utc(2026, 5, 20),
      lastReview: DateTime.utc(2026, 5, 18),
      reps: 4,
      lapses: 1,
      elapsedDays: 2,
      scheduledDays: 5,
      dirty: true,
    );

    final doc = const FsrsCardMapper().toFirestore(
      row,
      updatedAt: DateTime.utc(2026, 5, 18, 2),
      originDeviceId: 'device-1',
    );

    expect(doc['questionId'], 'q1');
    expect(doc['questionVersion'], 3);
    expect(doc['stage'], 'review');
    expect(doc['due'], '2026-05-20T00:00:00.000Z');
    expect(doc, isNot(contains('dirty')));
    expect(const FsrsCardMapper().fromFirestore(doc).dirty, isFalse);
  });
}
