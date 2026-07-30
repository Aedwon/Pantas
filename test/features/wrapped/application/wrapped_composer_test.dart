import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/wrapped/application/wrapped_composer.dart';
import 'package:pantas/features/wrapped/domain/wrapped_trigger_event.dart';

void main() {
  test('returns null when no archetype is resolved', () {
    final payload = const WrappedComposer().compose(
      trigger: WrappedTriggerEvent(
        artifactId: 'post_mock_recap',
        examId: 'exam_cse',
        userId: 'user_1',
        firedAt: DateTime.utc(2026, 6, 10),
      ),
      archetype: null,
      shareId: 'share_1',
    );

    expect(payload, isNull);
  });

  test('composes coherent payload with at least two slides', () {
    final payload = const WrappedComposer().compose(
      trigger: WrappedTriggerEvent(
        artifactId: 'post_mock_recap',
        examId: 'exam_cse',
        userId: 'user_1',
        firedAt: DateTime.utc(2026, 6, 10),
      ),
      archetype: const WrappedArchetypeSnapshot(
        id: 'game_day_player',
        label: 'Game-Day Player',
        synthesizedCopy: 'You lift in mock mode.',
      ),
      shareId: 'share_1',
    );

    expect(payload, isNotNull);
    expect(payload!.title, 'Mock recap');
    expect(payload.slides.length, greaterThanOrEqualTo(2));
    expect(payload.slides.last.body, 'You lift in mock mode.');
  });
}
