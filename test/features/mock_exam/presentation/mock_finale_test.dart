import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';

void main() {
  test('submission input keeps immutable original parts and outcomes', () {
    final questions = [
      const MockFinaleQuestion(id: 'q', outcome: MockFinaleOutcome.blank),
    ];
    final part = MockFinalePart(name: 'Science', questions: questions);
    final parts = [
      part,
      MockFinalePart(name: 'Retired part', questions: const []),
    ];
    final input = MockFinaleInput(
      reason: MockSubmitReason.timeUp,
      currentPartIndex: 0,
      currentQuestionIndex: 0,
      parts: parts,
    );
    questions.clear();
    parts.clear();
    expect(input.parts, hasLength(2));
    expect(input.parts.first.questions.single.id, 'q');
    expect(input.parts.first.questions.single.outcome, MockFinaleOutcome.blank);
    expect(input.parts.last.questions, isEmpty);
    expect(input.parts.clear, throwsUnsupportedError);
    expect(() => input.parts.first.questions.clear(), throwsUnsupportedError);
  });
}
