import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/application/mock_session_controller.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';

void main() {
  MockSessionController sectional({int at = 0}) {
    final controller = MockSessionController.initial(
      attemptId: 'att_1',
      durationSeconds: 180 * 60,
      questionIds: [for (var i = 0; i < 70; i += 1) 'q_$i'],
      parts: const [
        MockSessionPart(name: 'Reading', startIndex: 0, count: 40, minutes: 30),
        MockSessionPart(name: 'Maths', startIndex: 40, count: 30, minutes: 40),
      ],
    );
    if (at != 0) controller.goTo(at);
    return controller;
  }

  /// A roamable exam is a single part covering the whole exam, so every
  /// boundary rule is vacuously satisfied by the same code path.
  MockSessionController roamable({int at = 0}) {
    final controller = MockSessionController.initial(
      attemptId: 'att_1',
      durationSeconds: 180 * 60,
      questionIds: [for (var i = 0; i < 70; i += 1) 'q_$i'],
    );
    if (at != 0) controller.goTo(at);
    return controller;
  }

  int indexOf(MockSessionController controller) =>
      (controller.state as MockSessionInProgress).currentIndex;

  test('next stops at the last item of a part', () {
    final controller = sectional(at: 39);

    expect(controller.canGoNext, isFalse);
    // ignore: cascade_invocations
    controller.goNext();
    expect(indexOf(controller), 39);
  });

  test('previous stops at the first item of a part', () {
    final controller = sectional();

    expect(controller.canGoPrevious, isFalse);
    // ignore: cascade_invocations
    controller.goPrevious();
    expect(indexOf(controller), 0);
  });

  test('a roamable exam is one part and pages the whole way', () {
    final controller = roamable(at: 39);

    expect(controller.canGoNext, isTrue);
    // ignore: cascade_invocations
    controller.goNext();
    expect(indexOf(controller), 40);
  });

  test('the grid cannot cross into a part that has not opened', () {
    final controller = sectional();

    // ignore: cascade_invocations
    controller.goTo(45);

    expect(indexOf(controller), 0);
  });

  test('a closed part cannot be reopened, even by the grid', () {
    final controller = sectional(at: 10);

    // ignore: cascade_invocations
    controller.closeCurrentPart();
    expect(controller.state, isA<MockSessionBetweenParts>());
    controller.startNextPart();
    expect(indexOf(controller), 40);
    expect(controller.currentPartIndex, 1);

    // ignore: cascade_invocations
    controller.goTo(3);
    expect(indexOf(controller), isNot(3));
  });

  test('the clock counts the part, not the exam', () {
    final controller = sectional();

    // ignore: cascade_invocations
    controller.tickTo(60);
    expect(controller.remainingInPart, const Duration(minutes: 29));

    // ignore: cascade_invocations
    controller.closeCurrentPart();
    // The second part starts with its own full limit, not what the exam
    // has left.
    expect(controller.remainingInPart, const Duration(minutes: 40));
  });

  test('a roamable exam counts the whole exam', () {
    final controller = roamable();

    // ignore: cascade_invocations
    controller.tickTo(60);
    expect(controller.remainingInPart, const Duration(minutes: 179));
  });

  test('closing the last part ends the exam', () {
    final controller = sectional();
    final reasons = <MockSubmitReason>[];
    final ending = MockSessionController.initial(
      attemptId: 'att_1',
      durationSeconds: 180 * 60,
      questionIds: [for (var i = 0; i < 70; i += 1) 'q_$i'],
      parts: const [
        MockSessionPart(name: 'Reading', startIndex: 0, count: 40, minutes: 30),
        MockSessionPart(name: 'Maths', startIndex: 40, count: 30, minutes: 40),
      ],
      onSubmit: reasons.add,
    );

    controller.closeCurrentPart();

    ending
      ..closeCurrentPart()
      ..startNextPart()
      ..closeCurrentPart();

    expect(ending.state, isA<MockSessionSubmitted>());
    expect(reasons, [MockSubmitReason.timeUp]);
  });

  test('the part runs out on its own clock', () {
    final controller = sectional();

    // ignore: cascade_invocations
    controller.tickTo(30 * 60);

    // The exam has hours left, but this part is over, so the next one
    // opens on its own full clock.
    expect(controller.currentPartIndex, 1);
    expect(
      (controller.state as MockSessionBetweenParts).snapshot.currentIndex,
      40,
    );
    expect(controller.remainingInPart, const Duration(minutes: 40));
  });
}
