import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

// ignore_for_file: cascade_invocations, unnecessary_lambdas

void main() {
  test('answer change records answer index and elapsed atSec', () {
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 600,
      questionIds: ['q1', 'q2'],
    )
      ..tickTo(42)
      ..answerCurrent(1);

    final state = controller.state as MockSessionInProgress;
    expect(state.answers['q1'], const MockAnswer(selectedIndex: 1, atSec: 42));
  });

  test('flag toggle updates current question flag set', () {
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 600,
      questionIds: ['q1'],
    );

    controller.toggleFlag();
    expect((controller.state as MockSessionInProgress).flags, {'q1'});

    controller.toggleFlag();
    expect((controller.state as MockSessionInProgress).flags, isEmpty);
  });

  test('pause forces paused state and resume restores in progress', () {
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 600,
      questionIds: ['q1'],
    );

    controller.pause();
    expect(controller.state, isA<MockSessionPaused>());

    controller.resume();
    expect(controller.state, isA<MockSessionInProgress>());
  });

  test('restored session keeps answers position elapsed and part clock', () {
    final controller = MockSessionController.restored(
      attemptId: 'mock_1',
      durationSeconds: 1800,
      questionIds: ['q1', 'q2', 'q3'],
      currentIndex: 2,
      elapsedSeconds: 180,
      answers: const {
        'q1': MockAnswer(selectedIndex: 1, atSec: 42),
      },
      flags: const {'q2'},
      strictMode: false,
      parts: const [
        MockSessionPart(name: 'Part 1', startIndex: 0, count: 2, minutes: 2),
        MockSessionPart(name: 'Part 2', startIndex: 2, count: 1, minutes: 10),
      ],
      currentPartIndex: 1,
      partStartedAtSeconds: 120,
    );

    final state = controller.state as MockSessionInProgress;
    expect(state.currentIndex, 2);
    expect(state.elapsedSeconds, 180);
    expect(state.answers['q1'], const MockAnswer(selectedIndex: 1, atSec: 42));
    expect(state.flags, {'q2'});
    expect(controller.currentPartIndex, 1);
    expect(controller.partStartedAtSeconds, 120);
    expect(controller.remainingInPart, const Duration(minutes: 9));
  });

  test('strict mode hides pause capability', () {
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 600,
      questionIds: ['q1'],
      strictMode: true,
    );

    expect(controller.canPause, isFalse);
    expect(() => controller.pause(), throwsStateError);
  });

  test('five minute and one minute warnings emit once', () {
    final warnings = <MockTimeWarning>[];
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 600,
      questionIds: ['q1'],
      onWarning: warnings.add,
    );

    controller
      ..tickTo(300)
      ..tickTo(300)
      ..tickTo(540)
      ..tickTo(540);

    expect(warnings, [MockTimeWarning.fiveMinutes, MockTimeWarning.oneMinute]);
  });

  test('remaining zero submits with timeUp', () {
    MockSubmitReason? reason;
    void capture(MockSubmitReason value) => reason = value;
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 60,
      questionIds: ['q1'],
      onSubmit: capture,
    );

    controller.tickTo(60);

    expect(controller.state, isA<MockSessionSubmitted>());
    expect(reason, MockSubmitReason.timeUp);
  });

  test('strict background forfeit submits with strictBackground', () {
    MockSubmitReason? reason;
    void capture(MockSubmitReason value) => reason = value;
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 60,
      questionIds: ['q1'],
      strictMode: true,
      onSubmit: capture,
    );

    controller.strictBackgroundExceeded();

    expect(controller.state, isA<MockSessionForfeited>());
    expect(reason, MockSubmitReason.strictBackground);
  });

  test('submitting early records a manual submission', () {
    MockSubmitReason? reason;
    void capture(MockSubmitReason value) => reason = value;
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 600,
      questionIds: ['q1'],
      onSubmit: capture,
    );

    controller.submitNow();

    expect(controller.state, isA<MockSessionSubmitted>());
    expect(reason, MockSubmitReason.manual);
  });

  test('strict mode refuses an early submission', () {
    MockSubmitReason? reason;
    void capture(MockSubmitReason value) => reason = value;
    final controller = MockSessionController.initial(
      attemptId: 'mock_1',
      durationSeconds: 600,
      questionIds: ['q1'],
      strictMode: true,
      onSubmit: capture,
    );

    controller.submitNow();

    expect(controller.state, isA<MockSessionInProgress>());
    expect(reason, isNull);
  });
}
