import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_finale_motion.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';

MockFinaleInput paper(int count, {int correct = 0}) => MockFinaleInput(
      reason: MockSubmitReason.timeUp,
      currentPartIndex: 0,
      currentQuestionIndex: 0,
      parts: [
        MockFinalePart(
          name: 'CSE',
          questions: [
            for (var i = 0; i < count; i++)
              MockFinaleQuestion(
                id: 'q$i',
                outcome: i < correct
                    ? MockFinaleOutcome.correct
                    : MockFinaleOutcome.blank,
              ),
          ],
        ),
      ],
    );

void main() {
  test('actual paper sizes keep one dot per retained question', () {
    for (final count in [1, 12, 60, 145, 155]) {
      final motion = CseFinaleMotion(paper(count));
      expect(motion.questions, hasLength(count));
      expect(motion.questions.map((q) => q.id).toSet(), hasLength(count));
    }
  });

  test('approved thirteen-column booklet extends rows downward', () {
    final motion = CseFinaleMotion(paper(155));
    expect(motion.initialPosition(0).dx, 58.5);
    expect(motion.initialPosition(0).dy, 166);
    expect(motion.initialPosition(12).dx, 322.5);
    expect(motion.initialPosition(13).dx, 58.5);
    expect(motion.initialPosition(13).dy, 182);
    expect(motion.initialPosition(154).dy, 342);
    expect(motion.initialCard.height, 255);
    expect(motion.checkingCard.height, 237);
    expect(motion.checkingPosition(154).dy, 480);
    expect(motion.scanEnd, 494);
  });

  test('every supported short paper fits its card and count line', () {
    for (var count = 1; count <= 155; count++) {
      final motion = CseFinaleMotion(paper(count));
      for (var i = 0; i < count; i++) {
        final initial = motion.initialPosition(i);
        final checking = motion.checkingPosition(i);
        expect(initial.dx, greaterThanOrEqualTo(motion.initialCard.left));
        expect(initial.dx + 9, lessThanOrEqualTo(motion.initialCard.right));
        expect(initial.dy + 9, lessThan(motion.countY));
        expect(checking.dy + 9, lessThanOrEqualTo(motion.checkingCard.bottom));
        expect(checking.dy + 9, lessThan(motion.scanEnd));
      }
    }
  });

  test('actual outcome order survives packing and gathering', () {
    final input = MockFinaleInput(
      reason: MockSubmitReason.manual,
      currentPartIndex: 0,
      currentQuestionIndex: 1,
      parts: [
        MockFinalePart(
          name: 'CSE',
          questions: const [
            MockFinaleQuestion(id: 'wrong', outcome: MockFinaleOutcome.wrong),
            MockFinaleQuestion(
              id: 'correct',
              outcome: MockFinaleOutcome.correct,
            ),
            MockFinaleQuestion(id: 'blank', outcome: MockFinaleOutcome.blank),
          ],
        ),
      ],
    );
    final motion = CseFinaleMotion(input);
    expect(motion.questions.map((q) => q.id), ['wrong', 'correct', 'blank']);
    expect(motion.correctCount, 1);
    expect(motion.blankCount, 1);
    expect(motion.hasBall, isTrue);
    expect(motion.dotAt(0, 3100).opacity, 0);
    expect(motion.dotAt(2, 3100).opacity, 0);
    final arrival = motion.dotAt(1, 3900);
    expect(arrival.position.dx + 4.5, closeTo(195, .001));
    expect(arrival.position.dy + 4.5, closeTo(359, .001));
    expect(arrival.opacity, 0);
  });

  test('no correct answers have no ball or impact', () {
    final motion = CseFinaleMotion(paper(155));
    expect(motion.hasBall, isFalse);
    expect(motion.correctCount, 0);
    expect(motion.dotAt(154, 3100).opacity, 0);
  });

  test('original ball deformation and timing remain sampled exactly', () {
    final impactApproach = sampleCseFinaleEffect(540, 4446.022);
    expect(impactApproach.scaleX, closeTo(1.55, .00001));
    expect(impactApproach.scaleY, closeTo(.72, .00001));
    expect(impactApproach.rotation, closeTo(-129.8, .00001));
    expect(impactApproach.opacity, 1);
    final launch = sampleCseFinaleEffect(539, 4563.0405);
    expect(launch.x, closeTo(-108, .00001));
    expect(launch.y, closeTo(-129.5, .00001));
  });
  test('large-text reflow still gathers at the actual gauge-aligned point', () {
    final motion = CseFinaleMotion(paper(155, correct: 1));
    final frame = motion.dotAt(
      0,
      3900,
      verticalOffset: 100,
      gatheringCenter: const Offset(195, 549),
    );
    expect(frame.position.dx + 4.5, closeTo(195, .001));
    expect(frame.position.dy + 4.5, closeTo(549, .001));
  });

  test('the booklet fade keeps the original nonlinear easing', () {
    expect(
      sampleCseFinaleEffect(531, 3412.491).opacity,
      closeTo(0.04519059050633534, .001),
    );
  });
  test('scan colors follow the eased bar and ignore shared vertical reflow',
      () {
    final motion = CseFinaleMotion(paper(155));
    expect(motion.dotAt(0, 2180).checked, isFalse);
    expect(motion.dotAt(0, 2250).checked, isTrue);
    expect(motion.dotAt(154, 2800, verticalOffset: 100).checked, isTrue);
    expect(
      motion.dotAt(154, 2800, verticalOffset: 100).checked,
      motion.dotAt(154, 2800).checked,
    );
  });
}
