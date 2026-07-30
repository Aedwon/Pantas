import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/picker/drill_picker.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:flutter_test/flutter_test.dart';

Question question(String id) => Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: 'topic_algebra',
      language: 'en',
      stem: 'stem $id',
      choices: const [
        Choice(id: 'c_a', label: 'A', text: 'a', isCorrect: true),
        Choice(id: 'c_b', label: 'B', text: 'b', isCorrect: false),
      ],
      explanation: 'because',
    );

List<Question> pool(int count) =>
    [for (var i = 0; i < count; i++) question('q_$i')];

void main() {
  test('the pool is shuffled, not taken from the top', () {
    final questions = pool(30);

    final first = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 10,
        shuffleSeed: 1,
      ),
    );
    final second = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 10,
        shuffleSeed: 2,
      ),
    );

    expect(first.map((q) => q.id), isNot(equals(second.map((q) => q.id))));
  });

  test('the same seed picks the same session', () {
    final questions = pool(30);

    final first = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 10,
        shuffleSeed: 7,
      ),
    );
    final second = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 10,
        shuffleSeed: 7,
      ),
    );

    expect(first.map((q) => q.id), equals(second.map((q) => q.id)));
  });

  test('recently answered questions are skipped', () {
    final questions = pool(20);

    final picked = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 5,
        excludedQuestionIds: const {'q_0', 'q_1', 'q_2'},
        shuffleSeed: 1,
      ),
    );

    expect(
      picked.map((q) => q.id),
      isNot(anyElement(isIn(['q_0', 'q_1', 'q_2']))),
    );
  });

  test('an exhausted pool still fills the session', () {
    final questions = pool(6);

    final picked = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 6,
        excludedQuestionIds: {for (final q in questions) q.id},
        shuffleSeed: 1,
      ),
    );

    expect(picked, hasLength(6));
  });

  test('a short pool gives what it has', () {
    final picked = DrillPicker().pick(
      PickContext(
        allQuestions: pool(3),
        requestedLength: 10,
        shuffleSeed: 1,
      ),
    );

    expect(picked, hasLength(3));
  });
}
