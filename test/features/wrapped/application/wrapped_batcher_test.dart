import 'package:pantas/features/wrapped/application/wrapped_batcher.dart';
import 'package:pantas/features/wrapped/domain/wrapped_trigger_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('batches same-day streak and mastery triggers', () {
    final day = DateTime(2026, 6, 10, 9);
    final events = [
      WrappedTriggerEvent(
        artifactId: 'streak_milestone_30',
        examId: 'exam_cse',
        userId: 'user_1',
        firedAt: day,
      ),
      WrappedTriggerEvent(
        artifactId: 'mastery_crossing_topic_1',
        examId: 'exam_cse',
        userId: 'user_1',
        firedAt: day.add(const Duration(hours: 1)),
      ),
    ];

    final batched = const WrappedBatcher().batch(events);

    expect(batched, hasLength(1));
    expect(batched.single.artifactId, 'milestone_batch_2026-06-10');
    expect(batched.single.children, events);
  });

  test('does not batch post mock or post exam triggers', () {
    final day = DateTime(2026, 6, 10, 9);
    final events = [
      WrappedTriggerEvent(
        artifactId: 'post_mock_recap',
        examId: 'exam_cse',
        userId: 'user_1',
        firedAt: day,
      ),
      WrappedTriggerEvent(
        artifactId: 'post_exam_debrief',
        examId: 'exam_cse',
        userId: 'user_1',
        firedAt: day,
      ),
    ];

    expect(const WrappedBatcher().batch(events), events);
  });
}
